#!/bin/bash

set -euo pipefail
IMAGE="ghcr.io/hasanashab/spring-react-devops-frontend"
TAG="latest"
CONTAINER_NAME="frontend-app"

echo "🔧 Updating package list..."
apt-get update -y

echo "📦 Installing Docker dependencies..."
apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

echo "🔑 Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

echo "📝 Adding Docker APT repository..."
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable"

echo "📦 Installing Docker Engine..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "🚀 Enabling and starting Docker service..."
systemctl enable docker
systemctl start docker

echo "📥 Pulling image: ${IMAGE}:${TAG}..."
docker pull "${IMAGE}:${TAG}"

echo "🧹 Cleaning up any existing container named ${CONTAINER_NAME}..."
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "🏃 Running container..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p 80:80 \
  "${IMAGE}:${TAG}"

echo "✅ Deployment completed successfully."
