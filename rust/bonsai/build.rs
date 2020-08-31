extern crate capnpc;

use std::env;
use std::path::Path;

fn main() {
    let path_env = env::var_os("GOPATH").unwrap();
    let gopath = path_env.to_str().unwrap();
    let dir = env::current_dir().unwrap();
    let path = dir.join("../../protocols");
    capnpc::CompilerCommand::new()
        .src_prefix(path.as_path())
        // Add the import path to the Golang
        .import_path(Path::new(gopath).join("src/zombiezen.com/go/capnproto2/std"))
        .file(path.join("registration.capnp"))
        .file(path.join("metrics.capnp"))
        .run().expect("schema compiler command");
}