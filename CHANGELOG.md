# Changelog

## 2026-11-05
- **Fix:** Preserve bcrypt authentication hashes using Docker Compose `env_file.format: raw` (requires Compose v2.30+). The prior Compose file interpolated a portion of the hash, so valid admin passwords were rejected.
- Validate the Docker Compose configuration in `start.sh` before starting Pulse.
- Document recovery steps, login lockouts, and runtime validation performed on the Debian 13 CT 105 deployment.
- Changed the interactive installer's default Pulse admin password to `!QAZ2wsx` (previously `1QAZ2wsx`).
- Updated README documentation and validated deployment procedure for a clean Debian 13 CT rebuild.

## 2026-11-04
- Initial Debian 13 LXC Docker Compose installer.
- Host port 80, persistent data, automatic service restart.
- Bootstrap-token wizard bypass through private bcrypt-hashed deployment credentials.
- Manual Pulse image update script.
- No automatic PVE registration.
