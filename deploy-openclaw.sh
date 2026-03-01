#!/bin/bash

set -e

echo "=========================================="
echo "OpenClaw + Ollama Low-Spec Deployment"
echo "=========================================="

PROJECT_DIR="$HOME/openclaw-stack"
MODEL="phi3:mini"

############################################
# 1️⃣ Install Modern Docker (Official Repo)
############################################

if ! command -v docker &> /dev/null
then
    echo "Installing official Docker..."

    sudo apt update
    sudo apt install -y ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo usermod -aG docker $USER

    echo "Docker installed. Please log out and back in if permission denied."
fi

############################################
# 2️⃣ Low RAM Protection (Auto Swap)
############################################

TOTAL_RAM=$(free -m | awk '/Mem:/ {print $2}')

if [ "$TOTAL_RAM" -lt 3800 ]; then
    if [ ! -f /swapfile ]; then
        echo "Creating 4GB swap for stability..."
        sudo fallocate -l 4G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
    fi
fi

############################################
# 3️⃣ Create Project Directory
############################################

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

############################################
# 4️⃣ Create docker-compose.yml
############################################

cat > docker-compose.yml <<EOF
version: '3.9'

networks:
  claw-net:
    driver: bridge
    internal: true

volumes:
  ollama-data:

services:

  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    networks:
      - claw-net
    volumes:
      - ollama-data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
    mem_limit: 3g

  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    networks:
      - claw-net
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on:
      - ollama
EOF

############################################
# 5️⃣ Start Containers
############################################

echo "Starting containers..."
docker compose up -d

############################################
# 6️⃣ Wait for Ollama
############################################

echo "Waiting for Ollama to initialize..."
sleep 15

############################################
# 7️⃣ Pull Model
############################################

if ! docker exec ollama ollama list | grep -q "$MODEL"; then
    echo "Pulling model: $MODEL"
    docker exec ollama ollama pull $MODEL
fi

############################################
# 8️⃣ Final Status
############################################

echo ""
echo "=========================================="
echo "Deployment Complete"
echo "=========================================="
docker ps

echo ""
echo "Model used: $MODEL"
echo ""
echo "To onboard Telegram:"
echo "docker exec -it openclaw sh"
echo "Then run: openclaw onboard"
echo ""
