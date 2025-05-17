#!/bin/bash

# --- Configuration ---
STUDENT_NAME="themillion"
VERSION="v1.0.${BUILD_NUMBER}"
IMAGE_NAME="${STUDENT_NAME}estate"
REGISTRY_NAME="larryawesome"
FULL_IMAGE_URI="${REGISTRY_NAME}/${IMAGE_NAME}:${VERSION}"
HOST_PORT="8392"
APP_PORT="8000"

# --- Initial Setup ---
docker --version
ls -lhtra

# --- Cleanup ---
docker ps -aqf "name=${STUDENT_NAME}" | xargs --no-run-if-empty docker rm -f || true
docker rmi -f ${FULL_IMAGE_URI} 2>/dev/null || true
docker rmi -f ${IMAGE_NAME}:${VERSION} 2>/dev/null || true

# --- Build Stage with Buildx ---
docker buildx create --use
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --no-cache \
  -t ${IMAGE_NAME}:${VERSION} \
  -t ${FULL_IMAGE_URI} \
  --push .

# --- Image Verification ---
echo "--------------- Image Verification ----------"
docker images | grep ${IMAGE_NAME}
docker images --filter="reference=${IMAGE_NAME}"

# --- Test Stage ---
echo "--------------- Test Deployment ----------"
docker run --name ${STUDENT_NAME} -d \
  -p ${HOST_PORT}:${APP_PORT} \
  --memory="800m" \
  --cpus="1.0" \
  ${FULL_IMAGE_URI}
  
sleep 10
docker ps --filter "name=${STUDENT_NAME}"
docker logs ${STUDENT_NAME}

# --- Release Validation ---
echo "--------------- Smoke Test ----------"
curl -sSf http://localhost:${HOST_PORT}/health-check || {
  echo "Application health check failed"
  exit 1
}

# --- Final Cleanup ---
echo "---------------Final Cleanup-----------------"
docker stop ${STUDENT_NAME} || true
docker rm -f ${STUDENT_NAME} || true

echo "--------------- Push Verification ----------"
docker pull ${FULL_IMAGE_URI}
