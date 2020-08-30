
SOURCE=$(shell find . -iname "*.go")

.PHONY: all
all: | $(GOBIN)/core

.PHONY: clean
clean:
	rm -rf $(GOBIN)/core

.PHONY: core
core: $(GOBIN)/core

$(GOBIN)/core: $(SOURCE)
	go build -o $(GOBIN)/core \
	core/cmd/main.go