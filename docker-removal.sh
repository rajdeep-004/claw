echo "Force removing all Docker components..."

sudo systemctl stop docker 2>/dev/null || true
sudo systemctl stop containerd 2>/dev/null || true

sudo apt purge -y \
  docker-ce \
  docker-ce-cli \
  docker-ce-rootless-extras \
  docker-buildx-plugin \
  docker-compose-plugin \
  docker.io \
  docker-doc \
  docker-compose \
  podman-docker \
  containerd \
  containerd.io \
  runc || true

sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf /etc/apt/sources.list.d/docker.list
sudo rm -rf /etc/apt/keyrings/docker.gpg

sudo apt autoremove -y
sudo apt autoclean -y
