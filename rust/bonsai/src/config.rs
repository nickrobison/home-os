use std::env;
use std::time::Duration;

pub struct Config {
    pub core_host: String,
    pub frequency: Duration,

}

impl Config {
    pub fn new(freq: Duration, hostname: String) -> Result<Config, &'static str> {
        // If we have a corresponding environment variable, is that instead of the passed value
        let env_result = env::var("HOSTNAME");
        let final_name = env_result.unwrap_or(hostname);
        return Ok(Config {
            core_host: final_name,
            frequency: freq,
        });
    }
}