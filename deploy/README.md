# Despliegue del proyecto en el hosting (Plesk, layout plano)

Proceso para desplegar el proyecto Drupal completo en un hosting **Plesk sin acceso
SSH/shell** y con **document root fijo** (no se puede apuntar a una subcarpeta). El
despliegue produce un **layout plano**: Drupal queda directamente en el docroot (sin
subcarpeta `web/`) y con `vendor/` dentro, y la transferencia es por **zip + gestor de
ficheros de Plesk** (no FTP).

> En el entorno de pruebas el docroot es `devs-master-lscm.eu/`; en producción suele ser
> `httpdocs/`. A Drupal le da igual el nombre: aquí lo llamamos genéricamente «el docroot».

> Este documento **sustituye** al antiguo `DESPLIEGUE-HOSTING.md`, que partía de
> supuestos incorrectos (FTP/SFTP manual, conservar el `settings.php` del servidor,
> `npm run build`). El proceso válido es el de aquí.

> **Dos fuentes de verdad, dos mitades del despliegue.** El **código** (este artefacto)
> vive en git; la **configuración + contenido** del sitio vive en la **base de datos**,
> cuya copia es el **dump**. Un despliegue completo es: (a) subir el código (§1–§6) y
> (b) poner en producción la BD y los ficheros gestionados (§7). El dump es la red de
> seguridad de la mitad (b); git lo es de la mitad (a).

---

## 1. Por qué un layout plano construido de forma nativa

En local (DDEV) el proyecto usa el layout estándar de Composer: docroot en `web/` y
`vendor/` como hermano. En el `composer.json`, `web-root` es `web/` y todas las
`installer-paths` llevan el prefijo `web/` (`web/core`, `web/modules/contrib`…). Como
consecuencia, **el autoloader optimizado de Composer hornea rutas `<raíz>/web/...`**.

Si simplemente moviéramos `web/` a la raíz del docroot y `vendor/` dentro, ese autoloader
seguiría buscando el core en `<docroot>/web/core/...` (que ya no existiría): Drupal no
podría ni cargar sus propias clases. Por eso **no se mueve y se parchea**.

En su lugar, el artefacto plano se **genera de forma nativa**: se copia el
`composer.json`/`composer.lock` a un staging, se reescribe ese `composer.json` a layout
plano (`web-root: '.'`, `installer-paths` sin el prefijo `web/`) y se ejecuta
`composer install` ahí. Composer coloca `core/`, los contrib, `vendor/` y el andamiaje
(`index.php`, `autoload.php` con la ruta correcta, el `.htaccess` propio de Drupal)
**ya planos**, y el autoloader se genera coherente con ese layout. Sin parches.

El **único código propio** del repo es el tema `bootstrap_ula_lscm` (no hay módulos,
perfiles, librerías ni recipes custom), así que el único paso de superposición tras el
`composer install` es copiar el tema (con su `dist/`) e inyectar el `settings.php`.

Este enfoque **no toca tu `vendor/` local ni la configuración de DDEV**: todo el
trabajo plano ocurre en `deploy/build/`.

---

## 2. Requisitos previos

- **DDEV** en marcha (composer se ejecuta dentro del contenedor).
- **Node 22** vía `nvm` en el host (lo fija el `.nvmrc` del tema) para compilar.
- En el host: `python3` (lo usa `inject_drupal_db.sh`), `rsync` y `zip` (vienen con macOS).
- `composer.json` + `composer.lock` **consolidados en git** (el `.lock` fija las versiones
  que reproducirá el despliegue).
- El fichero **`./.env`** creado en la raíz (ver §3).

---

## 3. El fichero `./.env`

Las variables de producción van en un `./.env` en la **raíz del proyecto**, fuera de git.
Para crearlo:

```bash
cp deploy/env.example ./.env
# edita ./.env y rellena los valores
```

El `./.env` está cubierto por la línea `/.env` del `.gitignore`: **no se versiona nunca**.
La plantilla versionada es `deploy/env.example` (sin valores). Contiene:

- **`DB_*`** (requeridas): conexión a la BD de producción. La transferencia ya no usa FTP,
  así que no hay credenciales de FTP.
- **`HASH_SALT`** (requerida): valor **estable** para `$settings['hash_salt']` en
  producción. Genéralo una sola vez y no lo cambies (cambiarlo invalida sesiones y enlaces
  de un solo uso):
  ```bash
  openssl rand -hex 32
  ```
