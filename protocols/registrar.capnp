@0xc66174b4f8a2dcd1;

using Registration = import "registration.capnp";
using Services = import "services.capnp";

interface Registrar {
    register @0 (request :Registration.RegistrationRequest, callback :RegistrationCallback) -> ();
}

interface RegistrationCallback {
    success @0 (resolver :Services.ServiceResolver) -> ();
    failure @1 (err :Text) -> ();
}
