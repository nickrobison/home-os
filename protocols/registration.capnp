@0x8f5494d9dd28283d;
using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");

struct RegistrationRequest {
    name @0 :Text;
    callback @1 :Text;
}