FROM adrienaury/go-devcontainer:v0.2

RUN sudo apk add --update make gomplate

RUN    wget -nv -O- https://github.com/mitchellh/golicense/releases/download/v0.2.0/golicense_0.2.0_linux_x86_64.tar.gz | tar -C /usr/bin golicense_0.2.0_linux_x86_64.tar.gz golicense \
    && wget -nv -O/usr/bin/mlr https://github.com/johnkerl/miller/releases/download/v5.10.2/mlr.linux.x86_64
