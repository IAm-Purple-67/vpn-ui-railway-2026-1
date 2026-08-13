# استفاده از ایمیج پایه اوبونتو 24.04
FROM ubuntu:24.04

# جلوگیری از توقف مراحل نصب به دلیل ورودی تعاملی
ENV DEBIAN_FRONTEND=noninteractive

# نصب وابستگی‌های سیستمی مورد نیاز برای کامپایل و اجرا
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

# نصب Go (نسخه 1.22.5 یا بالاتر)
RUN wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz && \
    rm go1.22.5.linux-amd64.tar.gz

# تنظیم متغیرهای محیطی Go
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# کلون کردن پروژه به‌صورت خودکار از گیت‌هاب
RUN git clone https://github.com/Sir-MmD/vpn-ui.git /app

# رفتن به پوشه پروژه
WORKDIR /app

# اجرای اسکریپت build.sh برای کامپایل پروژه
RUN ./build.sh

# ایجاد مسیر نصب و کپی فایل باینری
RUN mkdir -p /opt/vpn-ui && cp vpn-ui-amd64 /opt/vpn-ui/

# پورت پیش‌فرض پنل وب
EXPOSE 443

# متغیرهای محیطی
ENV PANEL_PORT=443
ENV PANEL_DB_PATH=/opt/vpn-ui/database.db

# اجرای اسکریپت نصب و راه‌اندازی پنل
CMD ["/bin/bash", "-c", "cd /opt/vpn-ui && ./deploy.sh --port ${PANEL_PORT} && tail -f /dev/null"]
