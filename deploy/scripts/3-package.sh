#!/usr/bin/env bash
#
# 3-package.sh — Comprime el artefacto plano (deploy/build/) en un zip listo para
# subir por el gestor de ficheros de Plesk y descomprimir en el docroot.
#
# Se ejecuta en el host. El zip lleva el contenido en su raíz, de modo que al
# descomprimir en el docroot todo queda plano (index.php, core/, vendor/...).
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

BUILD_DIR="deploy/build"
OUT_DIR="deploy/deployment-files"
ZIP_ABS="$PROJECT_ROOT/$OUT_DIR/lscm-deploy.zip"

[ -d "$BUILD_DIR" ] || { echo "ERROR: no existe $BUILD_DIR. Ejecuta 2-stage-flat.sh primero." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "ERROR: se requiere zip en el host." >&2; exit 1; }

mkdir -p "$OUT_DIR"
rm -f "$ZIP_ABS"
( cd "$BUILD_DIR" && zip -r -q "$ZIP_ABS" . -x '*.DS_Store' )

echo "OK: artefacto comprimido en $OUT_DIR/lscm-deploy.zip"
echo "Súbelo por el gestor de ficheros de Plesk y descomprímelo en el docroot."
echo "Quedará todo plano: index.php, core/, modules/, themes/, vendor/, sites/..."
