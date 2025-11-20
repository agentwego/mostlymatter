# Dockerfile for Mostlymatter
# This builds and runs the Mostlymatter server (a Mattermost fork with removed user limits)

# Build stage
FROM debian:bookworm AS builder

# Build arguments
ARG GO_VERSION=1.24.6
ARG GO_HASHSUM=bbca37cc395c974ffa4893ee35819ad23ebb27426df87af92e93a9ec66ef8712

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin
ENV GO111MODULE=on

# Install build dependencies
RUN apt-get update && \
    apt-get install -qq -y build-essential libpng-dev libpng16-16 wget curl git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install Go
WORKDIR /tmp
RUN wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" && \
    echo "${GO_HASHSUM}  go${GO_VERSION}.linux-amd64.tar.gz" > "go${GO_VERSION}.linux-amd64.tar.gz.sha256sum" && \
    sha256sum -c "go${GO_VERSION}.linux-amd64.tar.gz.sha256sum" && \
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" && \
    rm -f "go${GO_VERSION}.linux-amd64.tar.gz" "go${GO_VERSION}.linux-amd64.tar.gz.sha256sum"

# Copy source code
WORKDIR /build
COPY . .

# Apply limitless patch and build
RUN git apply limitless.patch && \
    cd server && \
    make validate-go-version && \
    make setup-go-work && \
    make build-linux-$(dpkg --print-architecture)

# Runtime stage - using distroless for minimal attack surface
FROM gcr.io/distroless/base-debian12

# Build Arguments
ARG PUID=2000
ARG PGID=2000

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_SERVICESETTINGS_ENABLELOCALMODE="true"

# Create directory structure for mattermost with proper ownership
COPY --from=builder --chown=${PUID}:${PGID} /build/server/bin/mostlymatter /mattermost/bin/mostlymatter

# Copy passwd file with mattermost user
COPY --from=builder /build/server/build/passwd /etc/passwd

# We should refrain from running as privileged user
USER mattermost

# Configure entrypoint and command
WORKDIR /mattermost

# Healthcheck to make sure container is ready
HEALTHCHECK --interval=30s --timeout=10s \
  CMD ["/mattermost/bin/mostlymatter", "version"]

CMD ["/mattermost/bin/mostlymatter"]

EXPOSE 8065 8067 8074 8075

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
