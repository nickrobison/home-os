@0x8f5494d9dd28283d;

using Services = import "services.capnp";

struct RegistrationRequest {
    name @0 :Text;
}

struct RegistrationResponse {
    union {
        success @0 :Services.ServiceResolver;
        failure @1 :Text;
    }
}
