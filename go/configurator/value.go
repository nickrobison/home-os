package main

import (
	"context"

	"nickrobison.com/homeos/protocols"
)

type ConfigValue struct {
	key  string
	name string
}

func (v ConfigValue) Set(ctx context.Context, call protocols.ConfigValue_set) error {
	return nil
}

func (v ConfigValue) Get(ctx context.Context, call protocols.ConfigValue_get) error {
	return nil
}

func (v ConfigValue) Name(ctx context.Context, call protocols.ConfigNode_name) error {
	resp, err := call.AllocResults()
	if err != nil {
		return err
	}

	return resp.SetName(v.name)
}

func CreateConfigValue(key string, name string) (*ConfigValue, error) {
	return &ConfigValue{key, name}, nil
}
