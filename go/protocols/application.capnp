using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");
@0xe5fec9f03b35e1f2;

using import "services.capnp".Service;

struct Application {
    name @0 :Text;
    description @1 :Text;
    consumes @2 :List(Service);
    produces @3 :List(Service);
}