# Docker Guide for Mostlymatter

This guide explains how to build and run Mostlymatter using Docker.

## Building the Docker Image

To build the Mostlymatter Docker image from source:

```bash
docker build -t mostlymatter:latest .
```

The build process:
1. Downloads and installs Go 1.24.6
2. Applies the limitless patch to remove user limits
3. Builds the Mostlymatter server binary
4. Creates a minimal runtime image based on distroless

### Build Arguments

You can customize the build with these arguments:

- `GO_VERSION`: Go version to use (default: 1.24.6)
- `PUID`: User ID for the mattermost user (default: 2000)
- `PGID`: Group ID for the mattermost user (default: 2000)

Example:
```bash
docker build -t mostlymatter:latest --build-arg PUID=1000 --build-arg PGID=1000 .
```

## Running Mostlymatter

### Basic Usage

```bash
docker run -d \
  --name mostlymatter \
  -p 8065:8065 \
  -v mostlymatter-data:/mattermost/data \
  -v mostlymatter-logs:/mattermost/logs \
  -v mostlymatter-config:/mattermost/config \
  -v mostlymatter-plugins:/mattermost/plugins \
  mostlymatter:latest
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3'

services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_USER: mmuser
      POSTGRES_PASSWORD: mmuser_password
      POSTGRES_DB: mattermost
    volumes:
      - postgres-data:/var/lib/postgresql/data

  mostlymatter:
    image: mostlymatter:latest
    ports:
      - "8065:8065"
    volumes:
      - mostlymatter-data:/mattermost/data
      - mostlymatter-logs:/mattermost/logs
      - mostlymatter-config:/mattermost/config
      - mostlymatter-plugins:/mattermost/plugins
    environment:
      MM_SQLSETTINGS_DRIVERNAME: postgres
      MM_SQLSETTINGS_DATASOURCE: "postgres://mmuser:mmuser_password@postgres:5432/mattermost?sslmode=disable&connect_timeout=10"
    depends_on:
      - postgres

volumes:
  postgres-data:
  mostlymatter-data:
  mostlymatter-logs:
  mostlymatter-config:
  mostlymatter-plugins:
```

Then run:
```bash
docker-compose up -d
```

## Configuration

Mostlymatter can be configured using:

1. **Environment Variables**: Prefix any configuration setting with `MM_`
2. **Configuration File**: Mount a `config.json` to `/mattermost/config/config.json`
3. **Command Line**: Pass configuration as command arguments

Example with environment variables:
```bash
docker run -d \
  --name mostlymatter \
  -p 8065:8065 \
  -e MM_SERVICESETTINGS_SITEURL=https://example.com \
  -e MM_SQLSETTINGS_DRIVERNAME=postgres \
  -e MM_SQLSETTINGS_DATASOURCE="postgres://user:pass@db:5432/mattermost?sslmode=disable" \
  mostlymatter:latest
```

## Accessing the Application

Once running, access Mostlymatter at:
- HTTP: `http://localhost:8065`
- WebSocket: `ws://localhost:8065`

## Ports

The container exposes the following ports:
- `8065`: HTTP/HTTPS main port
- `8067`: Metrics port
- `8074`: Cluster port
- `8075`: Gossip port

## Volumes

The container uses these volume mount points:
- `/mattermost/data`: User data and file uploads
- `/mattermost/logs`: Application logs
- `/mattermost/config`: Configuration files
- `/mattermost/plugins`: Plugin data
- `/mattermost/client/plugins`: Client-side plugins

## Health Check

The container includes a health check that runs every 30 seconds using the `mostlymatter version` command.

## Troubleshooting

### View logs
```bash
docker logs mostlymatter
```

### Access container shell
Since the image is based on distroless, there's no shell. For debugging, rebuild with a different base image or use `docker exec` with available binaries.

### Check version
```bash
docker run --rm mostlymatter:latest /mattermost/bin/mostlymatter version
```

## About Mostlymatter

Mostlymatter is a fork of Mattermost that removes user and message limits by multiplying the default limits by 1,000. The differences from standard Mattermost are:

- User limits: 5,000,000 and 11,000,000 (instead of 5,000 and 11,000)
- Message limits: Increased by 1,000x
- Binary renamed from `mattermost` to `mostlymatter`

For more information, see the main [README.md](README.md) and [MOSTLYMATTER_HOW_TO.md](MOSTLYMATTER_HOW_TO.md).
