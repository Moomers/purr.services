# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository manages self-hosted web services on `purr.services` using Docker Compose.
It includes 23+ services with Traefik reverse proxy, PostgreSQL database, and various web applications.
The repo itself is usually modified on the author's laptop, while the services run on a different machine (purr).

## Key Commands

### Service Management
```bash
# Reload services after changes (pulls latest changes and restarts)
just reload

# View logs for all services or specific service
just logs          # all services
just logs traefik  # specific service

# Restart specific service
just restart <service-name>

# List all available just commands
just list
```

### Secrets Management

The repository uses DCSM (Docker Compose Secrets Manager) with encrypted secrets:

```bash
# Process all config templates using encrypted secrets
just dcsm

# Encrypt secrets.yaml into secrets.encrypted
just encrypt

# Decrypt secrets.encrypted into secrets.yaml  
just decrypt
```

### Database Initialization

Initialize PostgreSQL databases for services:
```bash
# Initialize all databases
just postgres-init

# Or initialize individual databases via docker exec
docker compose exec -it postgres.purr /init_scripts/<service>_db.sh
```

### Docker Compose Operations
```bash
# Standard docker compose commands
docker compose up --wait --detach --remove-orphans
docker compose ps
docker compose logs -f <service>
```

## Architecture

### Directory Structure
- `compose.yml` - Main Docker Compose configuration with all services
- `config/` - Service-specific configuration files (many are templates processed by DCSM)
- `secrets/` - Contains encrypted secrets and key file
- `init_scripts/` - PostgreSQL database initialization scripts (templates)
- `storage/` - Symlink to persistent data storage (../../test/purr.services.storage)
- `justfile` - Task runner with common commands

### Network Configuration
- Custom bridge network: 172.20.0.0/16
- Gateway: 172.20.1.1
- Named bridge: "purrsrv"

### Service Architecture
- **Traefik** - Reverse proxy handling SSL/TLS with Let's Encrypt and Cloudflare DNS
- **PostgreSQL** - Shared database for multiple services
- **Redis** - Caching and session storage
- **DCSM** - Secrets management and template processing

Services expose themselves via Traefik labels with routing rules based on hostnames (e.g., `auth.moomers.org`, `traefik.moomers.org`).

### Template Processing
Configuration files ending in `.template` are processed by DCSM:
1. DCSM reads encrypted secrets from `secrets/secrets.encrypted`
2. Processes templates in `config/` and `init_scripts/`
3. Generates actual config files without `.template` extension

### Service Dependencies
Most services depend on:
- `dcsm.purr` completing successfully (for config generation)
- `postgres.purr` or `redis.purr` being healthy
- Network connectivity through Traefik

## Important Notes

- The repository is designed to be cloned to `/root/purr.services` (path is hardcoded)
- Storage directory must be properly symlinked before starting services
- Use `just mkdirs` to create required storage directories with correct permissions
- Traefik handles SSL certificates via Let's Encrypt (HTTP challenge) or Cloudflare DNS
- Services are labeled with `cluster.name: purr.services` for Traefik discovery
