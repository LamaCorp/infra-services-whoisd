FROM golang:1.27@sha256:f44f6e88636cfb311f9ebace870ded69d943f227bb3cb27d32ffd84ea18c43ea AS builder

ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /go/src/whoisd

COPY ./ ./

ARG VERSION
ARG COMMIT
ENV VERSION=$VERSION
ENV COMMIT=$COMMIT

RUN go build \
  -trimpath \
  -ldflags="-s -w -X main.version=v$VERSION -X main.commit=$COMMIT" \
  -o whoisd \
  ./...

FROM debian:13@sha256:f324c7ff54321e8d9c588493a20244965938ce0aa50bbd1022d38010e9ffc4b1

ARG VERSION
ARG COMMIT

LABEL org.opencontainers.image.authors="Lama Corp."
LABEL org.opencontainers.image.source="https://github.com/LamaCorp/whoisd"
LABEL org.opencontainers.image.description="A recursive WHOIS server, it gets the data from whomever owns it."
LABEL org.opencontainers.image.documentation="https://github.com/LamaCorp/whoisd"
LABEL org.opencontainers.image.licenses="https://github.com/LamaCorp/whoisd/blob/main/LICENSE"
LABEL org.opencontainers.image.revision=${COMMIT}
LABEL org.opencontainers.image.title="whoisd"
LABEL org.opencontainers.image.url="https://github.com/LamaCorp/whoisd"
LABEL org.opencontainers.image.vendor="Lama Corp."
LABEL org.opencontainers.image.version=${VERSION}

WORKDIR /app

COPY ./LICENSE /app/LICENSE

COPY --from=builder /go/src/whoisd/whoisd /app/whoisd

CMD ["/app/whoisd"]
