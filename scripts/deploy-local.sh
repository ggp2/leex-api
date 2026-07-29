#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="leex-api"
IMAGE_TAG="${1:-latest}"
CONTAINER_NAME="leex-api"
HOST_PORT="${HOST_PORT:-8002}"
CONTAINER_PORT="8000"

echo "Construction de ${IMAGE_NAME}:${IMAGE_TAG}"
docker build \
  --pull \
  --tag "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

echo "Suppression de l'ancien conteneur"
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Démarrage du nouveau conteneur"
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  --publish "127.0.0.1:${HOST_PORT}:${CONTAINER_PORT}" \
  "${IMAGE_NAME}:${IMAGE_TAG}"

echo "Contrôle de santé"
for attempt in $(seq 1 10); do
  if curl \
    --fail \
    --silent \
    --show-error \
    "http://127.0.0.1:${HOST_PORT}/health"
  then
    echo
    echo "Déploiement réussi."
    docker ps --filter "name=${CONTAINER_NAME}"
    exit 0
  fi

  echo "Tentative ${attempt}/10"
  sleep 3
done

echo "Échec du déploiement."
docker logs "${CONTAINER_NAME}"
exit 1
