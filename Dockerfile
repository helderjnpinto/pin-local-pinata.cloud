FROM golang:1.22-alpine

WORKDIR /app

# Install runtime tools and certs
RUN apk --no-cache add bash curl ca-certificates jq

# Copy project files
COPY . .
# Make scripts executable
RUN chmod +x check_pinned_status.sh

# Entrypoint with wait-for-IPFS logic
CMD ["sh", "-c", "\
    echo '⏳ Waiting for IPFS API to be ready...'; \
    until curl -s http://ipfs-node:5001/api/v0/version > /dev/null; do \
    sleep 2; \
    done; \
    echo '✅ IPFS is ready.'; \
    curl -X POST 'http://ipfs-node:5001/api/v0/swarm/connect?arg=/dnsaddr/bitswap.pinata.cloud' \
    && ls -la && go run pin_checker.go && ./check_pinned_status.sh \
    "]
