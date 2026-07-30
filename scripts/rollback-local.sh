#!/usr/bin/env bash

set -euo pipefail

PREVIOUS_TAG="${1:?Usage : ./scripts/rollback-local.sh <tag>}"
IMAGE_NAME="leex-api"
CONTAINER_NAME="leex-api"
HOST_PORT="${HOST_PORT:-8002}"
CONTAINER_PORT="8000"

echo "Vérification de l'image ${IMAGE_NAME}:${PREVIOUS_TAG}"

if ! docker image inspect "${IMAGE_NAME}:${PREVIOUS_TAG}" >/dev/null 2>&1; then
  echo "Erreur : image ${IMAGE_NAME}:${PREVIOUS_TAG} introuvable."
  echo "Images disponibles :"
  docker images "${IMAGE_NAME}"
  exit 1
fi

echo "Suppression du conteneur actuel"
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

echo "Démarrage de ${IMAGE_NAME}:${PREVIOUS_TAG}"
docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  --publish "127.0.0.1:${HOST_PORT}:${CONTAINER_PORT}" \
  "${IMAGE_NAME}:${PREVIOUS_TAG}"

echo "Vérification de la route /health"

for attempt in $(seq 1 10); do
  echo "Tentative ${attempt}/10"

  if curl \
    --fail \
    --silent \
    --show-error \
    "http://127.0.0.1:${HOST_PORT}/health"
  then
    echo
    echo "Rollback vers ${PREVIOUS_TAG} réussi."
    docker ps --filter "name=${CONTAINER_NAME}"
    exit 0
  fi

  sleep 3
done

echo "Échec du rollback."
docker logs "${CONTAINER_NAME}"
exit 1
