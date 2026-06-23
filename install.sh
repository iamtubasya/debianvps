#!/bin/sh

############################################################
#                                                          #
#                ImGunpoint PROOT SYSTEM                  #
#                 Debian 13 Trixie VM                     #
#                                                          #
#            Fast • Stable • Optimized • Modern           #
#                                                          #
#                Author : IAMTUBASYA                      #
############################################################

############################
# ROOTFS DIRECTORY
############################
ROOTFS_DIR="$(pwd)"

export PATH="$PATH:$HOME/.local/usr/bin"

############################
# SETTINGS
############################
MAX_RETRIES=50
TIMEOUT=10

############################
# COLORS
############################
RESET='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'

############################
# ARCH DETECTION
############################
ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        ARCH_ALT="amd64"
        ;;
    aarch64|arm64)
        ARCH_ALT="arm64"
        ;;
    *)
        echo -e "${RED}[ERROR] Unsupported architecture: $ARCH${RESET}"
        exit 1
        ;;
esac

############################
# ASCII LOGO
############################
show_logo() {
clear

echo -e "${MAGENTA}"

cat << "EOF"

   ██████╗  ██╗  ██╗  ██╗  ██████╗   ███████╗  ██████╗
  ██╔════╝  ██║  ██║  ██║  ██╔══██╗  ██╔════╝  ██╔══██╗
  ██║       ███████║  ██║  ██████╔╝  █████╗    ██████╔╝
  ██║       ██╔══██║  ██║  ██╔═══╝   ██╔══╝    ██╔══██╗
  ╚██████╗  ██║  ██║  ██║  ██║       ███████╗  ██║  ██║
   ╚═════╝  ╚═╝  ╚═╝  ╚═╝  ╚═╝       ╚══════╝  ╚═╝  ╚═╝
  █████╗██╗   ██╗  ██╗██╗  ██╗ • AUTHOR  : I'M TUBASYA
  ██╔══╝██║   ██║  ██║╚██╗██╔╝
  ████╗ ██║   ██║  ██║ ╚███╔╝  • TWITTER : @ChiperFlux
  ██╔═╝ ██║   ██║  ██║ ██╔██╗
  ██║   █████╗╚█████╔╝██╔╝ ██╗ • TELE ID : @Chiper_Flux
  ╚═╝   ╚════╝ ╚════╝ ╚═╝  ╚═╝
EOF

echo -e "${RESET}"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}        Debian 13 Trixie Proot VM${RESET}"
echo -e "${YELLOW}           Powered By ImGunpoint${RESET}"
echo -e "${MAGENTA}           Author : IAMTUBASYA${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

}

############################
# INSTALL DEPENDENCIES
############################
install_dependencies() {

echo -e "${CYAN}[*] Checking dependencies...${RESET}"

if ! command -v wget >/dev/null 2>&1; then
    echo -e "${YELLOW}[*] Installing required packages...${RESET}"

    if command -v apt >/dev/null 2>&1; then
        apt update -y
        apt install wget curl tar xz-utils proot git -y

    elif command -v apk >/dev/null 2>&1; then
        apk add wget curl tar xz proot git

    elif command -v yum >/dev/null 2>&1; then
        yum install wget curl tar xz proot git -y

    else
        echo -e "${RED}[ERROR] Unsupported package manager.${RESET}"
        exit 1
    fi
fi

}

############################
# INSTALL DEBIAN ROOTFS
############################
install_debian() {

DEBIAN_URL="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-${ARCH_ALT}/trixie/rootfs.tar.xz"

echo -e "${CYAN}[*] Downloading Debian 13 RootFS...${RESET}"

wget \
    --tries="$MAX_RETRIES" \
    --timeout="$TIMEOUT" \
    --show-progress \
    --no-hsts \
    -O /tmp/rootfs.tar.xz \
    "$DEBIAN_URL"

if [ ! -f /tmp/rootfs.tar.xz ]; then
    echo -e "${RED}[ERROR] Failed to download Debian RootFS.${RESET}"
    exit 1
fi

echo -e "${GREEN}[*] Extracting Debian filesystem...${RESET}"

tar -xpf /tmp/rootfs.tar.xz -C "$ROOTFS_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Extraction failed.${RESET}"
    exit 1
fi

rm -f /tmp/rootfs.tar.xz

}

