#!/usr/bin/env bash
#
# 2-stage-flat.sh — Construye el artefacto PLANO de despliegue en deploy/build/.
#
# Genera el layout plano de forma NATIVA (sin parchear el autoloader):
#   1. Copia composer.json/lock a un staging.
#   2. Reescribe ese composer.json a layout plano: web-root '.' e installer-paths
#      sin el prefijo 'web/'.
#   3. Ejecuta `composer install` ahí → core, contrib, vendor y andamiaje
#      (index.php, autoload.php con la ruta plana correcta, .htaccess de Drupal)
#      quedan PLANOS, y el autoloader se genera coherente con ese layout.
#   4. Superpone el único código propio del repo: el tema bootstrap_ula_lscm
#      (con su dist/, sin node_modules).
#   5. Inyecta el settings.php de producción (BD, hash_salt y trusted_host
#      desde ./.env). Estos tres son PROD-ONLY: no viven en el settings.php
#      compartido (lo romperían en DDEV local).
#
# composer se ejecuta DENTRO del contenedor DDEV; el resto, en el host.
# NO toca el vendor/ local ni la configuración de DDEV.
#
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$PROJECT_ROOT"

BUILD_DIR="deploy/build"
THEME_REL="themes/custom/bootstrap_ula_lscm"
THEME_SRC="web/$THEME_REL"
INJECT="deploy/scripts/inject_drupal_db.sh"
ENV_FILE=".env"
SETTINGS_SRC="web/sites/default/settings.php"
SETTINGS_OUT="$BUILD_DIR/sites/default/settings.php"

# ── 0. Precondiciones ────────────────────────────────────────────────────────
[ -f "$ENV_FILE" ]       || { echo "ERROR: falta ./$ENV_FILE en la raíz (cópialo de deploy/env.example y rellénalo)." >&2; exit 1; }
[ -f "$INJECT" ]         || { echo "ERROR: no se encuentra $INJECT." >&2; exit 1; }
[ -d "$THEME_SRC/dist" ] || { echo "ERROR: no hay dist/ en el tema. Ejecuta deploy/scripts/1-build.sh primero." >&2; exit 1; }
[ -f "$SETTINGS_SRC" ]   || { echo "ERROR: no se encuentra tu settings.php local en $SETTINGS_SRC." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: inject_drupal_db.sh requiere python3 en el host." >&2; exit 1; }
command -v rsync   >/dev/null 2>&1 || { echo "ERROR: se requiere rsync en el host." >&2; exit 1; }

# ── 0.1 Cargar ./.env y validar lo requerido ─────────────────────────────────
set -a
# shellcheck disable=SC1090
. "./$ENV_FILE"
set +a
[ -n "${HASH_SALT:-}" ] || { echo "ERROR: define HASH_SALT en ./$ENV_FILE (valor estable; genéralo con: openssl rand -hex 32)." >&2; exit 1; }

# Normalizar TRUSTED_HOST (opcional): quitar esquema y ruta, dejar host[:puerto].
# trusted_host_patterns se compara con la cabecera Host, que NO lleva esquema.
TRUSTED_HOST_NORM=""
if [ -n "${TRUSTED_HOST:-}" ]; then
  TRUSTED_HOST_NORM=$(printf '%s' "$TRUSTED_HOST" | sed -E 's#^[a-zA-Z][a-zA-Z0-9+.-]*://##; s#/.*##')
fi

# ── 1. Staging limpio ────────────────────────────────────────────────────────
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ── 2. composer.json/lock → staging, reescribiendo a layout plano ────────────
cp composer.json composer.lock "$BUILD_DIR/"
python3 - "$BUILD_DIR/composer.json" <<'PYEOF'
import json, sys
path = sys.argv[1]
with open(path) as fh:
    data = json.load(fh)
extra = data.setdefault("extra", {})
# Docroot = raíz del proyecto (layout plano)
extra.setdefault("drupal-scaffold", {}).setdefault("locations", {})["web-root"] = "./"
# Quitar el prefijo 'web/' de las installer-paths
paths = extra.get("installer-paths", {})
flat = {}
for p, types in paths.items():
    flat[p[4:] if p.startswith("web/") else p] = types
extra["installer-paths"] = flat
with open(path, "w") as fh:
    json.dump(data, fh, indent=4)
print("  composer.json del staging reescrito a plano (web-root '.', installer-paths sin 'web/').")
PYEOF

# ── 3. composer install PLANO en el staging (dentro de DDEV) ─────────────────
# Aviso esperado e inofensivo: al haber tocado 'extra', composer puede decir que
# el lock "is not up to date". `install` NO re-resuelve; instala las versiones
# fijadas en composer.lock. (No ejecutes `composer update`.)
echo "Ejecutando composer install (plano) en $BUILD_DIR vía DDEV..."
ddev exec "cd $BUILD_DIR && composer install --no-dev --optimize-autoloader --no-interaction"

# ── 4. Superponer el tema propio (con dist/, sin node_modules) ───────────────
mkdir -p "$BUILD_DIR/themes/custom"
rsync -a --delete --exclude 'node_modules/' "$THEME_SRC/" "$BUILD_DIR/$THEME_REL/"

# ── 5. settings.php de producción ────────────────────────────────────────────
# Partimos de tu settings.php local: ya tiene los ajustes del sitio, el marcador
# `$databases = [];` y el include de DDEV (inerte fuera de DDEV). Inyectamos la BD
# y añadimos al final los ajustes prod-only (hash_salt, trusted_host_patterns),
# que así prevalecen sin tocar el settings.php compartido.
mkdir -p "$BUILD_DIR/sites/default"
cp "$SETTINGS_SRC" "$SETTINGS_OUT"

# 5a. BD (reemplaza el marcador $databases = [];)
bash "$INJECT" "$SETTINGS_OUT"

# 5b. hash_salt y trusted_host_patterns (prod-only), añadidos al final
{
  echo ""
  echo "// --- Ajustes de producción añadidos por deploy/scripts/2-stage-flat.sh ---"
  echo "\$settings['hash_salt'] = '${HASH_SALT}';"
  if [ -n "$TRUSTED_HOST_NORM" ]; then
    esc=$(printf '%s' "$TRUSTED_HOST_NORM" | sed 's/\./\\./g')
    echo "\$settings['trusted_host_patterns'] = ['^${esc}\$'];"
  fi
} >> "$SETTINGS_OUT"

# ── 6. No enviar directorios propiedad del servidor ──────────────────────────
# Las subidas de usuario viven en el servidor; nunca se sobrescriben en deploy.
rm -rf "$BUILD_DIR/sites/default/files"

# ── 7. Resumen ───────────────────────────────────────────────────────────────
echo
echo "settings.php de producción generado:"
echo "  - \$databases inyectado desde ./.env (DB_*)"
echo "  - hash_salt fijado desde ./.env"
if [ -n "$TRUSTED_HOST_NORM" ]; then
  echo "  - trusted_host_patterns fijado para host: $TRUSTED_HOST_NORM"
else
  echo "  - trusted_host_patterns SIN fijar (define TRUSTED_HOST en ./.env si lo quieres)"
fi
echo
echo "OK: artefacto plano listo en $BUILD_DIR/"
