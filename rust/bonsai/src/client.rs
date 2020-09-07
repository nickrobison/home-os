use capnp_rpc::{rpc_twoparty_capnp, RpcSystem, twoparty};
use futures::{AsyncReadExt, FutureExt};

use crate::config::Config;
use crate::metrics_capnp::metrics;

pub async fn main(config: Config) -> Result<(), Box<dyn std::error::Error>> {
    tokio::task::LocalSet::new().run_until(try_main(config)).await
}

async fn try_main(config: Config) -> Result<(), Box<dyn std::error::Error>> {
    use std::net::ToSocketAddrs;

    let addr = config.core_host.to_socket_addrs()?.next().expect("Could not parse address");
    let stream = tokio::net::TcpStream::connect(&addr).await?;
    stream.set_nodelay(true)?;

    let (reader, writer) = tokio_util::compat::Tokio02AsyncReadCompatExt::compat(stream).split();

    let network = Box::new(twoparty::VatNetwork::new(reader, writer, rpc_twoparty_capnp::Side::Client, Default::default()));

    let mut rpc_system = RpcSystem::new(network, None);
    let metrics: metrics::Client = rpc_system.bootstrap(rpc_twoparty_capnp::Side::Server);
    tokio::task::spawn_local(Box::pin(rpc_system.map(|_| ())));

    loop {
        let mut request = metrics.submit_request();
        request.get().set_name("Test Metric");
        request.get().set_value(3.14);
        request.send().promise.await?;
        std::thread::sleep(config.frequency);
    }

    Ok(())
}