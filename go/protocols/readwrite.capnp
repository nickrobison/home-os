using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");
@0xb0c3c3305b253e6e;

interface Writer(T) {
    write @0 (value :T) -> ();
}
