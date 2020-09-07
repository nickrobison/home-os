use std::{error, time};

use capnp::serialize;
use clap::{App, Arg};
use log::info;

use crate::config::Config;
use crate::registration_capnp::registration_request;

mod client;
mod config;

pub mod registration_capnp {
    include!(concat!(env!("OUT_DIR"), "/registration_capnp.rs"));
}

pub mod metrics_capnp {
    include!(concat!(env!("OUT_DIR"), "/metrics_capnp.rs"));
}

type Result<T> = std::result::Result<T, Box<dyn error::Error>>;

#[tokio::main]
async fn main() -> Result<()> {
    info!("Starting application");

    // Command line arguments
    let matches = App::new("Bonsai")
        .version("0.1")
        .author("Nick Robison <nick@nickrobison.com")
        .about("Monitor Bonsai tree soil parameters")
        // .arg("-c, --config=[FILE] 'Sets a custom config file'")
        .arg(Arg::from_usage("-f, --frequency=[FREQUENCY] 'Set update frequency (in seconds)'"))
        .get_matches();

    // Update frequency
    let freq = time::Duration::from_secs(matches.value_of("frequency").unwrap_or("10").parse().unwrap());

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

    // Create the config file.
    let conf = Config::new(freq, "localhost:8081".to_string())?;
    info!("Connecting to {}", conf.core_host);
    info!("Updating every {} seconds.", conf.frequency.as_secs());

    // Ok, now let's see if we can get some RPC stuff working
    return client::main(conf).await;
}
