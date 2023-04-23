package api

import (
	"github.com/go-chi/chi"
	"github.com/nickrobison/home-os/core/api/registrar"
	"net/http"
)

func NewV1API() http.Handler {
	r := chi.NewRouter()

	r.Post("/register", registrar.SubmitRegistration)

	return r
}
