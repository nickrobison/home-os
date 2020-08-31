use std::error;

use capnp::serialize;

use crate::registration_capnp::registration_request;

mod client;

pub mod registration_capnp {
    include!(concat!(env!("OUT_DIR"), "/registration_capnp.rs"));
}

pub mod metrics_capnp {
    include!(concat!(env!("OUT_DIR"), "/metrics_capnp.rs"));
}

type Result<T> = std::result::Result<T, Box<dyn error::Error>>;

#[tokio::main]
async fn main() -> Result<()> {
    let mut message = ::capnp::message::Builder::new_default();
    let mut request = message.init_root::<registration_request::Builder>();

    request.set_name("Hello");

    let mut writer = Vec::new();

    let err = serialize::write_message(&mut writer, &message);
    if err.is_err() {
        return Err("Nope, cannot".into());
    }

    let resp = reqwest::get("http://localhost:8080/version")
        .await?
        .text()
        .await?;
    println!("{:?}", resp);

    let client = reqwest::Client::new();

    let r2 = client.post("http://localhost:8080/api/v1/register")
        .body(writer)
        .send()
        .await?;

    if r2.status() != 202 {
        return Err("Registration failed".into());
    }

    // Ok, now let's see if we can get some RPC stuff working
    return client::main().await;
}
