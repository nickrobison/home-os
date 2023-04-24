package main

import (
	"context"
	"time"

	"github.com/rs/zerolog/log"
	clientv3 "go.etcd.io/etcd/client/v3"
	"nickrobison.com/homeos/protocols"
)

type ConfigFactory struct {
	client *clientv3.Client
}

func (c ConfigFactory) Create(ctx context.Context, call protocols.ConfigFactory_create) error {
	name, err := call.Args().ServiceName()
	if err != nil {
		return err
	}
	log.Info().Str("service", name).Msg("Creating Namespace for service")

	sublogger := log.With().Str("service", name).Str("namespace", name).Logger()

	// When create a namespace, the default name is root
	ns, err := CreateNamespace(name, "/", &sublogger)
	if err != nil {
		return nil
	}

	ns_server := protocols.ConfigNamespace_ServerToClient(ns)

	res, err := call.AllocResults()
	if err != nil {
		return err
	}

	return res.SetNamespace(ns_server)
}

func (c ConfigFactory) Close() error {
	return c.client.Close()
}

func CreateConfigFactory(ctx context.Context, endpoints []string) (ConfigFactory, error) {
	client, err := clientv3.New(clientv3.Config{
		Endpoints:   endpoints,
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		return ConfigFactory{}, err
	}

	return ConfigFactory{client}, nil
}
