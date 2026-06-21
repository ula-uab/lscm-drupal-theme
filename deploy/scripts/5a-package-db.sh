#!/usr/bin/env bash
#
# 5a-package-db.sh — Empaqueta la BD local como ARTEFACTO DE DESPLIEGUE.
#
# Exporta la base de datos de DDEV a deploy/deployment-files/lscm-db.sql.gz, listo
# para importar en producción por phpMyAdmin (§7.1 del README).
#
# OJO: esto NO es una copia de respaldo. Los respaldos van en backups/ (otro propósito).
# Este fichero es el artefacto que se SUBE a producción y queda ignorado por git
# (toda la carpeta deployment-files/ está en .gitignore).
#
# Se ejecuta en el host, desde la raíz del proyecto.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

OUT_DIR="deploy/deployment-files"
OUT="$OUT_DIR/lscm-db.sql.gz"

command -v ddev >/dev/null 2>&1 || { echo "ERROR: se requiere ddev en el host." >&2; exit 1; }

mkdir -p "$OUT_DIR"
rm -f "$OUT"
ddev export-db --file="$OUT"

echo "OK: BD exportada como artefacto de despliegue en $OUT"
echo "Se IMPORTA en producción por phpMyAdmin (no se descomprime en el sistema de ficheros)."
