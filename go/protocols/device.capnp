using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");
@0xc3f4d6c1465a3511;

using import "application.capnp".Application;

struct Device {
    id @0 :Text;
    name @1 :Text;
    applications @2 :List(Application);
}