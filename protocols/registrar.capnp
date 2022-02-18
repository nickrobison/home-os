@0xc66174b4f8a2dcd1;

using Registration = import "registration.capnp";

interface Registrar {
    register @0 (request :Registration.RegistrationRequest, callback :RegistrationCallback) -> ();
}

interface RegistrationCallback {
    callback @0 (response :Registration.RegistrationResponse) -> ();
}
