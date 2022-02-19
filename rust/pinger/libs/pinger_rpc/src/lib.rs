pub mod registration_capnp {
    include!(concat!(env!("OUT_DIR"), "/protocols/registration_capnp.rs"));
}

pub mod registrar_capnp {
    include!(concat!(env!("OUT_DIR"), "/protocols/registrar_capnp.rs"));
}

pub mod services_capnp {
    include!(concat!(env!("OUT_DIR"), "/protocols/services_capnp.rs"));
}

pub mod metrics_capnp {
    include!(concat!(env!("OUT_DIR"), "/protocols/metrics_capnp.rs"));
}