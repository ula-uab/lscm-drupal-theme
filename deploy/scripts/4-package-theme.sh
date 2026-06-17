#!/usr/bin/env bash
#
# 4-package-theme.sh — Empaqueta SOLO el tema para un redespliegue PARCIAL.
#
# Para iteraciones que tocan únicamente el tema (plantillas Twig, CSS/JS, .theme,
# .libraries.yml, componentes...). NO reconstruye core/vendor/contrib ni toca la BD.
#
# Si cambiaste CSS/JS, ejecuta antes deploy/scripts/1-build.sh para regenerar dist/.
#
# Genera deploy/deployment-files/lscm-theme.zip con la ruta themes/custom/<tema>/ en
# la raíz del zip, lista para descomprimir en el docroot del hosting reemplazando esa
# misma carpeta. Se ejecuta en el host.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

THEME_REL="themes/custom/bootstrap_ula_lscm"
THEME_SRC="web/$THEME_REL"
OUT_DIR="deploy/deployment-files"
ZIP_ABS="$PROJECT_ROOT/$OUT_DIR/lscm-theme.zip"

[ -d "$THEME_SRC" ]      || { echo "ERROR: no se encuentra el tema en $THEME_SRC." >&2; exit 1; }
[ -d "$THEME_SRC/dist" ] || { echo "ERROR: no hay dist/ en el tema. Ejecuta deploy/scripts/1-build.sh primero." >&2; exit 1; }
command -v zip   >/dev/null 2>&1 || { echo "ERROR: se requiere zip en el host." >&2; exit 1; }
command -v rsync >/dev/null 2>&1 || { echo "ERROR: se requiere rsync en el host." >&2; exit 1; }

mkdir -p "$OUT_DIR"
rm -f "$ZIP_ABS"

# Staging temporal para excluir node_modules de forma limpia y conservar la ruta
# themes/custom/<tema> dentro del zip.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/themes/custom"
rsync -a --exclude 'node_modules/' "$THEME_SRC/" "$TMP_DIR/$THEME_REL/"
( cd "$TMP_DIR" && zip -r -q "$ZIP_ABS" "themes" -x '*.DS_Store' )

echo "OK: tema empaquetado en $OUT_DIR/lscm-theme.zip"
echo "Súbelo y descomprímelo en el docroot del hosting; reemplaza la carpeta"
echo "themes/custom/bootstrap_ula_lscm/. Después, limpia la caché de Drupal."
echo "Si el cambio ELIMINA o RENOMBRA ficheros del tema, borra antes esa carpeta"
echo "en el servidor para no dejar ficheros huérfanos."
