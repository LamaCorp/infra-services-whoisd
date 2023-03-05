package main

import (
	"bufio"
	"io"
	"net"
	"os"
	"time"

	"github.com/likexian/whois"
	log "github.com/sirupsen/logrus"
)

const MaxLineLenBytes = 1024
const ReadWriteTimeout = time.Minute

func main() {
	log.SetFormatter(&log.JSONFormatter{})

	log_level_, ok := os.LookupEnv("WHOISD_LOG_LEVEL")
	if !ok {
		log_level_ = "warn"
	}
	log_level, err := log.ParseLevel(log_level_)
	if err != nil {
		log.Fatalf("log level is invalid, defaulting to warn")
		log_level = log.WarnLevel
	}
	log.SetLevel(log_level)

	listen_addr, ok := os.LookupEnv("WHOISD_LISTEN")
	if !ok {
		listen_addr = ":43"
	}

	lis, err := net.Listen("tcp", listen_addr)
	if err != nil {
		log.Fatalf("failed to start listener: %v", err)
	}

	for {
		conn, err := lis.Accept()
		if err != nil {
			log.Errorf("failed to accept conn: %v", err)
			continue
		}

		go handleConn(conn)
	}
}

func handleConn(conn net.Conn) {
	var logger = log.WithFields(log.Fields{"remote_addr": conn.RemoteAddr()})
	logger.Info("accepted connection")

	defer func() {
		_ = conn.Close()
		logger.Debug("closed connection")
	}()
	done := make(chan struct{})

	_ = conn.SetReadDeadline(time.Now().Add(ReadWriteTimeout))

	go func() {
		lim := &io.LimitedReader{
			R: conn,
			N: MaxLineLenBytes,
		}
		scan := bufio.NewScanner(lim)
		for scan.Scan() {
			query := scan.Text()

			response, err := whois.Whois(query)
			if err != nil {
				response = "% There was an error processing your request, please try again shortly."
				logger.Warnf("failed to execute query `%s`: %v", query, err)
			}

			if _, err := conn.Write([]byte(response + "\n")); err != nil {
				logger.Warnf("failed to write response: %v", err)
				return
			}
			break
		}

		done <- struct{}{}
	}()

	<-done
}
