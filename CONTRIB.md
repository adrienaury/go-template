# Contributing

## Create a local docker volume with sources

```console
docker volume create --driver local -o o=bind -o type=none -o device=/path/to/docker-credential-localuser docker-credential-localuser-sources
```

## Create a .env file

```.env
GITHUB_USER=<your github user>
GITHUB_REPO=<your github repo>
GITHUB_TOKEN=<your github token>
```

## TODO

- how to submit a contribution ?
- how to declare an issue ?
