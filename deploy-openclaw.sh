#!/bin/bash

set -e

echo "=========================================="
echo "OpenClaw + Ollama Low-Spec Deployment"
echo "=========================================="

PROJECT_DIR="$HOME/openclaw-stack"
MODEL="phi3:mini"

echo "Step 1: Installing Docker if not present..."

if ! command -v docker &> /dev/null
then
    sudo apt update
    sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
fi

echo "Step 2: Creating project directory..."
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

echo "Step 3: Creating docker-compose.yml..."

cat > docker-compose.yml <<EOF
version: '3.9'

networks:
  claw-net:
    driver: bridge

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

  openclaw:
    image: node:22-alpine
    container_name: openclaw
    restart: unless-stopped
    networks:
      - claw-net
    working_dir: /app
    command: >
      sh -c "
      npm install -g openclaw &&
      openclaw gateway
      "
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on:
      - ollama
EOF

echo "Step 4: Starting containers..."
docker compose up -d

echo "Step 5: Waiting for Ollama to initialize..."
sleep 10

echo "Step 6: Pulling model ($MODEL)..."
docker exec ollama ollama pull $MODEL

echo "=========================================="
echo "Deployment Complete"
echo "=========================================="
echo ""
echo "Containers running:"
docker ps

echo ""
echo "To onboard Telegram:"
echo "docker exec -it openclaw sh"
echo "Then run: openclaw onboard"
echo ""
echo "Model used: $MODEL"
echo ""
