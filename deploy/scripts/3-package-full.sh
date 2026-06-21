#!/usr/bin/env bash
#
# 3-package-full.sh — Comprime el artefacto COMPLETO del sitio (deploy/build/).
#
# Es el empaquetado que acompaña a 2-stage-flat.sh: el sitio Drupal entero en layout
# plano (core, contrib, vendor, tema, andamiaje). Se usa en el primer despliegue y en
# los despliegues con cambio de dependencias (§6 / §9b del README).
#
# Para redespliegues que solo tocan el tema, usa 4-package-theme.sh.
#
# Se ejecuta en el host. El zip lleva el contenido en su raíz, de modo que al
# descomprimir EN EL DOCROOT todo queda plano (index.php, core/, vendor/...).
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

BUILD_DIR="deploy/build"
OUT_DIR="deploy/deployment-files"
ZIP_ABS="$PROJECT_ROOT/$OUT_DIR/lscm-full.zip"

[ -d "$BUILD_DIR" ] || { echo "ERROR: no existe $BUILD_DIR. Ejecuta 2-stage-flat.sh primero." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "ERROR: se requiere zip en el host." >&2; exit 1; }

mkdir -p "$OUT_DIR"
rm -f "$ZIP_ABS"
( cd "$BUILD_DIR" && zip -r -q "$ZIP_ABS" . -x '*.DS_Store' )

echo "OK: artefacto COMPLETO comprimido en $OUT_DIR/lscm-full.zip"
echo "Se descomprime EN EL DOCROOT del hosting (queda todo plano)."
