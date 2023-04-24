@0x9f394813d4260427;

interface ConfigFactory {
    create @0 (serviceName: Text) -> (namespace: ConfigNamespace);
}

interface ConfigNode {
    name @0 () -> (name :Text);
}

interface ConfigNamespace extends(ConfigNode) {
    list @0 () -> (list :List(Entry));

    struct Entry {
        name @0 :Text;
        node @1 :ConfigNode;
    }

    createValue @1 (name :Text) -> (value :ConfigValue);
    createNamespace @2 (name :Text) -> (namespace :ConfigNamespace);
}

interface ConfigValue extends(ConfigNode) {
    set @0 (value :Data);
    get @1 () -> (value :Data);
}
