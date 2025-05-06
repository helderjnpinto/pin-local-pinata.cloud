FROM golang:1.22-alpine

WORKDIR /app

# Install runtime tools and certificates
RUN apk --no-cache add bash curl ca-certificates jq

# Copy project files
COPY . .

# Make scripts executable
RUN chmod +x check_pinned_status.sh

# Set the IPFS API endpoint as an environment variable
ENV IPFS_API=http://ipfs-node:5001/api/v0

# Entrypoint with wait-for-IPFS logic
CMD ["sh", "-c", "\
    echo '⏳ Waiting for IPFS API to be ready...'; \
    timeout=60; \
    while ! curl -s -X POST $IPFS_API/version > /dev/null; do \
    sleep 2; \
    timeout=$((timeout - 2)); \
    if [ $timeout -le 0 ]; then \
    echo '❌ Timeout waiting for IPFS API.'; \
    exit 1; \
    fi; \
    done; \
    echo '✅ IPFS is ready.'; \
    curl -X POST \"$IPFS_API/swarm/connect?arg=/dnsaddr/bitswap.pinata.cloud\"; \
    ls -la; \
    go run pin_checker.go; \
    ./check_pinned_status.sh \
    "]

