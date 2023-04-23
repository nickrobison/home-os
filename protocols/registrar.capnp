using Go = import "/go.capnp";
@0xc66174b4f8a2dcd1;
$Go.package("protocols");
$Go.import("src/protocols");

using Registration = import "registration.capnp";

interface Registrar {
    register @0 (request :Registration.RegistrationRequest) -> ();
}

