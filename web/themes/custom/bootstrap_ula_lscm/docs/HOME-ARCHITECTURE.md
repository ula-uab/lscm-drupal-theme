# Home LSCM — Arquitectura, diseño y mantenimiento

> Tema **Bootstrap ULA LSCM** (`bootstrap_ula_lscm`), subtema de `bootstrap_italia`.
> Drupal 11. Repositorio: https://github.com/ula-uab/lscm-drupal-theme (rama `main`).

---

## Control de versiones

El tema `bootstrap_ula_lscm` usa **versionado semántico propio** (`MAYOR.MENOR.PARCHE`),
declarado en `bootstrap_ula_lscm.info.yml`, **independiente de Bootstrap Italia**:

- **MAYOR**: cambios grandes de arquitectura (p.ej. completar la desvinculación de Bootstrap Italia → `2.0.0`).
- **MENOR**: nuevas funcionalidades (p.ej. colecciones editables → `1.1.0`).
- **PARCHE**: correcciones y ajustes menores.

> **Nota histórica:** hasta la v1.0.0, el `version:` del tema heredaba el número de
> Bootstrap Italia (`2.17.6`), que no representaba el desarrollo propio. Desde la v1.0.0
> se reinicia con versionado propio, como paso hacia la independencia del tema padre.

| Versión tema | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-11 | Primera versión con identidad propia. Cubre los 8 componentes `ula_*`, el marco `lscm-master-page`, el sistema de CSS en tres capas, y la home editable (nodo `landing` + plantillas `page--front` y `node--landing`). Documento de arquitectura de la home (este fichero). |

> **Mantenimiento:** al introducir cambios estructurales (nuevos componentes, cambios de arquitectura, colecciones editables), subir la versión del tema en `bootstrap_ula_lscm.info.yml` según el criterio semántico de arriba, añadir una fila a esta tabla, y actualizar las secciones afectadas del documento.

---

## 1. Visión general

La **home** del sitio es una *landing page* del máster LSCM: un escaparate que presenta el programa por secciones y **invita a entrar** a las páginas de detalle del sitio. Su contenido es mayoritariamente estático, con ajustes ocasionales.

Características clave de la implementación:

- **Diseño autónomo**, fiel a una maqueta original, **independiente de Bootstrap Italia** (no usa sus clases ni su CSS para la landing).
- Construida con **componentes SDC** (Single Directory Components) propios, con prefijo `ula_`.
- Un **componente-marco** (`lscm-master-page`) que ensambla todo.
- Servida como un **nodo** (tipo `landing`) con plantillas de tema dedicadas.
- **Textos editables** desde el admin (campos del nodo); colecciones de ítems pendientes de migrar a editables (ver §8).

---

## 2. Arquitectura de componentes (SDC)

Ubicación: `components/`. Cada componente es una carpeta con `.component.yml`, `.twig`, `.css` y `.preview.story.yml`.

### Los 8 componentes `ula_*` (piezas reutilizables)

| Componente | Rol | Props principales |
|---|---|---|
| `ula_hero_stat` | Estadística del hero | number, label |
| `ula_why_item` | Ítem "Why LSCM" | number, title, description |
| `ula_feature_item` | Feature del about | icon, title, description |
| `ula_req_card` | Tarjeta de requisito | icon, title, description |
| `ula_spec_card` | Tarjeta de especialización | icon, title, university, description, modules[], variant |
| `ula_sem_card` | Tarjeta de semestre | semester, icon, university, title, subjects[], variant |
| `ula_timeline_item` | Paso de cronología | title, description, show_line |
| `ula_uni_card` | Tarjeta de universidad | flag, country, name, abbr, description, tags[] |

### Decisiones de diseño de los componentes

