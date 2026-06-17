#!/usr/bin/env bash
#
# 1-build.sh — Compila los assets del tema (Webpack → dist/).
#
# Se ejecuta en el HOST (macOS, ARM64) con Node 22 gestionado por nvm
# (la versión la fija el .nvmrc del tema). No toca vendor/ ni la BD.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEME_DIR="$PROJECT_ROOT/web/themes/custom/bootstrap_ula_lscm"

cd "$THEME_DIR"

# Node 22 vía nvm (lee .nvmrc del tema)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  nvm use
else
  echo "AVISO: no se encontró nvm en \$NVM_DIR ($NVM_DIR)." >&2
  echo "       Asegúrate de tener Node 22 activo antes de continuar." >&2
fi

npm ci
npm run build:prod

echo "OK: tema compilado. dist/ actualizado en $THEME_DIR/dist"
