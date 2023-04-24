SRC_DIR := ../../protocols
DEST_DIR := .
SOURCES := config.capnp
SOURCE_TARGETS := $(patsubst %,$(DEST_DIR)/%.capnp, $(basename $(SOURCES)))
DEST_TARGETS := $(patsubst %,$(DEST_DIR)/%.capnp.go, $(basename $(SOURCES)))
PREFIX_STRING := 'using Go = import "\/go.capnp";\n$$Go.package("protocols");\n$$Go.import("protocols");\n'
CAPNP_FLAGS := '-I$(GOPATH)/src/capnproto.org/go/capnp/std'

.PHONY: copy

copy: $(SOURCE_TARGETS)

$(DEST_DIR)/%.capnp: $(SRC_DIR)/%.capnp
	# cp $< $@
	sed '1s/^/'$(PREFIX_STRING)'/' $< > $@

build: $(DEST_TARGETS)

%.capnp.go: %.capnp
	capnp compile $(CAPNP_FLAGS) -ogo $<

help:
	@echo 'Sources:'
	@echo $(DEST_TARGETS)

clean:
	rm -f *.capnp
	rm -f *.go