- **[DECISIÓN] Prefijo `ula_` solo en nombres** de ficheros, componentes y librerías (para coexistir con componentes similares de Bootstrap Italia, p.ej. `card` vs `ula_card`). **NO** se prefijan las variables CSS (`--eu-blue`) ni las clases CSS (`.uni-card`), que se mantienen de la maqueta.
- **[DECISIÓN] Separación contenedor/ítem.** Cada `ula_*` es solo el ítem individual. Los contenedores en rejilla (`.uni-grid`, `.why-grid`, `.journey-track`) y las animaciones (`.reveal`) los aporta la sección/marco, no el componente. Patrón análogo a `timeline2` (contenedor) vs `timeline_item2` (ítem).
- **[DECISIÓN] Iconos = prop de texto con emoji** (solución simple). Iconos SVG/librería serían una sofisticación futura.
- **[DECISIÓN] Listas (modules, subjects) = prop tipo array** de strings; el Twig hace el bucle.
- **[DECISIÓN] Variantes de color = prop enum** (p.ej. `variant: primary|secondary` en spec_card; `1|2|3|4` en sem_card), que aplica clases CSS de la maqueta.
- **[DECISIÓN] `ula_journey_connector` DESCARTADO** como componente: es pura decoración del layout (línea con gradiente) que depende del grid de la sección y se oculta en móvil. Vive como CSS/markup de la sección journey en el marco. (Inventario final: 8 componentes, no 9.)
- **[DECISIÓN] Pastillas de `ula_uni_card` preparadas para interactividad futura:** `tags` es un array de objetos `{label, info}`. Hoy solo se renderiza `label` (estático, fiel a la maqueta); `info` está reservado para un popover/modal en una iteración posterior (con **API nativa** del navegador, sin Bootstrap). El Twig ya tolera `{label, info}` y cadenas simples.

---

## 3. Sistema de CSS en tres capas

- **[DECISIÓN] Capa 1 — `ula_tokens`** (`css/ula-tokens.css`): variables CSS globales (`--eu-blue`, `--eu-yellow`, `--font-display`, etc.). Se carga **siempre** en todo el tema (declarada como global en `bootstrap_ula_lscm.info.yml`).
- **[DECISIÓN] Capa 2 — `ula_landing_base`** (`css/ula-landing-base.css`): reset, `.container`, `.section-*`, `.btn-*`, `.reveal`. Depende de `ula_tokens`. **NO** es global: se carga solo cuando aparece la landing (vía `libraryOverrides` del marco — ver §4).
- **[DECISIÓN] Capa 3 — CSS por componente:** cada `ula_*` y el marco tienen su propio `.css` con sus estilos específicos. No duplican tokens ni base.

> **Mantenimiento CSS:** los nombres de variables y clases provienen de la maqueta y se mantienen sin prefijo. Al añadir estilos, respetar la capa correcta: tokens globales → capa 1; estilos compartidos de la landing → capa 2; estilos de un componente concreto → su propio `.css`.

---

## 4. El marco `lscm-master-page`

Ubicación: `components/lscm-master-page/`. Es el componente que **ensambla la landing completa**.

- **`.twig`**: define al inicio (a) los **valores por defecto de fábrica** de todas las props de texto (con `|default()`), y (b) las **colecciones** como arrays fijos (universidades, semestres, etc. — ver §8). Luego ensambla nav + hero + about + journey + universities + specializations + why + admission + "Get in touch" + footer, componiendo los 8 `ula_*` con `include()`.
- **`.component.yml`**: ~44 props de texto editables (logo, marca, textos por sección, botones de salto, contacto). Las props de **descripción** llevan `maxLength: 1000`.
- **`.css`**: solo CSS estructural (nav, hero, fondos de sección, grids contenedores, conectores del journey, footer, CTA, responsive). No duplica base ni componentes.
- **`.js`**: animaciones scroll-reveal + sombra del nav.

### Decisiones del marco

- **[DECISIÓN] `libraryOverrides` con dependencia de `ula_landing_base`.** El marco declara en su `.component.yml` que depende de `bootstrap_ula_lscm/ula_landing_base` y `core/drupal`, para que esa librería base se cargue **solo** cuando se renderiza la landing (no en todo el sitio, evitando colisiones de clases genéricas).
- **[DECISIÓN] Valores por defecto "de fábrica" en el `.twig` del componente** (con `|default()`). Motivo: SDC **no inyecta de forma fiable** los `default` del `.component.yml` al renderizar vía `include()` con props parciales. Estos defaults son el contenido "out of the box"; el contenido editable (campos del nodo) los sobreescribe. **No es hardcodear contenido:** es el estado de fábrica del componente.
- **[DECISIÓN] Menú del header = anclas internas** (`#about`, `#journey`…) para navegar dentro de la landing. **Botones de salto por sección** = enlaces a las páginas de detalle del sitio (`/about`, `/programme`…), con texto y URL editables. (Opción "C": ambas cosas.)
- **[DECISIÓN] Logo del máster** como prop `logo_url` (editable), con default `/sites/default/files/2026-06/logo-MASTER-LSCM.png`. Sustituye al SVG de estrellas de la maqueta. Su tamaño se controla con `.nav-logo-img { height: 38px }`.
- **[DECISIÓN] Sección "Get in touch"** (CTA final con email y FAQ) incluida; sus textos/URLs son props editables.
- **[PENDIENTE] Menú hamburguesa** (móvil) y **pastillas interactivas** de `ula_uni_card`: iteración posterior, con toggle propio mínimo / API nativa, sin Bootstrap. La maqueta no tiene hamburguesa (los enlaces se ocultan en móvil); añadirlo es funcionalidad nueva.

