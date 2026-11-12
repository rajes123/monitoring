#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"
IMAGE_TAG="${IMAGE_TAG:-latest}"

command -v aws >/dev/null || { echo "ERROR: aws CLI is required"; exit 1; }
command -v docker >/dev/null || { echo "ERROR: docker is required"; exit 1; }
command -v jq >/dev/null || { echo "ERROR: jq is required"; exit 1; }

REGION="$(terraform -chdir="${TF_DIR}" output -raw aws_region)"
ACCOUNT_ID="$(terraform -chdir="${TF_DIR}" output -raw aws_account_id)"
REPOS_JSON="$(terraform -chdir="${TF_DIR}" output -json ecr_repository_urls)"
REGISTRY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

aws ecr get-login-password --region "${REGION}" \
  | docker login --username AWS --password-stdin "${REGISTRY}"

for SERVICE in user payment admin services order; do
  DOCKERFILE_DIR="${ROOT_DIR}/services/${SERVICE}"
  REPO_URL="$(echo "${REPOS_JSON}" | jq -r --arg service "${SERVICE}" '.[$service]')"

  if [[ ! -f "${DOCKERFILE_DIR}/Dockerfile" ]]; then
    echo "ERROR: Missing ${DOCKERFILE_DIR}/Dockerfile"
    echo "Create one Dockerfile per service, then run this script again."
    exit 1
  fi

  echo "Building ${SERVICE} -> ${REPO_URL}:${IMAGE_TAG}"
  docker build -t "${REPO_URL}:${IMAGE_TAG}" "${DOCKERFILE_DIR}"
  docker push "${REPO_URL}:${IMAGE_TAG}"
done

echo "All five images pushed successfully."
