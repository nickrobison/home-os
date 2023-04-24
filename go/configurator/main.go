package main

import (
	"context"
	"io"
	"net"
	"os"

	"capnproto.org/go/capnp/v3"
	"capnproto.org/go/capnp/v3/rpc"
	"github.com/rs/zerolog/log"
	"nickrobison.com/homeos/protocols"
)

const SOCK_ADDER = "/tmp/configurator.sock"

func main() {
	log.Info().Msg("Starting up")

	err := os.RemoveAll(SOCK_ADDER)
	if err != nil {
		log.Panic().Err(err).Msg("Cannot remove socket")
	}

	ctx := context.Background()

	l, err := net.Listen("tcp", ":6000")
	if err != nil {
		log.Panic().Err(err).Msg("Cannot bind to socket")
	}
	defer l.Close()

	log.Info().Msg("Connected to port 6000")

	c1, err := l.Accept()
	if err != nil {
		log.Panic().Err(err).Msg("Cannot listen on socket")
	}
	serverServer(ctx, c1)

}

func serverServer(ctx context.Context, rwc io.ReadWriteCloser) error {
	server, err := CreateConfigFactory(ctx, []string{""})
	if err != nil {
		return err
	}

	srv := protocols.ConfigFactory_NewServer(server)

	client := capnp.NewClient(srv)

	conn := rpc.NewConn(rpc.NewStreamTransport(rwc), &rpc.Options{
		BootstrapClient: client,
	})
	defer conn.Close()

	select {
	case <-conn.Done():
		return nil

	case <-ctx.Done():
		return conn.Close()
	}

}
