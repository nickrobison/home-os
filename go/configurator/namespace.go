package main

import (
	"context"
	"fmt"

	"github.com/rs/zerolog"
	"nickrobison.com/homeos/protocols"
)

type ConfigNamespace struct {
	prefix string
	name   string
	logger *zerolog.Logger
}

func (c ConfigNamespace) List(ctx context.Context, call protocols.ConfigNamespace_list) error {
	c.logger.Warn().Msg("Not implemented!!")
	return nil
}

func (c ConfigNamespace) CreateValue(ctx context.Context, call protocols.ConfigNamespace_createValue) error {
	name, err := call.Args().Name()
	if err != nil {
		return err
	}

	keyValue := fmt.Sprintf("%s/%s", c.prefix, name)
	keyName := fmt.Sprintf("%s/%s", c.name, name)

	value, err := CreateConfigValue(keyValue, keyName)
	if err != nil {
		return err
	}

	value_server := protocols.ConfigValue_ServerToClient(value)

	resp, err := call.AllocResults()
	if err != nil {
		return err
	}

	return resp.SetValue(value_server)
}

func (c ConfigNamespace) Name(ctx context.Context, call protocols.ConfigNode_name) error {
	resp, err := call.AllocResults()
	if err != nil {
		return err
	}

	return resp.SetName(c.prefix)
}

func (c ConfigNamespace) CreateNamespace(ctx context.Context, call protocols.ConfigNamespace_createNamespace) error {
	c.logger.Warn().Msg("Not implemented!!")
	return nil
}

func CreateNamespace(prefix string, name string, logger *zerolog.Logger) (*ConfigNamespace, error) {
	return &ConfigNamespace{prefix, name, logger}, nil
}
