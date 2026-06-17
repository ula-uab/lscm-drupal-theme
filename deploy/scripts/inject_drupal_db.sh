#!/usr/bin/env bash
# inject_drupal_db.sh
#
# Replaces the placeholder string:
#   $databases = [];
# in a Drupal settings.php file with a fully configured $databases array
# built from environment variables.
#
# Required environment variables:
#   DB_HOST      - database host (e.g. localhost or 127.0.0.1)
#   DB_PORT      - database port (e.g. 3306)
#   DB_NAME      - database/schema name
#   DB_USER      - database username
#   DB_PASSWORD  - database password
#
# Optional environment variables:
#   DB_DRIVER    - database driver (default: mysql)
#   DB_PREFIX    - table prefix   (default: empty string)
#   DB_COLLATION - collation      (default: utf8mb4_general_ci)
#   DB_NAMESPACE - PDO namespace  (default: Drupal\\Core\\Database\\Driver\\mysql for mysql,
#                                           Drupal\\Core\\Database\\Driver\\pgsql for pgsql)
#   SETTINGS_FILE - path to settings.php (default: ./settings.php)
#
# Usage:
#   export DB_HOST=localhost DB_PORT=3306 DB_NAME=mydb DB_USER=drupal DB_PASSWORD=secret
#   ./inject_drupal_db.sh [/path/to/settings.php]
# ---------------------------------------------------------------------------

set -euo pipefail

# ── Resolve settings file ────────────────────────────────────────────────────
SETTINGS_FILE="${1:-${SETTINGS_FILE:-./settings.php}}"

if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo "ERROR: Settings file not found: $SETTINGS_FILE" >&2
  exit 1
fi

# ── Validate required variables ──────────────────────────────────────────────
missing=()
for var in DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD; do
  [[ -z "${!var:-}" ]] && missing+=("$var")
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "ERROR: The following required environment variables are not set:" >&2
  printf '  %s\n' "${missing[@]}" >&2
  exit 1
fi

# ── Defaults for optional variables ─────────────────────────────────────────
DB_DRIVER="${DB_DRIVER:-mysql}"
DB_PREFIX="${DB_PREFIX:-}"
DB_COLLATION="${DB_COLLATION:-utf8mb4_general_ci}"

if [[ -z "${DB_NAMESPACE:-}" ]]; then
  case "$DB_DRIVER" in
    pgsql)   DB_NAMESPACE='Drupal\\Core\\Database\\Driver\\pgsql' ;;
    sqlite)  DB_NAMESPACE='Drupal\\Core\\Database\\Driver\\sqlite' ;;
    *)       DB_NAMESPACE='Drupal\\Core\\Database\\Driver\\mysql' ;;
  esac
fi

# ── Build the replacement block ──────────────────────────────────────────────
# Using a heredoc assigned to a variable so special characters in passwords
# are handled safely (no eval, no echo -e).
read -r -d '' DB_BLOCK << PHPBLOCK || true
\$databases = [
  'default' => [
    'default' => [
      'driver'    => '${DB_DRIVER}',
      'namespace' => '${DB_NAMESPACE}',
      'host'      => '${DB_HOST}',
      'port'      => '${DB_PORT}',
      'database'  => '${DB_NAME}',
      'username'  => '${DB_USER}',
      'password'  => '${DB_PASSWORD}',
      'prefix'    => '${DB_PREFIX}',
      'collation' => '${DB_COLLATION}',
    ],
  ],
];
PHPBLOCK

# ── Escape the replacement string for use in sed ─────────────────────────────
# We use a Python one-liner as a safe in-place substitution engine so that
# special characters in the password (/, &, \n, etc.) can't break the regex.
python3 - "$SETTINGS_FILE" "$DB_BLOCK" << 'PYEOF'
import sys, pathlib

settings_path = pathlib.Path(sys.argv[1])
replacement   = sys.argv[2]

original = settings_path.read_text(encoding="utf-8")
placeholder = "$databases = [];"

if placeholder not in original:
    print(f"WARNING: Placeholder '{placeholder}' not found in {settings_path}", file=sys.stderr)
    sys.exit(0)

updated = original.replace(placeholder, replacement, 1)
settings_path.write_text(updated, encoding="utf-8")
print(f"OK: Replaced placeholder in {settings_path}")
PYEOF
