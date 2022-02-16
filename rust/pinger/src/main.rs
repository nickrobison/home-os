use std::error;

use logs::info;

type Result<T> = std::result::Result<T, Box<dyn error::Error>>;


#[tokio::main]
async fn main() -> Result<()> {
    env_logger::init();
    info!("Starting!");
    return Ok(())
}
