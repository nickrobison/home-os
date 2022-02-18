extern crate capnpc;

fn main() {
    capnpc::CompilerCommand::new()
        .file("protocols/registrar.capnp")
        .file("protocols/registration.capnp")
        .file("protocols/services.capnp")
        .file("protocols/metrics.capnp")
        .run().expect("schema compiler command");
}