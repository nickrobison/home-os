@0xb1de3984a98f80b1;
using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");

interface Metrics {
    submit @0 (name :Text, value: Float64) -> ();
    create @1 (name :Text) -> (writer :MetricsWriter);
}

interface MetricsWriter {
    write @0 (value :Float64) -> ();
}