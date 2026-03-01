#!/bin/bash

set -e

PROJECT_DIR="$HOME/openclaw-stack"

echo "=========================================="
echo "OpenClaw + Ollama Full Cleanup"
echo "=========================================="

echo ""
read -p "This will REMOVE containers, volumes, and models. Continue? (y/N): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    exit 0
fi

############################################
# 1️⃣ Stop Containers
############################################

if command -v docker &> /dev/null; then

    echo "Stopping containers..."
    docker stop openclaw 2>/dev/null || true
    docker stop ollama 2>/dev/null || true

    echo "Removing containers..."
    docker rm openclaw 2>/dev/null || true
    docker rm ollama 2>/dev/null || true

    ############################################
    # 2️⃣ Remove Volumes
    ############################################

    echo "Removing volumes..."
    docker volume rm openclaw-stack_ollama-data 2>/dev/null || true
    docker volume prune -f

    ############################################
    # 3️⃣ Remove Network
    ############################################

    docker network rm claw-net 2>/dev/null || true

    ############################################
    # 4️⃣ Remove Images
    ############################################

    echo "Removing related images..."

    docker image rm ollama/ollama:latest 2>/dev/null || true
    docker image rm ghcr.io/openclaw/openclaw:latest 2>/dev/null || true

    docker image prune -f

fi

############################################
# 5️⃣ Remove Project Directory
############################################

if [ -d "$PROJECT_DIR" ]; then
    echo "Removing project directory..."
    rm -rf "$PROJECT_DIR"
fi

############################################
# 6️⃣ Optional Swap Removal
############################################

read -p "Remove swapfile (if created)? (y/N): " swapconfirm

if [[ "$swapconfirm" == "y" ]]; then
    sudo swapoff /swapfile 2>/dev/null || true
    sudo rm -f /swapfile
    sudo sed -i '/\/swapfile/d' /etc/fstab
    echo "Swap removed."
fi

############################################
# 7️⃣ Optional Docker Removal
############################################

read -p "Completely uninstall Docker? (y/N): " dockerconfirm

if [[ "$dockerconfirm" == "y" ]]; then
    sudo apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo rm -rf /var/lib/docker
    echo "Docker removed."
fi

echo ""
echo "=========================================="
echo "Cleanup Complete"
echo "=========================================="
echo ""
docker ps || true