---

## 5. Cómo se sirve la landing como home

La home es un **nodo** del tipo de contenido `landing`, servido con plantillas dedicadas del tema.

- **Tipo de contenido `landing`**: contiene los campos editables de los textos (ver §6). El nodo actual de la home es **`/node/55`** ("Home Master LSCM").
- **Front page**: configurada en `admin/config/system/site-information` apuntando a `/node/55`.
- **`templates/layout/page--front.html.twig`**: plantilla de **portada**. Sobreescribe la de Bootstrap Italia y renderiza **solo** el contenido (sin header/footer/rows del tema padre), para que la landing — que trae su propia nav y footer — ocupe la página entera sin conflictos.
- **`templates/content/node--landing.html.twig`**: renderiza el nodo `landing` con el componente `lscm-master-page`, **mapeando cada campo del nodo a su prop**. Si un campo está vacío, no se pasa y el componente usa su default de fábrica.

> **[DECISIÓN] Camino elegido:** nodo + plantilla Twig (mapeo campo→prop en código), **no** Layout Builder ni UI Patterns Blocks. Motivo: UI Patterns 2.x no ofrece "renderizar entidad completa con componente" salvo vía Layout Builder (capa pesada, config en BD). La plantilla Twig es más ligera, va a git, y no mete config crítica en una BD sin gestión de configuración.

---

## 6. EDICIÓN DE CONTENIDO — guía para quien mantiene el sitio

> **Esta es la sección más importante para el mantenimiento diario.**

El contenido de la home se divide en dos familias que se editan en **sitios distintos**:

### Familia A — Textos simples → editables en el ADMIN (sin tocar código)

**Dónde:** editando el nodo de la home → `/node/55/edit` (o Content → "Home Master LSCM" → Edit).

**Qué incluye:** logo (URL), marca, y por cada sección: tag, título, descripción, y textos+URLs de los botones de salto; además email y FAQ de contacto.

**Cómo funciona:**
- Campo **con valor** → se muestra ese valor.
- Campo **vacío** → se muestra el **texto por defecto de fábrica** (el de la maqueta).

Es decir, **solo hace falta rellenar los campos que se quieran cambiar** respecto a la maqueta. Los vacíos muestran el contenido por defecto. No hay que rellenarlos todos.

### Familia B — Colecciones de ítems → HOY en código (ver §8, en migración a editable)

**Qué incluye:** las tarjetas de universidades, especializaciones, semestres del journey, why-items, pasos de la timeline de admisión, requisitos, features del about y stats del hero.

**Dónde (estado actual, provisional):** definidas como arrays al inicio de `components/lscm-master-page/lscm-master-page.twig` (bloques `{% set universities = [...] %}`, etc.). Cambiarlas requiere editar ese fichero (código → git → `ddev drush cr`).

> **IMPORTANTE:** este estado es **provisional**. La §8 describe el plan para hacer estas colecciones editables desde el admin mediante tipos de contenido + vistas.

---

## 7. Notas técnicas y restricciones del entorno

Esta sección documenta restricciones del entorno y comportamientos no evidentes de Drupal/UI Patterns que condicionan cómo se construye y mantiene este tema. No son anécdotas: cada una afecta a decisiones concretas y a cómo deben hacerse las ampliaciones futuras.

### 7.1. Sitio sin gestión de configuración (config/sync)

Drupal separa **contenido** (nodos, textos — siempre en BD) de **configuración** (tipos de contenido, campos, vistas, displays, ajustes). La configuración *puede* exportarse a ficheros YAML versionables (`config/sync`) mediante la gestión de configuración, pero **este sitio no la usa**: la configuración vive **solo en la base de datos**.

