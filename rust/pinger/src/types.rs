use std::error;

pub type Result<T> = std::result::Result<T, Box<dyn error::Error>>;
pub type Promise<T> = capnp::capability::Promise<T, capnp::Error>;