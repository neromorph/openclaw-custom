# AGENTS.md

## Repo Scope
- This repo builds a custom OpenClaw Docker image. The root `Dockerfile` is the main artifact.

## Files That Matter
- `Dockerfile`: image contents and all pinned component versions.
- `.github/workflows/docker-build-push.yml`: publish pipeline and pushed image tags.
- `README.md`: secondary reference; trust workflow/config over prose if they diverge.

## Publish Flow
- Any push to `main` triggers the GitHub Actions workflow that builds and pushes `neromorph/openclaw:latest`.
- The workflow builds for `linux/amd64` and `linux/arm64`.

## Version Bumps
- Resolve versions from the source that actually installs them.
- Keep exact pins in `Dockerfile`; this repo uses explicit version pinning throughout.

### How to check latest versions

| Component | How to get latest version |
|---|---|
| Debian packages (openssh-client, rsync, wget, etc.) | `apt-cache policy <package>` or check [Debian bookworm repos](https://packages.debian.org/bookworm/) |
| Docker CLI (`docker-ce-cli`, `docker-compose-plugin`) | `apt-cache policy docker-ce-cli` after adding Docker repo, or check [Docker Debian repo](https://download.docker.com/linux/debian/dists/bookworm/stable/binary-amd64/Packages) |
| Python packages (`requests`, `beautifulsoup4`, `pandas`, `pyyaml`, `python-telegram-bot`) | `pip index versions <package>` or `curl -s https://pypi.org/pypi/<package>/json | jq -r '.info.version'` |
| `s3cmd` | `curl -s https://pypi.org/pypi/s3cmd/json | jq -r '.info.version'` |
| `@bitwarden/cli` | `npm view @bitwarden/cli version` |
| `kubectl` | `curl -sL https://dl.k8s.io/release/stable.txt` |
| `doctl` | `curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | jq -r '.tag_name'` |
| `tsh` (Teleport) | Check [Teleport releases](https://github.com/gravitational/teleport/releases) — version is manually pinned |
| Base image (`ghcr.io/openclaw/openclaw`) | Check [OpenClaw GHCR packages](https://github.com/openclaw/openclaw/pkgs/container/openclaw) |

## Verification
- There are no repo-native tests or package scripts.
- The meaningful verification step is building the root `Dockerfile`.

## Gotchas
- The base image is intentionally `ghcr.io/openclaw/openclaw:latest`.
- Be careful with direct pushes after `Dockerfile` changes, because `main` publishes immediately.
