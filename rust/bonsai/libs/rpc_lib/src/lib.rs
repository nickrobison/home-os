pub mod registration_capnp {
    include!(concat!(env!("OUT_DIR"), "/registration_capnp.rs"));
}

pub mod metrics_capnp {
    include!(concat!(env!("OUT_DIR"), "/metrics_capnp.rs"));
}