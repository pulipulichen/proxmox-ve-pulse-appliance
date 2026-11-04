#!/usr/bin/env bash
set -Eeuo pipefail
export DEBIAN_FRONTEND=noninteractive
[[ ${EUID} -eq 0 ]] || { echo "Run as root"; exit 1; }
. /etc/os-release
[[ "${ID}" == "debian" && "${VERSION_ID}" == "13" ]] || { echo "Debian 13 required"; exit 1; }
if systemd-detect-virt --container | grep -q lxc; then
  echo "LXC detected: ensure nesting=1,keyctl=1 in Proxmox CT configuration."
fi
apt-get update
apt-get install -y ca-certificates curl gnupg openssl python3 python3-bcrypt
if ! command -v docker >/dev/null || ! docker compose version >/dev/null 2>&1; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian %s stable\n' "$(dpkg --print-architecture)" "$VERSION_CODENAME" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
systemctl enable --now docker
docker info >/dev/null || { echo "Docker unavailable; check LXC nesting and host kernel"; exit 1; }
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR=/opt/pulse
install -d -m 0700 "$INSTALL_DIR" "$INSTALL_DIR/data"
if [[ "$SOURCE_DIR" != "$INSTALL_DIR" ]]; then
  cp "$SOURCE_DIR/docker-compose.yml" "$INSTALL_DIR/docker-compose.yml"
fi
cd "$INSTALL_DIR"
if [[ ! -f .env ]]; then
  printf 'PULSE_IMAGE=rcourtman/pulse:latest\nPULSE_PORT=80\nTZ=Asia/Taipei\n' > .env
  chmod 600 .env
fi
if [[ ! -f docker-auth.env ]]; then
  umask 077
  printf 'Pulse initial admin password (Enter to use the requested default): '
  IFS= read -rs password
  echo
  password="${password:-!QAZ2wsx}"
  export PULSE_INITIAL_PASSWORD="$password"
  python3 - <<'PY'
import bcrypt, os
password = os.environ["PULSE_INITIAL_PASSWORD"].encode()
hashed = bcrypt.hashpw(password, bcrypt.gensalt(rounds=12)).decode()
with open("docker-auth.env", "x") as f:
    f.write("PULSE_AUTH_USER=admin\nPULSE_AUTH_PASS=" + hashed + "\n")
os.chmod("docker-auth.env", 0o600)
PY
  unset PULSE_INITIAL_PASSWORD password
fi
docker compose up -d
ip="$(hostname -I | awk '{print $1}')"
echo "Pulse: http://${ip:-CT-IP}/ (admin)"
docker compose ps