- **`TRUSTED_HOST`** (opcional, recomendada): dominio de producción para
  `$settings['trusted_host_patterns']`. Se da como **host pelado** (sin esquema ni ruta:
  `devs-master-lscm.eu`, no `https://devs-master-lscm.eu`); el script lo normaliza (quita
  esquema y ruta si los hubiera) y lo convierte en el patrón `['^devs-master-lscm\.eu$']`.

`HASH_SALT`, `TRUSTED_HOST` y `DB_*` son **prod-only**: se inyectan en el `settings.php`
del despliegue (§5), pero **no** viven en el `settings.php` compartido del repo/local —si
estuvieran ahí, romperían DDEV (p. ej., un `trusted_host_patterns` con el dominio de
producción rechazaría las peticiones a `*.ddev.site`).

---

## 4. Cómo funciona `inject_drupal_db.sh`

> **No lo ejecutas tú directamente.** Es un helper **interno** que invoca
> `2-stage-flat.sh` en su paso 5a (§5). Vive en `deploy/scripts/inject_drupal_db.sh`.

Es un helper heredado (conservado) que **genera el bloque `$databases` de producción sin
escribir credenciales a mano**:

- Lee la conexión desde **variables de entorno**: `DB_HOST`, `DB_PORT`, `DB_NAME`,
  `DB_USER`, `DB_PASSWORD` (requeridas) y `DB_DRIVER`, `DB_PREFIX`, `DB_COLLATION`,
  `DB_NAMESPACE` (opcionales, con valores por defecto razonables: driver `mysql`,
  collation `utf8mb4_general_ci`).
- Sobre el `settings.php` que recibe como argumento, **reemplaza el marcador
  `$databases = [];` por el array `$databases` completo** ya configurado.
- La sustitución la hace con un fragmento Python (no con `sed`) para que caracteres
  especiales de la contraseña (`/`, `&`, etc.) no rompan nada.

`2-stage-flat.sh` lo invoca sobre la **copia** del `settings.php` que va al staging (nunca
sobre tu `settings.php` local), pasándole las variables al cargar `./.env`. Los otros dos
ajustes prod-only (`hash_salt`, `trusted_host_patterns`) no los pone este helper: los
**añade `2-stage-flat.sh` al final** del `settings.php` del staging (ver §5).

---

## 5. Secuencia de scripts (primer despliegue / despliegue completo)

Dales permiso de ejecución una vez:

```bash
chmod +x deploy/scripts/*.sh
```

Ejecuta desde la **raíz del proyecto**, en orden:

### `deploy/scripts/1-build.sh` — compilar el tema
Compila los assets del tema con Webpack (`npm ci` + `npm run build:prod`) usando Node 22
vía nvm. Actualiza `web/themes/custom/bootstrap_ula_lscm/dist/`. Se ejecuta **en local,
directamente sobre el host** (no dentro del contenedor DDEV: el build del tema lo gestiona
nvm en el host).

### `deploy/scripts/2-stage-flat.sh` — armar el artefacto plano
1. Limpia y crea `deploy/build/`.
2. Copia `composer.json`/`composer.lock` y reescribe el `composer.json` del staging a
   layout plano.
3. `composer install --no-dev --optimize-autoloader` **dentro de DDEV**, en el staging
   (deja core, contrib, vendor y andamiaje planos, con el autoloader correcto).
4. Superpone el tema `bootstrap_ula_lscm` (con `dist/`, excluyendo `node_modules`).
5. Genera el `settings.php` de producción: copia tu `settings.php` local, **inyecta la BD**
   (`inject_drupal_db.sh` sobre el marcador `$databases = [];`) y **añade al final** los
   ajustes prod-only `hash_salt` y, si `TRUSTED_HOST` está definido, `trusted_host_patterns`
   (normalizando el host: quita esquema y ruta). Añadirlos al final es deliberado: en PHP
   gana la última asignación, así que prevalecen sobre los valores vacíos del settings.php
   sin necesidad de editar líneas concretas (más robusto que la cirugía en sitio).
6. Elimina `sites/default/files/` del staging (es propiedad del servidor).

> **Aviso esperado:** al haber tocado `extra`, composer puede avisar de que el lock "is
> not up to date". Es inofensivo: `install` **no** re-resuelve, instala las versiones del
> lock. **No ejecutes `composer update`.**

