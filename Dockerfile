FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV SKIP_BACKEND=1

RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libsystemd-dev \
    iptables \
    nftables \
    wireguard-tools \
    iproute2 \
    strongswan \
    libstrongswan-extra-plugins \
    xl2tpd \
    openvpn \
    ocserv \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz && \
    rm go1.22.5.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

RUN git clone https://github.com/Sir-MmD/vpn-ui.git /app

WORKDIR /app

RUN ./build.sh

RUN mkdir -p /opt/vpn-ui && cp vpn-ui-amd64 /opt/vpn-ui/

EXPOSE 443

ENV PANEL_PORT=443
ENV PANEL_DB_PATH=/opt/vpn-ui/database.db

CMD ["/bin/bash", "-c", "cd /opt/vpn-ui && ./deploy.sh --port ${PANEL_PORT} && tail -f /dev/null"]
