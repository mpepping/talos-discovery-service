# Build stage
FROM golang:1.25-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /build

# Clone the discovery-service repository
RUN git clone https://github.com/siderolabs/discovery-service.git .

# Build the binary directly with Go (allow automatic toolchain download)
# GOARCH will default to the build platform's architecture
RUN CGO_ENABLED=0 GOOS=linux GOTOOLCHAIN=auto go build -ldflags="-s -w" -o discovery-service ./cmd/discovery-service

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Create non-root user
RUN addgroup -g 1000 discovery && \
    adduser -D -u 1000 -G discovery discovery

# Copy binary from builder
COPY --from=builder /build/discovery-service /usr/local/bin/discovery-service

# Set ownership
RUN chown discovery:discovery /usr/local/bin/discovery-service

# Switch to non-root user
USER discovery

# Expose ports
EXPOSE 3000 3001

# Run the service
ENTRYPOINT ["/usr/local/bin/discovery-service"]
