use std::net::ToSocketAddrs;

use capnp_rpc::{rpc_twoparty_capnp, RpcSystem, twoparty};
use crossbeam::channel::bounded;
use futures::{AsyncReadExt, FutureExt};
use logs::{error, info};

use protocols_rs::protocols::registrar_capnp::registrar;
use protocols_rs::protocols::registration_capnp::registration_callback;

use crate::callback::RegistrationCallbackImpl;
use crate::Config;
use crate::types::Result;

pub async fn main(conf: Config) -> Result<()> {
    // Not sure any of this is actually required, but we'll see
    tokio::task::LocalSet::new().run_until(try_main(conf)).await
}

async fn try_main(conf: Config) -> Result<()> {
    info!("At least I'm trying");

    let addr = conf.host.to_socket_addrs()?.next().expect("Could not parse address");
    let stream = tokio::net::TcpStream::connect(&addr).await?;
    stream.set_nodelay(true)?;

    // It really seems like this shouldn't be required, but my Rust skills are too poor to figure it out
    let (reader, writer) = tokio_util::compat::TokioAsyncReadCompatExt::compat(stream).split();

    // let (reader, writer) = stream.split();

    let network = Box::new(twoparty::VatNetwork::new(reader, writer, rpc_twoparty_capnp::Side::Client, Default::default()));

    let mut rpc_system = RpcSystem::new(network, None);
    let client = rpc_system.bootstrap::<registrar::Client>(rpc_twoparty_capnp::Side::Server);
    tokio::task::spawn_local(Box::pin(rpc_system.map(|_| ())));

    let mut req = client.register_request();

    // Add the callback
    let (tx, rx) = bounded(1);
    let callback: registration_callback::Client = capnp_rpc::new_client(RegistrationCallbackImpl { sender: tx });

    let mut r2 = req.get()
        .init_request();

    r2.set_name("Rust Test");
    r2.set_callback(callback);

    let _ = req.send().promise.await?;

    let resp = rx.recv();

    match resp? {
        Ok(pinger) => {
            info!("Resolved correctly, yaya for us!");

            for _ in 0..3 {
                info!("Sending ping and reply");
                let _ = pinger.ping_request().send().promise;
                let mut reply_request = pinger.reply_request();
                reply_request.get()
                    .set_msg("Hello world");
                // Ideally these 2 requests would run in parallel
                let _ = match reply_request.send().promise.await {
                    Ok(r) => {
                        let response = r.get()?;
                        let msg = response.get_response()?;
                        info!("Received `{}` from service", msg);
                        Ok(())
                    }
                    Err(err) => {
                        Err(err)
                    }
                };
            }
        }
        Err(err) => {
            error!("Could not get correct services: {}", err);
        }
    }


    Ok(())
}