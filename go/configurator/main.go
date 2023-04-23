package main

import (
	"context"
	"io"
	"net"

	"capnproto.org/go/capnp/v3/rpc"
	"github.com/rs/zerolog/log"
	"nickrobison.com/homeos/protocols"
)

func main() {
	log.Info().Msg("Starting up")

	ctx := context.Background()

	l, err := net.Listen("unix", "/tmp/configurator.sock")
	if err != nil {
		log.Panic().Err(err).Msg("Cannot bind to socket")
	}
	defer l.Close()

	c1, err := l.Accept()
	if err != nil {
		log.Panic().Err(err).Msg("Cannot listen on socket")
	}
	serverServer(ctx, c1)

}

func serverServer(ctx context.Context, rwc io.ReadWriteCloser) error {
	server, err := CreateConfigServer(ctx, []string{""})
	if err != nil {
		return err
	}

	srv := protocols.ConfigFactory_Server(server)

	conn := rpc.NewConn(rpc.NewStreamTransport(rwc), nil)
	defer conn.Close()

	select {
	case <-conn.Done():
		return nil

	case <-ctx.Done():
		return conn.Close()
	}

}