Implicaciones para el mantenimiento:

- **Git versiona el código** (tema, componentes, plantillas, este documento), **no la configuración**. El tipo de contenido `landing`, sus 42 campos, el nodo de la home, la front page y las visibilidades de bloques **no están en git**.
- **El respaldo de la configuración son los dumps de BD** (`ddev export-db`). Antes de cualquier cambio de configuración hay que hacer un dump; es la única forma de revertir.
- **Conviene evitar meter configuración pesada en BD.** Por eso se descartó Layout Builder (§5): habría añadido configuración compleja a una BD que no se versiona, haciendo el sitio más frágil de reproducir. Se prefieren mecanismos que vivan en código (plantillas Twig en el tema).
- **Riesgo conocido de `config:import`:** en este proyecto, importar configuración global ha fallado por dependencias de módulos (p.ej. `ui_patterns_field_formatters`). Evitar `config:import` / `theme:uninstall` globales; preferir cambios quirúrgicos.

### 7.2. Crear campos por código requiere tres pasos, no uno

Cuando se crea un campo desde la **interfaz** de Drupal, este encadena automáticamente tres operaciones. Al crearlo **por código** (scripts), hay que hacer las tres explícitamente, o el campo "existe" pero no se ve:

1. **`FieldStorageConfig`** — define el almacenamiento del campo (tipo de dato, cardinalidad). A nivel de entidad.
2. **`FieldConfig`** — vincula el campo a un bundle concreto (aquí, el tipo `landing`) con su etiqueta.
3. **Registro en el form display** — añade el campo al **formulario de edición** con su widget. **Sin este paso, el campo existe en la entidad pero no aparece al editar el nodo** (fue exactamente lo que ocurrió al crear los 42 campos por script).

Recomendación adicional: asignar el **`weight`** de cada campo por secciones desde el inicio, o el formulario queda en orden de creación/alfabético (poco usable con decenas de campos). Ver scripts en `scripts/` como referencia.

### 7.3. Límite de longitud en props de texto (UI Patterns / campos string)

Los campos de tipo `string` (texto plano) tienen un límite por defecto de **128 caracteres**. Las **descripciones** de la landing superan ese límite, lo que provoca un error al guardar ("cannot be longer than 128 characters").

- En el **`.component.yml`** del marco, las props de descripción declaran `maxLength: 1000`.
- Los **campos** de descripción del tipo `landing` se crearon como `string_long` (texto largo), no `string`.
- Al añadir nuevas props/campos de texto extenso, aplicar el mismo criterio.

### 7.4. `default` de SDC no se inyecta de forma fiable en runtime

Los valores `default` declarados en el `.component.yml` se usan para validación y para la galería, pero **no se inyectan de forma garantizada** cuando el componente se renderiza vía `include()` con un objeto de props parcial: las props ausentes quedan vacías en lugar de tomar su default.

- **Solución aplicada (§4):** los valores de fábrica se definen en el **`.twig` del componente** con el filtro `|default()`. Así el componente se ve completo aunque no se le pase nada, y los campos del nodo sobreescriben esos valores cuando tienen contenido.
- Al añadir props nuevas con valor por defecto, definir el default con `|default()` en el `.twig`, no confiar solo en el `.component.yml`.

### 7.5. `position: fixed` y entornos de previsualización

La barra de navegación de la landing usa `position: fixed`, que la ancla a la **ventana del navegador**, no a su contenedor. Consecuencias observadas:

- En la **galería de UI Patterns** (`/admin/appearance/ui/components`), el nav fijo se solapa con la barra de administración → la galería **no sirve** para validar páginas completas con elementos fijos; sirve para componentes sueltos.
- Incrustada como bloque dentro de la plantilla del tema padre, el nav fijo choca con el header de Bootstrap Italia.
- **Por eso** la landing se sirve como **página completa** mediante `page--front.html.twig` (§5), sin el chrome del tema padre.

### 7.6. Método de trabajo recomendado

