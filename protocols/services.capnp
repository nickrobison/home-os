@0x84619e3f4ed62791;

using Metrics = import "metrics.capnp";

interface Ping {
    ping @0 () -> (response :Text);
    reply @1 (msg :Text) -> (response :Text);
}

struct Service {
    name @0 :Text;

    union {
        metrics @1 :Metrics.Metrics;
        ping @2 :Ping;
    }
}

interface ServiceResolver {
    resolve @0 () -> (services :List(Service));
}

interface ServiceManager {
  list @0 () -> (services :List(Service));
}

enum ServiceType {
  ping @0;
  metrics @1;
}