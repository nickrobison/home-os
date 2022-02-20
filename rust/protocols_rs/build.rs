extern crate capnpc;

fn main() {
    capnpc::CompilerCommand::new()
        .file("protocols/registrar.capnp")
        .file("protocols/registration.capnp")
        .file("protocols/services.capnp")
        .file("protocols/metrics.capnp")
        .default_parent_module(vec!["protocols".into()])
        .output_path("src")
        .run().expect("Capnp compilation failed");
}