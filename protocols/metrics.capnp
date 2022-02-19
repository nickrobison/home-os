@0xb1de3984a98f80b1;

interface Metrics {
    submit @0 (name :Text, value :Float64) -> ();
    list @1 () -> (metrics :List(Text));
}
