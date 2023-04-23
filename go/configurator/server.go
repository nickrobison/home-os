package main

import (
	"context"
	"time"

	"github.com/rs/zerolog/log"
	clientv3 "go.etcd.io/etcd/client/v3"
	"nickrobison.com/homeos/protocols"
)

type ConfigServer struct {
	client *clientv3.Client
}

func (c ConfigServer) Create(ctx context.Context, call protocols.ConfigFactory_create) error {
	name, err := call.Args().Name()
	if err != nil {
		return err
	}
	log.Info().Str("key", name).Msg("Creating directory")
	return nil
}

func (c ConfigServer) Close() error {
	return c.client.Close()
}

func CreateConfigServer(ctx context.Context, endpoints []string) (ConfigServer, error) {
	client, err := clientv3.New(clientv3.Config{
		Endpoints:   endpoints,
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		return ConfigServer{}, err
	}

	return ConfigServer{client}, nil
}
