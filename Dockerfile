FROM ghcr.io/openclaw/openclaw:2026.5.27-slim

USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-client=1:9.2p1-2+deb12u10 \
    rsync=3.2.7-1+deb12u5 \
    wget=1.21.3-1+deb12u1 \
    netcat-openbsd=1.219-1 \
    iputils-ping=3:20221126-1+deb12u1 \
    dnsutils=1:9.18.49-1~deb12u1 \
    python3-pip=23.0.1+dfsg-1 \
    python3-venv=3.11.2-1+b1 \
    build-essential=12.9 \
    postgresql-client=15+248+deb12u1 \
    sqlite3=3.40.1-2+deb12u2 \
    unzip=6.0-28 \
    jq=1.6-2.1+deb12u1 \
    gnupg=2.2.40-1.1+deb12u2 \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/openclaw-venv && \
    /opt/openclaw-venv/bin/pip install --no-cache-dir --upgrade pip==26.1.1 && \
    /opt/openclaw-venv/bin/pip install --no-cache-dir \
      requests==2.34.2 \
      beautifulsoup4==4.14.3 \
      pandas==3.0.3 \
      pyyaml==6.0.3 \
      python-telegram-bot==22.7

ENV PATH="/opt/openclaw-venv/bin:${PATH}"

RUN npm install -g @bitwarden/cli@2026.4.2

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /tmp/docker.asc && \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    . /etc/os-release && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker-ce-cli=5:29.5.2-1~debian.12~bookworm \
      docker-compose-plugin=5.1.4-1~debian.12~bookworm \
    && rm -f /tmp/docker.asc && \
    rm -rf /var/lib/apt/lists/*

# Install pinned kubectl
RUN KUBECTL_ARCH=$(dpkg --print-architecture) && \
    KUBECTL_VERSION="v1.36.1" && \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install pinned doctl
RUN DOCTL_ARCH=$(dpkg --print-architecture) && \
    DOCTL_VERSION="1.159.0" && \
    curl -fsSL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${DOCTL_ARCH}.tar.gz" -o /tmp/doctl.tar.gz && \
    tar -xzf /tmp/doctl.tar.gz -C /usr/local/bin doctl && \
    rm /tmp/doctl.tar.gz

# Install pinned tsh (Teleport CLI)
RUN TSH_ARCH=$(dpkg --print-architecture) && \
    TSH_VERSION="v18.8.2" && \
    curl -fsSL "https://cdn.teleport.dev/teleport-${TSH_VERSION}-linux-${TSH_ARCH}-bin.tar.gz" -o /tmp/teleport.tar.gz && \
    tar -xzf /tmp/teleport.tar.gz -C /tmp teleport/tsh && \
    mv /tmp/teleport/tsh /usr/local/bin/tsh && \
    chmod +x /usr/local/bin/tsh && \
    rm -rf /tmp/teleport /tmp/teleport.tar.gz

USER node

RUN install -d -m 0755 -o node -g node /home/node/.openclaw/workspace

WORKDIR /app
