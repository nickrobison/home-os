@0xb1de3984a98f80b1;
using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");

interface Metrics {
    submit @0 (name :Text, value: Float64) -> ();
}