### `deploy/scripts/3-package.sh` — comprimir
Comprime `deploy/build/` en `deploy/deployment-files/lscm-deploy.zip`, con el contenido en
la raíz del zip para que al descomprimir en el docroot quede todo plano.

> Para **redespliegues** que solo tocan el tema existe además `4-package-theme.sh` (§9).

---

## 6. Subida y extracción limpia (Plesk, sin shell)

> **Regla de oro: NO mezclar con la instalación de fábrica.** El hosting creó un Drupal
> "de fábrica" (otra versión y otro conjunto de módulos). Si extraes el zip *encima* y
> respondes "sí, reemplazar", se sobrescriben los ficheros coincidentes pero quedan
> **huérfanos** los que el instalador puso y tu artefacto no tiene (core de otra versión,
> módulos que no usas, paquetes de `vendor` distintos): un "Frankenstein" que da fallos
> sutiles y difíciles de depurar sin shell. Hay que extraer sobre un docroot **limpio**.

Pasos:

1. Sube `deploy/deployment-files/lscm-deploy.zip` por el **gestor de ficheros** de Plesk
   al docroot.
2. Si al descomprimir te pregunta si reemplazar ficheros existentes, **cancela**: no
   extraigas mezclando.
3. **Vacía el docroot del Drupal de fábrica** desde el gestor de ficheros: borra
   `core/`, `vendor/`, `modules/`, `profiles/`, `themes/`, `sites/`, `index.php`,
   `autoload.php`, `update.php`, `.htaccess`, `robots.txt`, `composer.json`,
   `composer.lock`, etc. Es **solo código**: la BD no se toca (los datos del Drupal de
   fábrica están en la BD, no en estos ficheros), así que no hay nada que perder al
   borrarlos.

   **CONSERVA** (no son de Drupal, son del servidor y no están en el artefacto):
   - `.well-known/` — la usa Plesk para el certificado SSL.
   - `.user.ini` — configuración de PHP por directorio de Plesk.
   - `sites/default/files/` **solo si** ya contuviera subidas reales (en una instalación
     de fábrica está vacío; si dudas, descárgalo antes como copia).
   - Cualquier otro fichero/carpeta que Plesk haya puesto y tú no hayas subido.

4. **Extrae tu zip** en el docroot ya vacío. Quedará plano: `index.php`, `core/`,
   `modules/`, `themes/`, `vendor/`, `sites/`…
5. No hace falta tocar el document root ni añadir `.htaccess` de redirección: el
   `.htaccess` propio de Drupal, ahora en la raíz del docroot, sirve el sitio
   directamente. (Era la redirección a `/web` la que provocaba el error del admin; con el
   layout plano desaparece.)

6. **Permisos tras descomprimir (causa típica de 403).** El gestor de Plesk puede dejar
   ficheros —sobre todo los **ocultos**, como `.htaccess` o `.user.ini`— con permisos
   restrictivos (p. ej. `600`: `rw- --- ---`). Apache, que no puede leer el `.htaccess`,
   responde 403 a todo, con un error de Apache del tipo
   `(13) Permission denied: AH00529: .htaccess not readable`. Corrige a:
   - directorios → `755`, ficheros → `644` (incluidos los ocultos `.htaccess`, `.user.ini`);
   - `sites/default/settings.php` → al contrario, restrictivo es bueno (`644`, idealmente
     `444` solo lectura).

   Lo más rápido, si tu Plesk lo ofrece, es su función **«Restablecer permisos»** del
   docroot (reasigna propietario y permisos correctos de golpe).

---

## 7. Puesta en producción tras el código

Subir el código deja a Drupal arrancando, pero **contra la BD que haya** y **sin los
ficheros gestionados**. Faltan tres cosas para que el sitio sea el tuyo.

### 7.1 Importar la base de datos (sin shell)

La configuración y el contenido del sitio (módulos activos, tema, nodos, etc.) viven en la
BD, no en git. Hay que importar tu **dump** en la BD de producción **a la que apunta
`settings.php`** (la `DB_NAME` de tu `./.env`).

**Primero, genera el dump desde tu local** (no está en el repo; `backups/` y `*.sql*` están
en `.gitignore`). Exporta la BD de DDEV:

```bash
mkdir -p backups
ddev export-db --file=backups/lscm-$(date +%Y%m%d).sql.gz
```

Genera uno **fresco** antes de cada despliegue de BD, para que refleje el estado actual de
tu local. Si phpMyAdmin se queja por **tamaño**, genera una variante "lean" que vuelca las
tablas de caché solo con su estructura (sin datos), mucho más pequeña:

