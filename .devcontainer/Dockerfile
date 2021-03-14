FROM qmcgaw/godevcontainer:alpine

RUN sudo apk add --update make gomplate
RUN wget -O- -nv https://install.goreleaser.com/github.com/goreleaser/goreleaser.sh | sudo sh -s -- -b /usr/local/bin
RUN wget -O- -nv https://install.goreleaser.com/github.com/caarlos0/svu.sh | sudo sh -s -- -b /usr/local/bin
