package registrar

import (
	"github.com/nickrobison/home-os/middleware"
	"github.com/nickrobison/home-os/protocols"
	"github.com/rs/zerolog/log"
	"net/http"
	"zombiezen.com/go/capnproto2"
)

func SubmitRegistration(w http.ResponseWriter, r *http.Request) {
	logger := middleware.GetLogger(r)
	logger.Info().Msg("Submitting registration")

	msg, err := capnp.NewDecoder(r.Body).Decode()
	if err != nil {

		logger.Error().Stack().Msg(err.Error())
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	logger.Info().Msg("Let's get the message")

	request, err := protocols.ReadRootRegistrationRequest(msg)
	if err != nil {
		logger.Err(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	name, err := request.Name()
	if err != nil {
		logger.Err(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	callback, err := request.Callback()
	if err != nil {
		logger.Err(err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	log.Info().Str("name", name).Str("callback", callback).Msg("Done")
	w.WriteHeader(http.StatusAccepted)
}
