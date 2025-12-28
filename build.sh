#!/usr/bin/env bash
set -euo pipefail

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Commande introuvable: $1" >&2
    exit 127
  }
}

require_cmd git
require_cmd docker

echo "== Sync repo =="
git pull --ff-only

default_repo="ghcr.io/rangedace/la-question-de-dix-heures"
image_repo="${IMAGE_REPO:-$default_repo}"

read -r -p "Image repo [$image_repo]: " input_repo
if [[ -n "${input_repo:-}" ]]; then
  image_repo="$input_repo"
fi

version=""
while [[ -z "$version" ]]; do
  read -r -p "Version à publier (ex: 0.4.2): " version
done

image_version="${image_repo}:${version}"
image_latest="${image_repo}:latest"

echo "== Build =="
docker build -t "$image_version" -t "$image_latest" .

echo "== Push =="
echo "Note: assure-toi d'être loggé: docker login ghcr.io"
docker push "$image_version"
docker push "$image_latest"

echo "OK: ${image_version} et ${image_latest}"
