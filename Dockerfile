# Build stage
FROM golang:1.14-alpine AS build

# Install build dependencies
RUN apk add --no-cache \
    git \
    make \
    build-base \
    ca-certificates

# Set working directory
WORKDIR /mattermost-server

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN make build-linux

# Runtime stage
FROM alpine:3.12

# Some ENV variables
ENV PATH="/mattermost/bin:${PATH}"
ARG PUID=2000
ARG PGID=2000

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    libc6-compat \
    libffi-dev \
    linux-headers \
    mailcap \
    netcat-openbsd \
    xmlsec-dev \
    tzdata \
    && rm -rf /tmp/*

# Create mattermost user and directories
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins /mattermost/logs /mattermost/config \
    && addgroup -g ${PGID} mattermost \
    && adduser -D -u ${PUID} -G mattermost -h /mattermost -D mattermost \
    && chown -R mattermost:mattermost /mattermost

# Copy built binaries from build stage
COPY --from=build --chown=mattermost:mattermost /mattermost-server/bin/linux_amd64/mattermost /mattermost/bin/
COPY --from=build --chown=mattermost:mattermost /mattermost-server/bin/linux_amd64/platform /mattermost/bin/

# Copy configuration files and resources
COPY --from=build --chown=mattermost:mattermost /mattermost-server/fonts /mattermost/fonts
COPY --from=build --chown=mattermost:mattermost /mattermost-server/templates /mattermost/templates
COPY --from=build --chown=mattermost:mattermost /mattermost-server/i18n /mattermost/i18n
COPY --from=build --chown=mattermost:mattermost /mattermost-server/config /mattermost/config

# Configure entrypoint
COPY build/entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER mattermost

# Healthcheck to make sure container is ready
HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl -f http://localhost:8065/api/v4/system/ping || exit 1

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /mattermost
CMD ["mattermost"]

# Expose ports
EXPOSE 8065 8067 8074 8075

# Declare volumes for mount point directories
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
