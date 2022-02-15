@0x84619e3f4ed62791;

using Metrics = import "metrics.capnp"

struct Service {
    name @0 :Text;

    union {
        metrics @1 :Metrics.Metrics;
    }
}

interface ServiceManager {
    list @0 () -> (services: :List(:Service))
}
