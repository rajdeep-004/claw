Specification:

* Ubuntu (VM or VPS)
* 3 vCPU / 4GB RAM / 50GB SSD
* Docker deployment
* Ollama + OpenClaw in separate containers
* Telegram integration
* Low-memory optimized

---

# 🦞 OpenClaw + Ollama (Low-Spec Deployment)

Minimal, production-ready Docker deployment for running:

* **Ollama (Local LLM Server)**
* **OpenClaw (Agent Gateway)**
* Telegram integration
* Optimized for **4GB RAM environments**

Designed for:

* Local VM sandbox
* Budget VPS (₹500–₹1000/month)
* AI business automation experiments

---

# 📦 System Requirements

Minimum:

* Ubuntu 22.04 LTS
* 3 vCPU
* 4GB RAM
* 50GB SSD
* Internet access (for model pull + Telegram)

Recommended:

* 4GB swap enabled
* Private VPS with root access

---

# 🏗 Architecture

```
Host (Ubuntu)
│
├── Docker Network (claw-net)
│
├── ollama container
│     └── Model storage (persistent volume)
│
└── openclaw container
      └── Connects internally to ollama
      └── Telegram integration
```

Ollama is NOT exposed publicly.
OpenClaw communicates internally via Docker network.

---

# 🚀 Quick Deployment

## 1️⃣ Clone Repo

```bash
git clone <your-repo-url>
cd openclaw-stack
```

## 2️⃣ Run Deployment Script

```bash
chmod +x deploy-openclaw.sh
./deploy-openclaw.sh
```

This script will:

* Install Docker (if missing)
* Create docker-compose.yml
* Start containers
* Pull low-memory model (`phi3:mini`)
* Show container status

---

# 🧠 Default Model (Low Memory Safe)

```
phi3:mini
```

Why?

* ~2.2GB RAM usage
* Stable on 4GB machines
* Fast CPU inference
* Suitable for agent workflows

---

# 🔁 Changing Model (Optional)

Edit inside `deploy-openclaw.sh`:

```
MODEL="mistral:7b-instruct-q4_0"
```

⚠ Warning:
7B models may consume ~3.5GB RAM and cause swap usage on 4GB machines.

---

# 🐳 Manual Docker Control

Start containers:

```bash
docker compose up -d
```

Stop containers:

```bash
docker compose down
```

View logs:

```bash
docker logs ollama
docker logs openclaw
```

Check running services:

```bash
docker ps
```

---

# 📲 Telegram Setup

## Step 1 — Create Bot

1. Open Telegram
2. Search **@BotFather**
3. Run:

```
/newbot
```

4. Save the Bot API token

---

## Step 2 — Pair in OpenClaw

Enter container:

```bash
docker exec -it openclaw sh
```

Run:

```bash
openclaw onboard
```

* Choose Telegram
* Paste Bot Token
* Set model endpoint:

  ```
  http://ollama:11434
  ```

Exit container.

Now your bot runs 24×7.

---

# 🔐 Security Recommendations

On VPS:

```bash
sudo ufw allow 22
sudo ufw enable
```

Do NOT expose port 11434 publicly.

Keep Ollama internal only.

---

# 🧠 Memory Optimization

If machine becomes unstable, enable swap:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

Verify:

```bash
free -h
```

---

# 📊 Expected Resource Usage (4GB System)

| Component       | RAM Usage |
| --------------- | --------- |
| Ollama + phi3   | ~2.2GB    |
| OpenClaw        | ~300MB    |
| Ubuntu + Docker | ~800MB    |
| Free Headroom   | ~700MB    |

Stable under moderate load.

---

# 🔄 Auto Restart Behavior

Containers use:

```
restart: unless-stopped
```

If VPS reboots → services restart automatically.

---

# 🧩 Business Automation Workflow

Once deployed, use Telegram to send structured prompts like:

```
Generate 10 zero-cost online business ideas ranked by speed to first $10 profit.
```

Then:

```
Create 7-day execution plan for idea #1.
```

Then:

```
Generate outreach scripts and KPI tracking format.
```

Your AI agent runs continuously via Docker.

---

# 🛠 Troubleshooting

If model fails to load:

```bash
docker exec -it ollama ollama list
```

If empty, re-pull:

```bash
docker exec -it ollama ollama pull phi3:mini
```

If container crashes:

```bash
docker logs openclaw
```

---

# 📈 Scaling Path

If revenue grows:

1. Upgrade to 8GB RAM VPS
2. Switch to Mistral 7B
3. Add Nginx reverse proxy
4. Add HTTPS + webhook mode
5. Add logging + monitoring

---

# 🧠 Deployment Modes

You can use this setup as:

* Private AI assistant
* Multi-user Telegram bot
* Automated idea generation engine
* AI business experimentation sandbox

---

# 📌 Project Goals

* Zero upfront cost business experiments
* First $10 profit
* First $100 MRR
* Fully autonomous agent infrastructure

---