############################
# DOWNLOAD PROOT
############################
download_proot() {

mkdir -p "$ROOTFS_DIR/usr/local/bin"

echo -e "${CYAN}[*] Downloading PRoot binary...${RESET}"

wget \
    --tries="$MAX_RETRIES" \
    --timeout="$TIMEOUT" \
    --show-progress \
    --no-hsts \
    -O "$ROOTFS_DIR/usr/local/bin/proot" \
    "https://proot.gitlab.io/proot/bin/proot"

chmod +x "$ROOTFS_DIR/usr/local/bin/proot"

}

############################
# CONFIGURE SYSTEM
############################
configure_system() {

echo -e "${CYAN}[*] Configuring Debian environment...${RESET}"

echo "nameserver 1.1.1.1" > "$ROOTFS_DIR/etc/resolv.conf"
echo "nameserver 8.8.8.8" >> "$ROOTFS_DIR/etc/resolv.conf"

cat > "$ROOTFS_DIR/root/setup.sh" << 'EOF'
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update -y

apt install -y \
    sudo \
    curl \
    wget \
    nano \
    vim \
    git \
    htop \
    neofetch \
    net-tools \
    openssh-server \
    ca-certificates \
    zip \
    unzip \
    screen \
    tmux \
    python3 \
    python3-pip

echo "root:root" | chpasswd

mkdir -p /run/sshd

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

clear

echo "======================================"
echo "     DEBIAN 13 TRIXIE READY"
echo "     AUTHOR : IAMTUBASYA"
echo "======================================"

neofetch

EOF

chmod +x "$ROOTFS_DIR/root/setup.sh"

touch "$ROOTFS_DIR/.installed"

}

############################
# SYSTEM INFO
############################
show_system_info() {

RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
CPU_MODEL=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^[ \t]*//')
CPU_CORES=$(nproc)
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
IP_ADDRESS=$(hostname -I 2>/dev/null | awk '{print $1}')
HOST_NAME=$(hostname)
KERNEL_VER=$(uname -r)

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}SYSTEM INFO${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${YELLOW}OS:${RESET} Debian 13 (Trixie)"
echo -e "${YELLOW}Arch:${RESET} $ARCH"
echo -e "${YELLOW}Kernel:${RESET} $KERNEL_VER"
echo -e "${YELLOW}Hostname:${RESET} $HOST_NAME"
echo -e "${YELLOW}CPU:${RESET} $CPU_MODEL ($CPU_CORES cores)"
echo -e "${YELLOW}RAM:${RESET} ${RAM_TOTAL} MB"
echo -e "${YELLOW}Disk:${RESET} $DISK_TOTAL"
echo -e "${YELLOW}IP:${RESET} ${IP_ADDRESS:-Not Available}"
echo ""

echo -e "${MAGENTA}Author : IAMTUBASYA${RESET}"
echo ""

}

############################
# MAIN
############################
show_logo
install_dependencies

if [ ! -f "$ROOTFS_DIR/.installed" ]; then
    echo -e "${YELLOW}[*] First launch detected.${RESET}"

    install_debian
    download_proot
    configure_system

    echo -e "${GREEN}[*] Debian installation completed successfully.${RESET}"
fi

show_system_info

############################
# START PROOT
############################
exec "$ROOTFS_DIR/usr/local/bin/proot" \
    --rootfs="$ROOTFS_DIR" \
    -0 \
    -w /root \
    -b /dev \
    -b /sys \
    -b /proc \
    -b /tmp \
    -b /etc/resolv.conf \
    --kill-on-exit \
    /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/bash --login
