@0xb1de3984a98f80b1;
using Go = import "/go.capnp";
using RW = import "readwrite.capnp";
$Go.package("protocols");
$Go.import("protocols");

interface MetricsWriter = RW.Writer(:Float64);

interface Metrics {
    submit @0 (name :Text, value: Float64) -> ();
    create @1 (name :Text) -> (writer :MetricsWriter);
    list @2 () -> (metrics :List(:Text));
}
