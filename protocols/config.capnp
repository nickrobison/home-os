using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("src/protocols");
@0x9f394813d4260427;

interface ConfigFactory {
    create @0 (name: Text) -> (v: Text);
}
