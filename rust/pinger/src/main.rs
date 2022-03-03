use logs::info;

use types::Result;

use crate::config::Config;

mod types;
mod client;
mod config;
mod callback;

#[tokio::main]
async fn main() -> Result<()> {
    env_logger::init();
    info!("Starting!");

    // Create the config
    let conf = Config::new("127.0.0.1:7000".to_string())?;
    info!("Connecting to: {}", conf.host);
    return client::main(conf).await;
}
