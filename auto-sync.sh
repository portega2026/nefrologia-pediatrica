#!/usr/bin/env bash
set -euo pipefail

FILE="${1:-index.html}"
BRANCH="${BRANCH:-$(git branch --show-current 2>/dev/null || true)}"
MESSAGE_PREFIX="${MESSAGE_PREFIX:-auto-sync}"
POLL_SECONDS="${POLL_SECONDS:-2}"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Este directorio no es un repositorio Git."
  echo "Inicializa Git y configura el remoto antes de usar este script."
  exit 1
fi

if [ -z "${BRANCH}" ]; then
  BRANCH="main"
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No existe el remoto 'origin'."
  echo "Añade el remoto de GitHub antes de usar este script."
  exit 1
fi

if [ ! -e "${FILE}" ]; then
  echo "No existe el archivo a vigilar: ${FILE}"
  exit 1
fi

last_hash="$(shasum -a 256 "${FILE}" | awk '{print $1}')"

echo "Vigilando ${FILE}"
echo "Branch: ${BRANCH}"
echo "Pulsa Ctrl+C para detener."

while true; do
  sleep "${POLL_SECONDS}"

  if ! current_hash="$(shasum -a 256 "${FILE}" | awk '{print $1}')"; then
    continue
  fi

  if [ "${current_hash}" = "${last_hash}" ]; then
    continue
  fi

  last_hash="${current_hash}"

  if git diff --quiet -- "${FILE}" 2>/dev/null; then
    continue
  fi

  git add "${FILE}"

  if git diff --cached --quiet -- "${FILE}" 2>/dev/null; then
    continue
  fi

  commit_message="${MESSAGE_PREFIX}: update ${FILE} $(date '+%Y-%m-%d %H:%M:%S')"

  if git commit -m "${commit_message}"; then
    if git push origin "${BRANCH}"; then
      echo "Sincronizado: ${commit_message}"
    else
      echo "Commit creado, pero el push falló. Revisa credenciales o conectividad."
    fi
  fi
done
