using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");
@0xf2a4c92f4415d4a0;

interface Ping {
    ping @0 () -> (response :Text);
    reply @1 (msg :Text) -> (response :Text);
}