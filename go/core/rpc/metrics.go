package rpc

import (
	"github.com/nickrobison/home-os/protocols"
	"github.com/rs/zerolog/log"
)

type MetricsHandler struct{}

func (h MetricsHandler) Submit(call protocols.Metrics_submit) error {
	name, err := call.Params.Name()
	if err != nil {
		return err
	}
	value := call.Params.Value()
	log.Info().Str("metric", name).Float64("value", value).Msg("")

	return nil
}
