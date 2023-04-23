package main

import (
	"fmt"
	"github.com/go-chi/chi"
	cm "github.com/go-chi/chi/middleware"
	"github.com/nickrobison/home-os/core/api"
	"github.com/nickrobison/home-os/core/rpc"
	"github.com/nickrobison/home-os/middleware"
	"github.com/nickrobison/home-os/protocols"
	"github.com/rs/zerolog/log"
	"net"
	"net/http"
	cr "zombiezen.com/go/capnproto2/rpc"
)

func server(conn net.Conn) error {
	main := protocols.Metrics_ServerToClient(rpc.MetricsHandler{})
	c := cr.NewConn(cr.StreamTransport(conn), cr.MainInterface(main.Client))

	err := c.Wait()
	return err
}

func rpcRun(conn net.Listener) error {
	for {
		l, err := conn.Accept()
		if err != nil {
			return err
		}

		go server(l)
	}
}

func main() {
	log.Info().Msg("Starting up")

	r := chi.NewRouter()
	r.Use(cm.RequestID)
	r.Use(cm.RealIP)
	r.Use(middleware.NewStructuredLogger(&log.Logger))
	r.Use(middleware.ContextLogger(&log.Logger))
	r.Use(cm.Recoverer)

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world\n"))
	})
	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		logger := middleware.GetLogger(r)
		logger.Debug().Msg("I'm logging the version")
		w.Write([]byte(fmt.Sprintln("Version: 1")))
	})

	r.Mount("/api/v1", api.NewV1API())

	// Startup the capnproto stuff
	log.Info().Msg("Starting CapnRPC")
	conn, err := net.Listen("tcp", ":8081")
	if err != nil {
		panic(err)
	}
	defer conn.Close()

	go rpcRun(conn)
	log.Info().Msg("CapnRPC started")

	http.ListenAndServe(":8080", r)
}
