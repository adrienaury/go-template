FROM gcr.io/distroless/base
ARG BIN
COPY /bin/${BIN} /entrypoint
CMD ["/entrypoint"]
