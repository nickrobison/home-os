@0x8f5494d9dd28283d;

using Services = import "services.capnp";

struct RegistrationRequest {
    name @0 :Text;
    callback @1 :Text;
}

struct RegistrationResponse {
    union {
        success @0 :Services.ServiceManager;
        failure @1 :Text;
    }
}
