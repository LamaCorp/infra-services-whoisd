FROM golang:1.22 as builder

WORKDIR /go/src/whoisd

COPY ./ ./

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o whoisd .

FROM debian:12

WORKDIR /app

COPY --from=builder /go/src/whoisd/whoisd /app/whoisd

CMD ["/app/whoisd"]
