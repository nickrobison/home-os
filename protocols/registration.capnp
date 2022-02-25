@0x8f5494d9dd28283d;

using Services = import "services.capnp";

struct ServiceRequest {
      reason @0 :Text;
}

interface RegistrationCallback {
    success @0 (resolver :Services.ServiceResolver) -> ();
    failure @1 (err :Text) -> ();
}



struct RegistrationRequest {
    name @0 :Text;
    description @1 :Text;
    consumes @2 :List(ServiceRequest);
    produces @3 :List(Services.Service);
    callback @4 :RegistrationCallback;
}

struct RegistrationResponse {
    union {
        success @0 :Services.ServiceResolver;
        failure @1 :Text;
    }
}
