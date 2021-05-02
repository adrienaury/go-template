# Go Template

This repository is a Go project template. This is not a real application, the go source code is an empty shell.

List of folders

- `cmd` contains source code of all compiled binaries, each sub-folder correspond to a binary.
- `internal` contains source code that cannot be linked in an external project.
- `pkg` contains source code that can be linked in an external project.
- `test` contains integration tests source code (run with venom).
- `githooks` contains git hooks for better automation.

## Usage

### Prerequisites

You need :

- Visual Studio Code ([download](https://code.visualstudio.com/)) with the [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed.
- Docker Desktop (Windows, macOS) or Docker CE/EE (Linux)

Details are available on [the official Visual Studio documentation](https://code.visualstudio.com/docs/remote/containers#_getting-started).

### Initialize a new repository using Github

When you [create a new repository on Github](https://github.com/new), you can select this project in the `Repository template` field. It will automatically initialize your new repository with this template.

### Initialize a new repository without using Github

```console
$ cd </your/project/root>
/your/project/root$ wget -nv -O- https://github.com/adrienaury/go-devcontainer/archive/refs/heads/main.tar.gz | tar --strip-components=1 -xz
/your/project/root$ git init -b main
/your/project/root$ git add .
/your/project/root$ git commit -m "chore: init repository from go template"
```

### Modify an existing repository

Warning: do this in a branch where to isolate the changes

```console
$ cd </your/project/root>
/your/project/root$ wget -nv -O- https://github.com/adrienaury/go-devcontainer/archive/refs/heads/main.tar.gz | tar --strip-components=1 -xz
```

### Run your workspace

When opening the folder with [Visual Studio Code](https://code.visualstudio.com/), the [Remote - Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) will detect the devcontainer configuration and ask you to reopen the project in a container.

Accept and enjoy !

## Features

- Structured Go code following folder names convention
- VSCode devcontainer pre-parameterized
- Auto code formatting, using EditorConfig extension
- Changelog, Contrib : all initialized with default templates
- Git commit message semantic validation
- Docker compatible (docker client and docker-compose are available inside the devcontainer)
- Build targets (run with `make` or `neon`) :
  - help : default target, print help message
  - info : print information on the build pipeline
  - promote : promote the project to a new tag using semantic versioning
  - refresh : refresh go modules dependencies
  - compile : compile sources
  - lint : check the code for suspicious constructs
  - test : run the unit tests
  - release : compile binaries, with production flags
  - test-int : run integration tests with venom
  - publish : publish binaries on Github with goreleaser
  - docker : build docker images
  - docker-tag : tag docker images using semantic versioning
  - docker-publish : publish docker images on Dockerhub

### Build targets

Run a build target by using the neon command.

```console
neon target
```

This text bloc show how target are related to each other. E.g. running the target `lint` will also run `info` and `refresh`.

```text
→ help
→ promote
→ info ┰─ docker ── docker-tag
       ┖─ refresh ┰─ compile
                  ┖─ lint ─ test ┰ release ─ test-int
                                 ┖─publish
```

#### Help

```console
$ neon help
----------------------------------------------- help --
Available targets

help        Print this message
info        Print build informations
promote     Promote the project with a new tag based on git log history
refresh     Refresh go modules (add missing and remove unused modules) [will trigger: info]
compile     Compile binary files locally [will trigger: info->refresh]
lint        Examine source code and report suspicious constructs [will trigger: info->refresh]
test        Run all tests with coverage [will trigger: info->refresh->lint]
release     Compile binary files for production [will trigger: info->refresh->lint->test]
test-int    Run all integration tests [will trigger: info->refresh->lint->test->release]
docker      Build docker images [will trigger: info]
docker-tag  Tag docker images [will trigger: info->docker]
publish     Publish tagged binary to Github [will trigger: info->refresh->lint->test]

Example : neon -props "{latest: true}" promote publish

Target dependencies
→ help
→ promote
→ info ┰─ docker ── docker-tag
       ┖─ refresh ┰─ compile
                  ┖─ lint ─ test ┰ release ─ test-int
                                 ┖─publish

OK
```

#### Info

Print build informations, like the author or the current tag.

```console
$ neon info
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = 00424c8c67bca5b11ed99efa0d45902f1143cbd7
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
OK
```

#### Promote

Promote the project with a new tag based on git log history, or based on the parameter passed with `-props` flag.

Without parameter, the tag name will be determined by the git commit history since the last tag (or will be equal to `v0.1.0` if there is no existing tag). This is base on the [`svu`](https://github.com/caarlos0/svu) tool.

```console
$ neon promote
--------------------------------------------- promote --
Promoted to v0.2.0
OK
```

It's possible to use the `-props` flag to override the name of the tag.

```console
$ neon -props '{tag: "v0.2.1-alpha"}' promote
--------------------------------------------- promote --
Promoted to v0.2.1-alpha
OK
```

#### Refresh

Refresh go modules (add missing and remove unused modules).

This target will keep your `go.mod` and `go.sum` files clean.

```console
$ neon refresh
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = 00424c8c67bca5b11ed99efa0d45902f1143cbd7
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
OK
```

#### Compile

Compile binary files locally.

By default, the `cmd` folder is scanned and each subfolder will create a binary with the name of the subfolder.

```console
$ neon compile
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = b0b418aa05db7f386275249ea641f14b295cf3ab
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
--------------------------------------------- compile --
Building cmd/cli
Building cmd/webserver
OK
```

It's possible to use the `-props` flag to specify a list of folders to compile. Be aware that if one of these folders does not have a `main` package, the result file will not be executable.

```console
$ neon -props '{buildpaths: ["internal/helloservice"]}' compile
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = b0b418aa05db7f386275249ea641f14b295cf3ab
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
--------------------------------------------- compile --
Building internal/helloservice
OK
```

#### Lint

Examine source code and report suspicious constructs. Under the hood, the [`golangci-lint`](https://github.com/golangci/golangci-lint) tool is used.

```console
$ neon lint
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = b0b418aa05db7f386275249ea641f14b295cf3ab
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
------------------------------------------------ lint --
Running command: golangci-lint run --fast --enable-all --disable scopelint --disable forbidigo
OK
```

By default, all fast linters are enabled (`--fast` and `--enable-all` flags on `golangci-lint`) but you can change this with the following build properties :

- linters : an array of linters to enable, if left empty then all fast linters are enabled.
- lintersno : an array of linters to disable, by default `scopelint` (deprecated) and `forbidigo` are disabled.

To change the default values, edit the `build.yml` file and look for the properties names `linters` or `lintersno`.

These build properties can also be set by the `neon -props` flag.

```console
$ neon -props '{linters: ["deadcode"]}' lint
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = b0b418aa05db7f386275249ea641f14b295cf3ab
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
------------------------------------------------ lint --
Running command: golangci-lint run --enable deadcode --disable scopelint --disable forbidigo
OK
```

#### Test

Run all tests with coverage.

```console
$ neon test
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = 6ac8d1ab1facb9969a84b330d08e0f3efac55819
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
------------------------------------------------ lint --
Running command: golangci-lint run --fast --enable-all --disable scopelint --disable forbidigo
------------------------------------------------ test --
?       github.com/adrienaury/go-template/cmd/cli       [no test files]
?       github.com/adrienaury/go-template/cmd/webserver [no test files]
?       github.com/adrienaury/go-template/internal/helloservice [no test files]
?       github.com/adrienaury/go-template/pkg/nameservice       [no test files]
OK
```

#### Release

Compile binary files for production.

The only difference with the [`compile`](#compile) target is with the `ldflags` passed to the Go linker (it will produce a smaller binary) and the dependency to other targets (`lint` and `test`).

```console
$ neon release
----------------------------------------------- info --
MODULE  = github.com/adrienaury/go-template
PROJECT = go-template
TAG     = refactor
COMMIT  = b0b418aa05db7f386275249ea641f14b295cf3ab
DATE    = 2021-05-02
BY      = adrienaury@gmail.com
RELEASE = no
--------------------------------------------- refresh --
go: creating new go.mod: module github.com/adrienaury/go-template
go: to add module requirements and sums:
        go mod tidy
------------------------------------------------ lint --
Running command: golangci-lint run --fast --enable-all --disable scopelint --disable forbidigo
------------------------------------------------ test --
?       github.com/adrienaury/go-template/cmd/cli       [no test files]
?       github.com/adrienaury/go-template/cmd/webserver [no test files]
?       github.com/adrienaury/go-template/internal/helloservice [no test files]
?       github.com/adrienaury/go-template/pkg/nameservice       [no test files]
--------------------------------------------- release --
Calling target 'compile'
--------------------------------------------- compile --
Building cmd/cli
Building cmd/webserver
OK
```

The build properties are the same as the [`compile`](#compile) target.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
