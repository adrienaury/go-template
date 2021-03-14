# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := /bin/zsh # Use zsh syntax

# Build variables
BUILD_DIR ?= bin
PROJECT_NAME ?= $(git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')
VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH ?= $(shell git rev-parse HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
BUILD_BY ?= $(shell git config user.email)
LDFLAGS += -X main.tag=${VERSION} -X main.commit=${COMMIT_HASH} -X main.buildDate=${BUILD_DATE} -X main.builtBy=${BUILD_BY}

# Project variables
DOCKER_IMAGE = adrienaury/${PROJECT_NAME}
DOCKER_TAG ?= $(shell echo -n ${VERSION} | sed -e 's/[^A-Za-z0-9_\\.-]/_/g')
RELEASE := $(shell [[ $(VERSION) =~ ^[0-9]*.[0-9]*.[0-9]*$$ ]] && echo 1 || echo 0 )
MAJOR := $(shell echo $(VERSION) | cut -f1 -d.)
MINOR := $(shell echo $(VERSION) | cut -f2 -d.)
PATCH := $(shell echo $(VERSION) | cut -f3 -d. | cut -f1 -d-)

.PHONY: help
.DEFAULT_GOAL := help
help:
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: info
info: ## Prints build informations
	@echo COMMIT_HASH=$(COMMIT_HASH)
	@echo VERSION=$(VERSION)
	@echo RELEASE=$(RELEASE)
ifeq (${RELEASE}, 1)
	@echo MAJOR=$(MAJOR)
	@echo MINOR=$(MINOR)
	@echo PATCH=$(PATCH)
endif
	@echo DOCKER_IMAGE=$(DOCKER_IMAGE)
	@echo DOCKER_TAG=$(DOCKER_TAG)
	@echo BUILD_BY=$(BUILD_BY)

.PHONY: clean
clean: ## Clean builds
	rm -rf ${BUILD_DIR}/

.PHONY: mkdir
mkdir:
	mkdir -p ${BUILD_DIR}

.PHONY: build-%
build-%: mkdir #generate
	GO111MODULE=on go build ${GOARGS} -ldflags "${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: build
build: $(patsubst cmd/%,build-%,$(wildcard cmd/*)) ## Build all binaries

.PHONY: run-%
run-%: build-%
	${BUILD_DIR}/$* ${ARGS}

.PHONY: run
run: $(patsubst cmd/%,run-%,$(wildcard cmd/*)) ## Build and execute a binary

.PHONY: release-%
release-%: mkdir
	GO111MODULE=on go build ${GOARGS} -ldflags "-w -s ${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: release
release: clean info lint $(patsubst cmd/%,release-%,$(wildcard cmd/*)) ## Build all binaries for production

.PHONY: publish
publish:  ## Publish binaries
	BUILD_DATE=${BUILD_DATE} VERSION=${VERSION} \
	docker-compose \
	  -f .devcontainer/docker-compose.yml \
	  -p ${PROJECT_NAME}_devcontainer \
	  run \
	  -e BUILD_DATE \
	  -e VERSION \
	  goreleaser --rm-dist release