```bash
ddev drush sql:dump --structure-tables-key=common --gzip \
  --result-file=/var/www/html/backups/lscm-lean.sql
```

**Después, impórtalo en producción:**

1. Abre **phpMyAdmin** (Plesk → *Bases de datos* → *phpMyAdmin*) o Adminer, sobre la BD
   correcta (`DB_NAME`). **Asegúrate de que es esa**, no otra del servidor.
2. **Vacíala primero**: la BD de fábrica no tiene datos que conservar. En phpMyAdmin,
   marca todas las tablas → *Eliminar* (DROP). (Importar encima sin vaciar dejaría tablas
   de fábrica huérfanas, el mismo problema que en §6 pero en la BD.)
3. **Importa el dump** por la pestaña *Importar* (phpMyAdmin admite `.sql.gz`). Si el dump
   supera el límite de subida, súbelo descomprimido por el gestor de ficheros y
   selecciónalo desde el servidor, o usa la importación de BD de Plesk.
4. La red de seguridad de esta operación es el propio **dump** (es una operación sobre BD).

Tras importar, la BD trae **tu** usuario administrador, así que ya podrás iniciar sesión.

### 7.2 Subir los ficheros gestionados (`sites/default/files/`)

Las imágenes y ficheros subidos (managed files) viven en tu `web/sites/default/files/`
local y **no van en el zip de código** (los excluimos a propósito: son contenido, pueden
ser grandes y no deben pisarse en redespliegues). El dump referencia esos ficheros por URI
(`public://…` → `sites/default/files/…`), así que si no los subes verás imágenes rotas y,
hasta limpiar caché, la página puede salir **en blanco** (los CSS/JS agregados que la BD
referencia no existen aún en el servidor).

**Empaqueta `files/` en local** (desde la raíz del proyecto):

```bash
mkdir -p deploy/deployment-files
rm -f deploy/deployment-files/lscm-files.zip
( cd web/sites/default/files && \
  zip -r -q ../../../../deploy/deployment-files/lscm-files.zip . \
    -x 'css/*' 'js/*' 'php/*' 'styles/*' '*.DS_Store' )
```

Se **excluyen** las subcarpetas **regenerables**: `css/` y `js/` (agregados), `styles/`
(derivados de estilos de imagen) y `php/` (caché de Twig compilado). Drupal las regenera;
subir las locales sería arrastrar artefactos obsoletos (y `php/` stale puede dar
problemas). El zip lleva el contenido en su raíz.

**Súbelo y descomprímelo dentro de `sites/default/files/` del hosting.** Verifica que el
contenido queda directamente ahí (no en una subcarpeta anidada).

> **Precaución de sobrescritura (redespliegues).** En el primer despliegue `files/` está
> vacío y no hay riesgo. Pero en redespliegues **ya hay subidas en el servidor**: es
> contenido vivo, trátalo como la BD. Si el gestor pregunta si reemplazar, **no
> sobrescribas a ciegas** (los ficheros del servidor pueden ser más recientes que tu copia
> local). Antes de descomprimir, **descarga como copia de seguridad** el `files/` del
> servidor; y si solo quieres **añadir lo que falta** sin pisar lo existente, extrae en una
> carpeta aparte y copia selectivamente, o usa la opción "no reemplazar existentes" si el
> gestor la ofrece.

**Permisos / "usuario web":** en Plesk, PHP-FPM se ejecuta como el **usuario de tu
suscripción** (el mismo que posee lo que subes por el panel/FTP), **no** como `www-data`.
Por eso `sites/default/files/` (creada por el panel) **ya es de ese usuario y escribible**:
normalmente **no necesitas cambiar propietario**. Solo asegúrate de que el directorio sea
**escribible** por su dueño (Drupal escribe ahí los agregados, los derivados de imagen y
las futuras subidas) y de que los ficheros sean legibles (dirs `755`, ficheros `644`).

**Tras subir, limpia la caché** (§7.3): regenera los CSS/JS agregados con referencias
coherentes. Sin este paso, la BD sigue apuntando a agregados inexistentes y la home queda
en blanco.

### 7.3 Limpiar caché (sin shell)

El dump trae las tablas `cache_*` con datos obsoletos. Dos vías:

- **phpMyAdmin:** vacía (TRUNCATE) las tablas que empiezan por `cache`.
- **Admin** (cuando ya puedas entrar): *Configuración → Desarrollo → Rendimiento*
  (`/admin/config/development/performance`) → "Limpiar todas las cachés".

