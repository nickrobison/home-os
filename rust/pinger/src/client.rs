use std::net::ToSocketAddrs;

use capnp_rpc::{rpc_twoparty_capnp, RpcSystem, twoparty};
use futures::{AsyncReadExt, FutureExt};
use logs::info;
use tokio::sync::oneshot;

use crate::callback::RegistrationCallbackImpl;
use crate::Config;
use crate::pinger_rpc::registrar_capnp::{registrar, registration_callback};
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

    req.get()
        .init_request()
        .set_name("Rust Test");

    // Add the callback
    let (tx, _rx) = oneshot::channel();
    let callback: registration_callback::Client = capnp_rpc::new_client(RegistrationCallbackImpl { sender: tx });
    req.get().set_callback(callback);

    let _ = req.send().promise.await?;
    Ok(())
}