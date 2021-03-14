# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := /bin/zsh # Use zsh syntax

# Build variables
BUILD_DIR ?= bin
PROJECT_MODULE ?= $(shell git config --local remote.origin.url|sed -n 's#.*//\(.*\)\.git#\1#p')
PROJECT_NAME ?= $(shell git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')
VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH ?= $(shell git rev-parse HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
BUILD_BY ?= $(shell git config user.email)
LDFLAGS += -X main.version=${VERSION} -X main.commit=${COMMIT_HASH} -X main.buildDate=${BUILD_DATE} -X main.builtBy=${BUILD_BY}

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
	@echo "==============================================================="
	@echo PROJECT_MODULE=$(PROJECT_MODULE)
	@echo PROJECT_NAME=$(PROJECT_NAME)
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
	@echo BUILD_DATE=$(BUILD_DATE)
	@echo "==============================================================="

.PHONY: refresh
refresh:
	rm -f go.mod go.sum
	go mod init ${PROJECT_MODULE}
	go mod tidy

.PHONY: clean
clean: info ## Clean builds
	rm -rf ${BUILD_DIR}/

.PHONY: mkdir
mkdir: clean
	mkdir -p ${BUILD_DIR}

.PHONY: build-%
build-%: mkdir refresh
	GO111MODULE=on go build ${GOARGS} -ldflags "-X main.name=$* ${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: build
build: $(patsubst cmd/%,build-%,$(wildcard cmd/*)) ## Build all binaries

.PHONY: run-%
run-%: build-%
	${BUILD_DIR}/$* ${ARGS}

.PHONY: run
run: $(patsubst cmd/%,run-%,$(wildcard cmd/*)) ## Build and execute a binary

.PHONY: lint
lint: ## Examines Go source code and reports suspicious constructs
	golangci-lint run

.PHONY: release-%
release-%:
	GO111MODULE=on go build ${GOARGS} -ldflags "-w -s -X main.name=$* ${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: release
release: mkdir refresh lint $(patsubst cmd/%,release-%,$(wildcard cmd/*)) ## Build all binaries for production

.PHONY: publish-%
publish-%:
	source .env && export GITHUB_TOKEN BUILD_DATE=${BUILD_DATE} MAIN=$* && cd cmd/$* && goreleaser release -f ../../.goreleaser.yml --rm-dist --snapshot
	#source .env && export GITHUB_TOKEN BUILD_DATE=${BUILD_DATE} MAIN=$* && goreleaser --debug release --rm-dist --snapshot

.PHONY: publish
publish: mkdir refresh lint $(patsubst cmd/%,publish-%,$(wildcard cmd/*)) ## Publish binaries and documentation
