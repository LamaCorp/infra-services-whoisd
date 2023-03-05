FROM golang:1.19 as builder

WORKDIR /go/src/whoisd

COPY ./ ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o whoisd .

FROM debian:11

WORKDIR /app

COPY --from=builder /go/src/whoisd/whoisd /app/whoisd

CMD ["/app/whoisd"]
