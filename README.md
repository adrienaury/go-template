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
------------------------------------------------ info --
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

```console
$ neon promote
------------------------------------------------ promote --
Promoted to v0.2.0
OK
```

```console
$ neon -props '{tag: "v0.2.1-alpha"}' promote
------------------------------------------------ promote --
Promoted to v0.2.1-alpha
OK
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
