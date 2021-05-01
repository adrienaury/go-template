# A Self-Documenting Makefile: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html

SHELL := /bin/zsh # Use zsh syntax

# Build variables
BUILD_DIR ?= bin
PROJECT_MODULE ?= $(shell git config --local remote.origin.url|sed -n 's#.*//\(.*\)\.git#\1#p')
PROJECT_NAME ?= $(shell git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p')
USER_NAME ?= $(shell git config --local user.name)
VERSION ?= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH ?= $(shell git rev-parse HEAD 2>/dev/null)
BUILD_DATE ?= $(shell date +%FT%T%z)
BUILD_BY ?= $(shell git config user.email)
LDFLAGS += -X main.version=${VERSION} -X main.commit=${COMMIT_HASH} -X main.buildDate=${BUILD_DATE} -X main.builtBy=${BUILD_BY}

# Project variables
MAIN = ${PROJECT_NAME}
DOCKER_IMAGE = ${USER_NAME}/${PROJECT_NAME}
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
info: ## Print build informations
	@neon info

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

.PHONY: test
test: mkdir ## Run all tests with coverage
	GO111MODULE=on go test -coverprofile=${BUILD_DIR}/coverage.txt -covermode=atomic ./...

.PHONY: lint
lint: ## Examines Go source code and reports suspicious constructs
	golangci-lint run

.PHONY: release-%
release-%: mkdir refresh lint
	GO111MODULE=on go build ${GOARGS} -ldflags "-w -s -X main.name=$* ${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: release
release: $(patsubst cmd/%,release-%,$(wildcard cmd/*)) ## Build all binaries for production

.PHONY: publish
publish: mkdir refresh lint release ## Publish binaries and documentation
	cat .goreleaser.template.yml | gomplate > ${BUILD_DIR}/.goreleaser.yml
	source .env && export GITHUB_TOKEN BUILD_DATE=${BUILD_DATE} && goreleaser release -f ${BUILD_DIR}/.goreleaser.yml --rm-dist --snapshot

.PHONY: docker-%
docker-%: release ## Build docker image locally
	if [ ${MAIN} = "$*" ]; then DOCKER_IMAGE=${DOCKER_IMAGE}; else DOCKER_IMAGE=${DOCKER_IMAGE}-$*; fi; \
	if [ -f ./Dockerfile.$* ]; then \
		sudo docker build -t $${DOCKER_IMAGE}:${DOCKER_TAG} --build-arg BIN=$* -f Dockerfile.$* .; \
	elif [ -f ./cmd/$*/Dockerfile ]; then \
		sudo docker build -t $${DOCKER_IMAGE}:${DOCKER_TAG} --build-arg BIN=$* -f ./cmd/$*/Dockerfile .; \
	else \
		sudo docker build -t $${DOCKER_IMAGE}:${DOCKER_TAG} --build-arg BIN=$* .; \
	fi; \
    if [ ${RELEASE} -eq 1 ]; then \
		sudo docker tag $${DOCKER_IMAGE}:${DOCKER_TAG} $${DOCKER_IMAGE}:${MAJOR}.${MINOR}; \
		sudo docker tag $${DOCKER_IMAGE}:${DOCKER_TAG} $${DOCKER_IMAGE}:${MAJOR}; \
		sudo docker tag $${DOCKER_IMAGE}:${DOCKER_TAG} $${DOCKER_IMAGE}:latest; \
	fi

.PHONY: docker
docker: $(patsubst cmd/%,docker-%,$(wildcard cmd/*)) ## Build all docker images locally

.PHONY: push-%
push-%: docker ## Push docker image on DockerHub
	if [ ${MAIN} = "$*" ]; then DOCKER_IMAGE=${DOCKER_IMAGE}; else DOCKER_IMAGE=${DOCKER_IMAGE}-$*; fi; \
	sudo docker push $${DOCKER_IMAGE}:${DOCKER_TAG}; \
    if [ ${RELEASE} -eq 1 ]; then \
		sudo docker push $${DOCKER_IMAGE}:${MAJOR}.${MINOR}; \
		sudo docker push $${DOCKER_IMAGE}:${MAJOR}; \
		sudo docker push $${DOCKER_IMAGE}:latest; \
	fi

.PHONY: push
push: $(patsubst cmd/%,push-%,$(wildcard cmd/*)) ## Push all docker images on DockerHub
