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
	@neon test

.PHONY: lint
lint: warning
	@neon lint

.PHONY: release-%
release-%: warning
	@neon -props "{buildpaths: ["cmd/$*"]}" release

.PHONY: release
release: warning
	@neon release

.PHONY: docker
docker: warning
	@neon docker

.PHONY: docker-tag
docker-tag: warning
	@neon docker-tag

.PHONY: publish
publish: warning
	@neon publish
