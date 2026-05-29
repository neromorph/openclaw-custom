FROM ghcr.io/openclaw/openclaw:2026.5.27-slim

USER root

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-client \
    rsync \
    wget \
    netcat-openbsd \
    iputils-ping \
    dnsutils \
    python3-pip \
    python3-venv \
    build-essential \
    postgresql-client \
    sqlite3 \
    unzip \
    jq \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/openclaw-venv && \
    /opt/openclaw-venv/bin/pip install --no-cache-dir --upgrade pip && \
    /opt/openclaw-venv/bin/pip install --no-cache-dir \
      requests \
      beautifulsoup4 \
      pandas \
      pyyaml \
      python-telegram-bot

ENV PATH="/opt/openclaw-venv/bin:${PATH}"

RUN npm install -g @bitwarden/cli

RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /tmp/docker.asc && \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg /tmp/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    . /etc/os-release && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker-ce-cli \
      docker-compose-plugin \
    && rm -f /tmp/docker.asc && \
    rm -rf /var/lib/apt/lists/*

# Install latest kubectl
RUN KUBECTL_ARCH=$(dpkg --print-architecture) && \
    KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt) && \
    curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install latest doctl
RUN DOCTL_ARCH=$(dpkg --print-architecture) && \
    DOCTL_VERSION=$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | jq -r .tag_name | sed 's/^v//') && \
    curl -fsSL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-${DOCTL_ARCH}.tar.gz" -o /tmp/doctl.tar.gz && \
    tar -xzf /tmp/doctl.tar.gz -C /usr/local/bin doctl && \
    rm /tmp/doctl.tar.gz

# Install pinned tsh (Teleport CLI)
RUN TSH_ARCH=$(dpkg --print-architecture) && \
    TSH_VERSION="v16.5.18" && \
    curl -fsSL "https://cdn.teleport.dev/teleport-${TSH_VERSION}-linux-${TSH_ARCH}-bin.tar.gz" -o /tmp/teleport.tar.gz && \
    tar -xzf /tmp/teleport.tar.gz -C /tmp teleport/tsh && \
    mv /tmp/teleport/tsh /usr/local/bin/tsh && \
    chmod +x /usr/local/bin/tsh && \
    rm -rf /tmp/teleport /tmp/teleport.tar.gz

USER node

RUN install -d -m 0755 -o node -g node /home/node/.openclaw/workspace

WORKDIR /app
