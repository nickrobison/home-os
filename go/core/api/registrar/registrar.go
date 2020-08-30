package registrar

import (
	"github.com/nickrobison/home-os/middleware"
	"github.com/nickrobison/home-os/protocols"
	"net/http"
	"zombiezen.com/go/capnproto2"
)

func SubmitRegistration(w http.ResponseWriter, r *http.Request) {
	logger := middleware.GetLogger(r)
	logger.Info().Msg("Submitting registration")

	msg, err := capnp.NewDecoder(r.Body).Decode()
	if err != nil {
		logger.Err(err)
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	_, err = protocols.ReadRootRegistrationRequest(msg)
	if err != nil {
		logger.Err(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusAccepted)
}
