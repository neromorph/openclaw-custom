# OpenClaw Custom Image

This repository builds a custom Docker image based on `ghcr.io/openclaw/openclaw:latest` and publishes it to Docker Hub as `neromorph/openclaw:latest`.

## What is included

The image extends OpenClaw with additional tools such as:

- SSH, rsync, wget, netcat, ping, dnsutils
- Python venv + pinned Python packages
- Docker CLI and Docker Compose plugin
- kubectl, doctl, tsh
- Bitwarden CLI

## Create a public GitHub repository

1. Go to `https://github.com/new`
2. Set repository name (for example: `openclaw`)
3. Set visibility to **Public**
4. Do not initialize with README/gitignore/license
5. Click **Create repository**

## Configure Docker Hub access

1. Open `https://hub.docker.com/`
2. Go to **Account Settings** -> **Security**
3. Create a new access token
4. Copy and store the token securely

## Configure GitHub Actions secrets

In your GitHub repo:

1. Go to **Settings** -> **Secrets and variables** -> **Actions**
2. Add secret `DOCKERHUB_USERNAME` with value `neromorph`
3. Add secret `DOCKERHUB_TOKEN` with your Docker Hub access token

## Push this repository

Run from this project directory:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/neromorph/openclaw.git
git push -u origin main
```

## GitHub Actions workflow behavior

Workflow file: `.github/workflows/docker-build-push.yml`

On every push to `main`, the workflow:

1. Checks out the repository
2. Sets up QEMU + Buildx for multi-arch builds
3. Logs into Docker Hub
4. Pulls `ghcr.io/openclaw/openclaw:latest` before build
5. Builds and pushes multi-platform image:
   - `linux/amd64`
   - `linux/arm64`
6. Pushes image tag `neromorph/openclaw:latest`

## Verify published image

After workflow success:

```bash
docker pull neromorph/openclaw:latest
docker run --rm -it neromorph/openclaw:latest bash
```
