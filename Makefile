##
## This project uses neon as a build tool, all of the make rules are mapped to the neon build in build.yml
##

SHELL := /bin/zsh # Use zsh syntax

.PHONY: warning
warning:
	@echo "This project uses neon as a build tool, all of the make rules are mapped to the neon build in build.yml"
	@echo "You should use the 'neon' command directly, it works the same way as make"
	@echo "example: neon build"

.PHONY: help
.DEFAULT_GOAL := help
help: warning
	@neon help

.PHONY: info
info: warning
	@neon info

.PHONY: promote
promote: warning
	@neon promote

.PHONY: refresh
refresh: warning
	@neon refresh

.PHONY: compile-%
build-%: warning
	@neon -props "{buildpaths: ["cmd/$*"]}" compile

.PHONY: compile
build: warning
	@neon compile

.PHONY: test
test: warning
	@echo TODO
	# GO111MODULE=on go test -coverprofile=${BUILD_DIR}/coverage.txt -covermode=atomic ./...

.PHONY: lint
lint: warning ## Examines Go source code and reports suspicious constructs
	golangci-lint run

.PHONY: release-%
release-%: warning
	@echo TODO
	# GO111MODULE=on go build ${GOARGS} -ldflags "-w -s -X main.name=$* ${LDFLAGS}" -o ${BUILD_DIR}/$* ./cmd/$*

.PHONY: release
release: $(patsubst cmd/%,release-%,$(wildcard cmd/*)) ## Build all binaries for production

.PHONY: publish
publish: warning
	@echo TODO
	# cat .goreleaser.template.yml | gomplate > ${BUILD_DIR}/.goreleaser.yml
	# source .env && export GITHUB_TOKEN BUILD_DATE=${BUILD_DATE} && goreleaser release -f ${BUILD_DIR}/.goreleaser.yml --rm-dist --snapshot
