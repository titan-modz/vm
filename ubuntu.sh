#!/bin/bash
set -euo pipefail

# =============================
# Ubuntu Auto Setup (Azimeee)
# =============================

clear
cat << "EOF"
==============================================================
  _______    _______     __    __    __    _______    _______
|  ___  |  |_____  |   |  |  |   \/   |  |  _____|  |  _____|
| |___| |       /  /   |  |  |  \  /  |  | |____    | |____
| |___| |     /  /     |  |  |  |\/|  |  |  ____|   |  ____|
| |   | |   /  /____   |  |  |  |  |  |  | |_____   | |_____
|_|   |_|  |________|  |__|  |__|  |__|  |_______|  |_______|
                                   
              POWERED BY AZIMEEE            
==============================================================
EOF

# =============================
# Root Check
# =============================
if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Please run this script as root (sudo su)."
    exit 1
fi

# =============================
# Essentials Installation
# =============================
echo "[INFO] Updating system..."
apt update -y && apt upgrade -y

echo "[INFO] Installing essentials..."
apt install -y \
    curl wget git vim htop unzip zip \
    software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# =============================
# Docker Installation
# =============================
echo "[INFO] Installing Docker..."

if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
else
    echo "[INFO] Docker already installed."
fi

systemctl enable docker
systemctl start docker

# =============================
# Docker Compose Installation
# =============================
echo "[INFO] Installing Docker Compose..."

if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
else
    echo "[INFO] Docker Compose already installed."
fi

# =============================
# Create Non-root User (gg)
# =============================
echo "[INFO] Creating user 'gg'..."
id -u gg &>/dev/null || useradd -m -s /bin/bash gg

# =============================
# Pull & Run Ubuntu Container
# =============================
echo "[INFO] Pulling Ubuntu image..."
docker pull ubuntu:22.04

echo "[INFO] Launching Ubuntu shell as gg@azimee..."
exec docker run -it --rm --hostname azimee ubuntu:22.04 /bin/bash -c "
    apt update -y >/dev/null 2>&1 && apt install -y sudo >/dev/null 2>&1
    useradd -m -s /bin/bash gg
    echo 'gg ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    su - gg
"
