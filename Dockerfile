# ---------- Stage 1: Build Go binary ----------
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o pin_checker pin_checker.go

# ---------- Stage 2: Run the binary + shell script ----------
FROM alpine:latest

WORKDIR /app

# Install necessary tools
RUN apk --no-cache add ca-certificates bash

# Copy compiled Go binary and scripts
COPY --from=builder /app/pin_checker .
COPY check_pinned_status.sh .
COPY all_files.jsonl .
COPY .env .

# Make the shell script executable
RUN chmod +x check_pinned_status.sh

# Entrypoint: run the Go checker, then the bash script
CMD ["sh", "-c", " \
    echo '⏳ Waiting for IPFS API to be ready...'; \
    until curl -s http://ipfs-node:5001/api/v0/version > /dev/null; do \
    sleep 2; \
    done; \
    echo '✅ IPFS is ready.'; \
    ./pin_checker && ./check_pinned_status.sh \
    "]

