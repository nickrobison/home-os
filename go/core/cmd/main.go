package main

import (
	"fmt"
	"github.com/go-chi/chi"
	cm "github.com/go-chi/chi/middleware"
	"github.com/nickrobison/home-os/core/api"
	"github.com/nickrobison/home-os/middleware"
	"github.com/rs/zerolog/log"
	"net/http"
)

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
		w.Write([]byte(fmt.Sprint("Version: 1\n")))
	})

	r.Mount("/api/v1", api.NewV1API())

	http.ListenAndServe(":8080", r)
}
