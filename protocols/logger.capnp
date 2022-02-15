@0xc44af6dd60b5376e;
using Go = import "/go.capnp";
$Go.package("protocols");
$Go.import("protocols");

interface Logger {
    enum Level {
        trace @0;
        debug @1;
        info @2;
        warn @3;
        error @4;
    }
    log @0(level :Level, msg :Text) -> ();
}

interface LoggerFactory {
    create @0 (request :LoggerRequest) -> (logger :Logger);
}

struct LoggerRequest {
    name @0 :Text;
}