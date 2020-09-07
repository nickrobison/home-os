package rpc

import (
	"fmt"
	"github.com/nickrobison/home-os/protocols"
	"github.com/rs/zerolog/log"
)

type MetricsWriter struct {
	name string
}

func (w MetricsWriter) Write(call protocols.MetricsWriter_write) error {
	value := call.Params.Value()
	log.Info().Str("metric", w.name).Float64("value", value).Msg("")
	return nil
}

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

func (h MetricsHandler) Create(call protocols.Metrics_create) error {
	name, err := call.Params.Name()
	if err != nil {
		return err
	}
	writer := MetricsWriter{name}
	log.Info().Msg(fmt.Sprintf("Creating metric: %s", name))
	w := protocols.MetricsWriter_ServerToClient(writer)
	err = call.Results.SetWriter(w)
	if err != nil {
		return err
	}
	return nil
}
