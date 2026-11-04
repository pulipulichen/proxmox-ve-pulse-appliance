# Proxmox VE Pulse Appliance

Debian 13 LXC appliance deploying [Pulse](https://github.com/rcourtman/Pulse) with Docker Compose.

## Prerequisites

Create a Debian 13 CT with network access. Enable **nesting** (and **keyctl** when supported) in Proxmox LXC options. Ensure Docker is supported by the host and CT configuration. Allocate enough storage for Docker images and monitoring history.

## Install

```bash
git clone https://github.com/pulipulichen/proxmox-ve-pulse-appliance.git
cd proxmox-ve-pulse-appliance
./start.sh
```

Runs as root. Installs Docker if needed, stores Compose and persistent data under `/opt/pulse`, and starts Pulse automatically. Access **http://CT-IP/** on port **80**. Username: **admin**.

First-run bootstrap token setup is skipped using Pulse's documented `PULSE_AUTH_USER` and `PULSE_AUTH_PASS` environment variables. The installer prompts for a password; pressing Enter uses the temporary default `!QAZ2wsx` (username: `admin`). **Change this password before exposing the service to any untrusted network.** A bcrypt hash is saved in `/opt/pulse/docker-auth.env` with restrictive permissions; Docker administrators can still read the hash. This managed password overrides Pulse's password-change UI; to rotate it, regenerate the bcrypt hash in the private file and recreate the container. Never commit credentials.

The installer does **not** connect Pulse to Proxmox VE. The Pulse UI remains available for future configuration.

### Authentication and Compose compatibility

**Requires Docker Compose v2.30.0 or newer.** A bcrypt hash contains literal `# Proxmox VE Pulse Appliance

Debian 13 LXC appliance deploying [Pulse](https://github.com/rcourtman/Pulse) with Docker Compose.

## Prerequisites

Create a Debian 13 CT with network access. Enable **nesting** (and **keyctl** when supported) in Proxmox LXC options. Ensure Docker is supported by the host and CT configuration. Allocate enough storage for Docker images and monitoring history.

## Install

```bash
git clone https://github.com/pulipulichen/proxmox-ve-pulse-appliance.git
cd proxmox-ve-pulse-appliance
./start.sh
```

Runs as root. Installs Docker if needed, stores Compose and persistent data under `/opt/pulse`, and starts Pulse automatically. Access **http://CT-IP/** on port **80**. Username: **admin**.

First-run bootstrap token setup is skipped using Pulse's documented `PULSE_AUTH_USER` and `PULSE_AUTH_PASS` environment variables. The installer prompts for a password; pressing Enter uses the temporary default `!QAZ2wsx` (username: `admin`). **Change this password before exposing the service to any untrusted network.** A bcrypt hash is saved in `/opt/pulse/docker-auth.env` with restrictive permissions; Docker administrators can still read the hash. This managed password overrides Pulse's password-change UI; to rotate it, regenerate the bcrypt hash in the private file and recreate the container. Never commit credentials.

 characters. Compose normally interpolates unquoted values in `env_file`, which can silently corrupt the hash and make every login fail even if the original credential file is correct. This project's `docker-compose.yml` uses `env_file: {path: /opt/pulse/docker-auth.env, format: raw}` to preserve the exact 60-character hash. The installer validates the Compose configuration before startup.

If you installed the older version and cannot log in, update your checkout, replace `/opt/pulse/docker-compose.yml` with the new file, and recreate only the Pulse container (preserving `/opt/pulse/data`):

```bash
cd /root/proxmox-ve-pulse-appliance
git pull --ff-only
cp docker-compose.yml /opt/pulse/docker-compose.yml
cd /opt/pulse
docker compose config --quiet
docker compose up -d --no-deps --force-recreate pulse
```

For installations that already have failed login attempts, Pulse may lock the username or client IP for 15 minutes. Wait for the lockout window to end before retrying. Do not delete persistent data or clear authentication files to recover from the interpolation bug.

## Update

```bash
./update-pulse.sh
```

Pulls the configured image and recreates only Pulse, retaining `/opt/pulse/data`. By default the image tag is `latest`; override `PULSE_IMAGE` in `/opt/pulse/.env` to pin a release. Back up `/opt/pulse` before upgrading. The update script does not replace the Compose file itself.

## Notes

The public HTTP listener is **not encrypted**. Restrict access to a trusted LAN or put a TLS reverse proxy in front before remote exposure. Host port 80 maps to container port 7655. No host Docker socket is mounted. Validated on a Debian 13 LXC CT on Proxmox VE 9.2.4 (2026-11-04); installations may still vary by host configuration.
