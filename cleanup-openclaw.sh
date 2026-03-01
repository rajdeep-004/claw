#!/bin/bash

set -e

PROJECT_DIR="$HOME/openclaw-stack"

echo "=========================================="
echo "OpenClaw + Ollama COMPLETE REMOVAL"
echo "=========================================="
echo ""
echo "This will:"
echo "- Remove containers"
echo "- Remove volumes"
echo "- Remove images"
echo "- Remove networks"
echo "- Remove project directory"
echo "- Remove swap (if exists)"
echo "- UNINSTALL DOCKER COMPLETELY"
echo ""
read -p "Are you absolutely sure? (type YES to continue): " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "Aborted."
    exit 0
fi

############################################
# 1️⃣ Stop & Remove Containers
############################################

if command -v docker &> /dev/null; then
    echo "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true

    echo "Removing all containers..."
    docker rm -f $(docker ps -aq) 2>/dev/null || true

    ############################################
    # 2️⃣ Remove Volumes
    ############################################

    echo "Removing all volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null || true

    ############################################
    # 3️⃣ Remove Networks
    ############################################

    echo "Removing custom networks..."
    docker network rm $(docker network ls -q) 2>/dev/null || true

    ############################################
    # 4️⃣ Remove Images
    ############################################

    echo "Removing all images..."
    docker rmi -f $(docker images -aq) 2>/dev/null || true

    ############################################
    # 5️⃣ System Prune
    ############################################

    docker system prune -a -f --volumes || true
fi

############################################
# 6️⃣ Remove Project Directory
############################################

if [ -d "$PROJECT_DIR" ]; then
    echo "Removing project directory..."
    rm -rf "$PROJECT_DIR"
fi

############################################
# 7️⃣ Remove Swap (if exists)
############################################

if [ -f /swapfile ]; then
    echo "Removing swapfile..."
    sudo swapoff /swapfile || true
    sudo rm -f /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
fi

############################################
# 8️⃣ Uninstall Docker Completely
############################################

echo "Uninstalling Docker packages..."

sudo systemctl stop docker 2>/dev/null || true

sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io docker-compose podman-docker containerd runc || true

sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker.io docker-compose podman-docker containerd runc || true

############################################
# 9️⃣ Remove Docker Data
############################################

echo "Removing Docker data directories..."

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/apt/sources.list.d/docker.list
sudo rm -rf /etc/apt/keyrings/docker.gpg

############################################
# 🔟 Autoremove + Clean
############################################

sudo apt autoremove -y
sudo apt autoclean -y

echo ""
echo "=========================================="
echo "FULL CLEAN COMPLETE"
echo "=========================================="
echo ""
echo "Docker installed? Checking..."
if command -v docker &> /dev/null; then
    echo "WARNING: docker still present."
else
    echo "Docker fully removed."
fi
echo ""
