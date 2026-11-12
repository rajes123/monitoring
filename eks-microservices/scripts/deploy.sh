#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
IMAGE_TAG="${IMAGE_TAG:-latest}"

command -v terraform >/dev/null || { echo "ERROR: terraform is required"; exit 1; }
command -v kubectl >/dev/null || { echo "ERROR: kubectl is required"; exit 1; }
command -v envsubst >/dev/null || { echo "ERROR: envsubst is required"; exit 1; }

REPOS_JSON="$(terraform -chdir="${TF_DIR}" output -json ecr_repository_urls)"
export USER_IMAGE="$(echo "${REPOS_JSON}" | jq -r '.user'):${IMAGE_TAG}"
export PAYMENT_IMAGE="$(echo "${REPOS_JSON}" | jq -r '.payment'):${IMAGE_TAG}"
export ADMIN_IMAGE="$(echo "${REPOS_JSON}" | jq -r '.admin'):${IMAGE_TAG}"
export SERVICES_IMAGE="$(echo "${REPOS_JSON}" | jq -r '.services'):${IMAGE_TAG}"
export ORDER_IMAGE="$(echo "${REPOS_JSON}" | jq -r '.order'):${IMAGE_TAG}"

envsubst '${USER_IMAGE} ${PAYMENT_IMAGE} ${ADMIN_IMAGE} ${SERVICES_IMAGE} ${ORDER_IMAGE}' \
  < "${ROOT_DIR}/k8s/microservices.yaml.tpl" \
  | kubectl apply -f -

kubectl rollout status deployment/user
kubectl rollout status deployment/payment
kubectl rollout status deployment/admin
kubectl rollout status deployment/services
kubectl rollout status deployment/order