- **Validar la tubería completa con un caso mínimo** antes de replicar a escala (se validó la editabilidad con un solo campo antes de crear los 42; se validará una colección piloto antes de migrar las 8 — §8).
- **Dump de BD antes de cada cambio de configuración.**
- **Consolidar en git por hito**, y verificar que el repositorio y el entorno de trabajo coinciden tras cada push.
- **Preferir el método menos invasivo primero**; evitar operaciones globales de configuración.

---

## 8. Pendientes de la home

Pendientes específicos de la home. (Los pendientes transversales del tema están en `TODO.md` en la raíz del tema.)

### 8.1. Colecciones editables (tipos de contenido + vistas) — EN CURSO

**Estado:** las 8 colecciones están hoy como datos fijos en el `.twig` del marco (decisión **provisional** para desbloquear la home). Plan acordado: migrarlas a **tipos de contenido + vistas**, reutilizando el patrón que el sitio ya usa (la timeline de Admissions: nodos `ct_admission_preenrolment_step` listados por una vista y pintados con `timeline_item2` vía `ui_patterns_views`).

**Mecanismo por colección:**
1. Un **tipo de contenido** con los campos del ítem.
2. **Nodos** (el contenido editable).
3. Una **vista** que los lista y los pinta con el componente `ula_*` correspondiente (vía `ui_patterns_views`, mapeando campos → props).
4. Integrar la vista en la landing en lugar de la colección fija.

**Colecciones a migrar:** universidades (`ula_uni_card`), especializaciones (`ula_spec_card`), semestres (`ula_sem_card`), why-items (`ula_why_item`), timeline (`ula_timeline_item`), requisitos (`ula_req_card`), features (`ula_feature_item`), stats del hero (`ula_hero_stat`).

**Método previsto:** validar el patrón con una colección piloto (probablemente **universidades**) antes de replicar a las demás. Decidir, por colección, si el contenido tendrá página de detalle propia (reutilizable) — lo que refuerza el enfoque nodos+vistas.

### 8.2. Menú hamburguesa (móvil)

La maqueta oculta los enlaces de navegación en móvil sin sustituirlos. Pendiente: añadir un menú hamburguesa que use el **menú principal de Drupal** (entradas reales del sitio) con un **toggle propio mínimo** (sin Bootstrap, sofisticable más adelante). Es funcionalidad nueva, no presente en la maqueta.

### 8.3. Pastillas interactivas de `ula_uni_card`

Las pastillas (`tags`) de las tarjetas de universidad están preparadas como `{label, info}` pero hoy se renderizan estáticas (solo `label`). Pendiente: convertirlas en botones que abran un popover/modal con el contenido de `info`, usando la **API nativa** del navegador (`popover` / `<dialog>`), sin Bootstrap.

### 8.4. Limpieza: eliminar la vista vieja `page_home`

Al cambiar la front page al nodo `landing` (`/node/55`), la vista `page_home` (antigua home, ruta `/home2`) quedó **huérfana**. Pendiente eliminarla cuando se confirme que no se necesita. (Reversible mientras exista; el dump previo la conserva.)

---

## 9. Inventario de ficheros (esta versión)

```
bootstrap_ula_lscm/
├── bootstrap_ula_lscm.info.yml          # base theme: bootstrap_italia; carga ula_tokens global
├── TODO.md                              # Pendientes transversales del tema
├── bootstrap_ula_lscm.libraries.yml     # define ula_tokens y ula_landing_base
├── css/
│   ├── ula-tokens.css                   # Capa 1: variables globales
│   └── ula-landing-base.css             # Capa 2: base de la landing
├── components/
│   ├── ula_hero_stat/  ula_why_item/  ula_feature_item/  ula_req_card/
│   ├── ula_spec_card/  ula_sem_card/  ula_timeline_item/  ula_uni_card/
│   ├── lscm-master-page/                # El marco (ensambla todo)
│   └── lscm-master-static/              # Maqueta original (referencia, no se usa en producción)
├── templates/
│   ├── layout/page--front.html.twig     # Portada sin chrome del tema padre
│   └── content/node--landing.html.twig  # Mapea campos del nodo → props del marco
└── docs/
    └── DISENO-Y-MANTENIMIENTO.md         # Este documento
```

> Scripts de configuración (no en el tema, en la raíz del proyecto): `crear-campos-landing.php`, `anadir-campos-formdisplay.php`, `ordenar-campos-landing.php` — crean y ordenan los campos del tipo `landing`. Útiles como referencia para ampliar campos.
