#!/usr/bin/env bash
#
# 5b-package-files.sh — Empaqueta los ficheros gestionados como ARTEFACTO DE DESPLIEGUE.
#
# Comprime web/sites/default/files/ en deploy/deployment-files/lscm-files.zip,
# excluyendo las subcarpetas REGENERABLES (css/, js/, php/, styles/), que Drupal
# recrea. El zip lleva el contenido en su raíz.
#
# IMPORTANTE: este zip se descomprime DENTRO de sites/default/files/ del docroot
# (NO en la raíz del docroot). Ver §7.2 del README.
#
# Se ejecuta en el host, desde la raíz del proyecto.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

FILES_SRC="web/sites/default/files"
OUT_DIR="deploy/deployment-files"
ZIP_ABS="$PROJECT_ROOT/$OUT_DIR/lscm-files.zip"

[ -d "$FILES_SRC" ] || { echo "ERROR: no existe $FILES_SRC." >&2; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "ERROR: se requiere zip en el host." >&2; exit 1; }

mkdir -p "$OUT_DIR"
rm -f "$ZIP_ABS"
( cd "$FILES_SRC" && zip -r -q "$ZIP_ABS" . -x 'css/*' 'js/*' 'php/*' 'styles/*' '*.DS_Store' )

echo "OK: ficheros gestionados empaquetados en $OUT_DIR/lscm-files.zip"
echo "Se descomprime DENTRO de sites/default/files/ del docroot (NO en la raíz)."
