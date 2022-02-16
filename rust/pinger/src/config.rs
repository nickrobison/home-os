pub struct Config {
    pub host: String,
}

impl Config {
    pub fn new(host: String) -> Result<Config, &'static str> {
        return Ok(Config {
            host
        });
    }
}