package main

import (
	"fmt"
	"github.com/go-chi/chi"
	"github.com/rs/zerolog/log"
	"net/http"
)

func main() {
	log.Info().Msg("Starting up")

	r := chi.NewRouter()

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world\n"))
	})
	r.Get("/version", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(fmt.Sprint("Version: 1\n")))
	})

	http.ListenAndServe(":8080", r)
}