### 7.4 Acceso al admin y diagnóstico del 403

- Un **403 en `/admin` sin sesión iniciada es normal**: indica que Drupal funciona (el
  `.htaccess`, `index.php`, el autoloader y la BD están bien), pero el usuario anónimo no
  tiene acceso al admin. **Inicia sesión en `/user/login`** con tu usuario administrador
  (que viene en el dump importado), no entres por `/admin`.
- Si ves el 403 **antes** de importar la BD, es esperable: la BD de producción aún no es la
  tuya y no conoces su usuario admin. Importa el dump (§7.1) y entra por `/user/login`.
- Si **toda** la web (incluida la home `/`) da 403 con `AH00529: .htaccess not readable`,
  es un problema de **permisos** del docroot, no de Drupal → corrige permisos (§6, paso 6).

### 7.5 Verificar
Carga la home y el admin (tras login), comprueba el tema y que los módulos esperados están
activos, y que las imágenes (managed files) se ven.

---

## 8. `.gitignore` (añadir)

El staging y los zips son artefactos generados; no se versionan. Añade:

```
/deploy/build/
/deploy/deployment-files/
```

(la línea `/.env` ya debería estar para proteger las credenciales).

---

## 9. Redespliegues / actualizaciones

El borrón y cuenta nueva de §6 solo es necesario en el **primer** despliegue (para evitar
el "Frankenstein" con la instalación de fábrica). Para iteraciones, el alcance depende del
tipo de cambio:

### (a) Cambio solo del tema — despliegue parcial
Plantillas Twig, CSS/JS, `.theme`, `.libraries.yml`, componentes… Solo cambian ficheros
bajo `themes/custom/bootstrap_ula_lscm/`; no tocan core, vendor, contrib ni `settings.php`.

1. Si tocaste CSS/JS, recompila: `deploy/scripts/1-build.sh` (regenera `dist/`).
2. Empaqueta solo el tema: `deploy/scripts/4-package-theme.sh` → genera
   `deploy/deployment-files/lscm-theme.zip` (con la ruta `themes/custom/bootstrap_ula_lscm/`
   en su raíz, sin `node_modules`).
3. Súbelo y descomprímelo en el docroot, reemplazando `themes/custom/bootstrap_ula_lscm/`.
   **Matiz huérfanos:** si el cambio **elimina o renombra** ficheros del tema, **borra antes
   esa carpeta en el servidor** y luego extrae (si solo sobrescribes, quedarían ficheros
   viejos huérfanos). Para un retoque de CSS o de una plantilla, sobrescribir basta.
4. **Limpia la caché** (los cambios de Twig, de librerías y la agregación lo exigen).

### (b) Cambio de dependencias — proceso completo
Nuevo/actualizado módulo contrib, cambios en `composer.json`/`composer.lock`, o
actualización de core: cambian `vendor/`, `core/` o `modules/contrib/` y el autoloader. Hay
que **reconstruir el artefacto** (`2-stage-flat.sh`) y redesplegar el código; lo más seguro
es el **proceso completo** de §6 (vaciar el docroot y extraer en limpio).

### (c) Cambio de configuración o contenido — es la BD, no ficheros
Tipos de contenido, vistas, bloques, nodos creados por la interfaz: viven en la **BD**, no
en ficheros del tema, así que **no se despliegan por ficheros**. Es la otra fuente de verdad
(importación de dump / config sync, pendiente). Un cambio de código del tema, por sí solo,
nunca toca la BD.

---

## 10. Avisos y limitaciones

- El **código** (este artefacto) es solo código: su red de seguridad es git. La **BD** y
  los **ficheros gestionados** (§7) son la otra fuente de verdad: su red de seguridad es el
  **dump** (BD) y tu copia local de `files/`.
- Los scripts están **revisados a mano**, no validados con PHP/Composer en origen. El
  punto a validar en la primera ejecución real es el `composer install` del staging plano
  (paso 3 de `2-stage-flat.sh`): comprueba que `deploy/build/` queda plano y con
  `vendor/autoload.php` y `core/` en su sitio antes de comprimir.
- A largo plazo, lo más limpio sería migrar el proyecto a un layout plano nativo (estilo
  `drupal/legacy-project`), lo que evitaría la reescritura en cada build. Es una tarea
  aparte: reestructura el repo y DDEV, y se planificaría como tal.
