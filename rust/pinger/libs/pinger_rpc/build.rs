extern crate capnpc;

use std::env;

fn main() {
    let dir = env::current_dir().unwrap();
    let path = dir.join("./protocols");
    capnpc::CompilerCommand::new()
        .src_prefix(path.as_path())
        .file(path.join("registrar.capnp"))
        .file(path.join("registration.capnp"))
        .file(path.join("services.capnp"))
        .file(path.join("metrics.capnp"))
        .run().expect("schema compiler command");
}