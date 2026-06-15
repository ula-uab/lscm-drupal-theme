# Análisis técnico — Página «About» heredada

> **Tipo de documento:** análisis de una **página preexistente/heredada** (no diseñada por nosotros),
> documentada para investigación y para la fase de migración a un tema independiente de Bootstrap
> Italia. Ver convención en `docs/analysis/` (*analysis = lo que investigamos; entities = lo que
> diseñamos*).
>
> **Alcance:** este documento analiza los **aspectos técnicos** (flujo contenido → visualización,
> mecanismos y dependencias de Bootstrap Italia), **no el contenido editorial** de la página (que es,
> en su estado actual, un banco de pruebas con textos de marcador de posición). El objetivo es
> identificar qué es técnicamente reutilizable y qué hay que sustituir al rehacer la página en clave
> `ula_*` / `lscm_*`.
>
> **Página piloto.** «About» es la primera página que se aborda en la fase de independencia de
> Bootstrap Italia. Es **sencilla pero representativa**: el patrón estructural que usa (vista + bloque
> de contenido `lscm_*` + UI Patterns) se repite en otras páginas heredadas (ver §5).

---

## 1. Qué es «About», técnicamente

La página servida en `/about` **no es un nodo**: es una **vista de Drupal** (Views).

- **Ruta:** `/about` → nombre de ruta `view.page_about.page_1` (no `entity.node.canonical`).
- **Vista:** `page_about` («Page - About»), con dos displays:
  - `default` — contiene toda la configuración real (la fila, los campos, el ensamblaje).
  - `page_1` — el display de tipo *page* que expone la ruta `/about`.
- **Base de la vista:** `block_content_field_data` → la vista consulta **bloques de contenido**
  (`block_content`), no nodos ni términos.

---

## 2. Flujo contenido → visualización

### 2.1. Contenido (de dónde sale)

La vista filtra y muestra **un único bloque de contenido**:

- **Filtros de la vista:** `status = 1` (publicado) · `reusable = 1` (reutilizable) ·
  `type = lscm_about_page`.
- **Bloque mostrado:** `lscm_about_page` (id 2, «LSCM About Page Content»).

**Campos del tipo de bloque `lscm_about_page`:**

| Campo | Etiqueta | Tipo |
|---|---|---|
| `body` | Body | text_with_summary |
| `field_p_about_what_text` | About - What - Text | text_long |
| `field_p_about_where_text` | About - Where - Text | text_long |
| `field_p_about_why_text` | About - Why - Text | text_long |
| `field_p_about_stdalu_image` | About - Students & Alumni - Image | entity_reference (imagen) |

> **Nota sobre el estado del contenido (no objeto de este análisis, pero relevante técnicamente):** en
> el estado actual solo el `body` contiene texto real; los tres campos de texto tienen marcadores de
> posición y el campo «What» está **definido pero no se usa** en el ensamblaje de la vista. Es
> coherente con un banco de pruebas, no con una página terminada. Para la migración, esto significa
> que **no hay un diseño ni un contenido editorial que preservar**; lo único técnicamente relevante es
> el modelo de campos (por si se reutiliza alguno) y el flujo.

### 2.2. Presentación (cómo se ensambla y se pinta)

La fila de la vista se renderiza con el plugin de fila **UI Patterns** (`row: ui_patterns`). El
ensamblaje es un **componente contenedor** que envuelve una secuencia de slots:

- **Contenedor:** componente `bootstrap_ula_lscm:grid_row` (una rejilla del tema base).
- **Secuencia de slots `content`** (en orden):
  1. El campo `body` del bloque (volcado directo, vía `ui_patterns_views_field`).
  2. Un WYSIWYG **hardcodeado en la vista**: `<h2>Where</h2>` (formato `basic_html`).
  3. El campo `field_p_about_where_text`.
  4. La **subvista embebida** `page_about_consortium` (ver §4).
  5. Un WYSIWYG hardcodeado: `<h2>Why</h2>`.
  6. El campo `field_p_about_why_text`.
  7. Un WYSIWYG hardcodeado: `<h2>Students &amp; Alumni</h2>`.
  8. Un **componente `bootstrap_ula_lscm:card`** (variante `horizontal`) que contiene:
     - *slot image:* el campo `field_p_about_stdalu_image`.
     - *slot content:* un WYSIWYG hardcodeado `<p>This text is hardcoded for now</p>`
       (formato `bootstrap_italia_2`).

En resumen, el flujo es: **vista → toma un bloque `lscm_about_page` → lo ensambla con UI Patterns
combinando campos del bloque, textos hardcodeados en la propia vista, una subvista embebida y
componentes del tema base (grid_row, card) → lo presenta en `/about`.**

---

## 3. Dependencias de Bootstrap Italia identificadas

Estas son las dependencias que hay que **eliminar** al rehacer la página (no introducir ninguna nueva,
regla general del proyecto). Ordenadas de mayor a menor acoplamiento:

1. **Componentes del tema base (Bootstrap Italia):** el ensamblaje usa `bootstrap_ula_lscm:grid_row` y
   `bootstrap_ula_lscm:card` (variante `horizontal`). Son componentes heredados (no del design system
   `ula_*`), basados en la rejilla y las tarjetas de Bootstrap.
2. **Clases de rejilla de Bootstrap en el markup**, hardcodeadas en la configuración del `card`:
   `class="col-md-4"`, `class="col-md-8"`, `class="g-0"`. Dependencia directa del sistema de rejilla
   de Bootstrap.
3. **Formato de texto `bootstrap_italia_2`:** uno de los WYSIWYG incrustados usa este formato, que
   puede inyectar markup/clases de Bootstrap Italia. (Los campos del propio bloque usan `basic_html`,
   que es el formato correcto y respetuoso con la independencia.)
4. **El mecanismo de presentación en sí (Views + UI Patterns):** ajeno al patrón adoptado para la home
   (nodo + plantilla Twig, ADR-001 en `../elements/home/HOME-ARCHITECTURE.md`). No es una dependencia
   de Bootstrap Italia *per se*, pero sí un flujo distinto cuya sustitución hay que decidir en el plan.

> **Contenido incrustado en la configuración de la vista.** Parte del texto visible (los encabezados
> `<h2>Where</h2>` / `<h2>Why</h2>` / `<h2>Students &amp; Alumni</h2>` y el `<p>This text is hardcoded
> for now</p>`) **no vive en el bloque**, sino **escrito a mano dentro del ensamblaje de la vista**. No
> es contenido editable: es configuración. Técnicamente relevante porque, al rehacer la página, ese
> texto estructural debe pasar a donde corresponda (plantilla o contenido editable), no perderse ni
> quedar incrustado en una vista.

---

## 4. Dependencia aparte: la subvista `page_about_consortium`

El slot 4 del ensamblaje embebe **otra vista distinta**, `page_about_consortium` (display `default`),
que presenta el **consorcio de universidades** dentro de la página About.

- **No se analiza en este documento.** Es una pieza con entidad propia que merece su propio análisis,
  previsiblemente ligado a la **futura página Consortium** (ya prevista como consumidora de la relación
  universidad↔semestre; ver ADR-004 en `../elements/home/HOME-ARCHITECTURE.md`).
- **Implicación para la migración de About:** al rehacer About hay que **decidir qué hacer con esta
  subvista** — si se mantiene embebida (analizándola y migrándola aparte), si se enlaza a una futura
  página Consortium independiente, o si se omite en la nueva About. Queda como **dependencia
  identificada, pendiente de análisis propio**.

---

## 5. Patrón estructural común del sitio heredado

«About» no es un caso aislado: el sitio heredado modela **cada página como un tipo de bloque de
contenido `lscm_*`**, servido por una vista. Tipos de bloque de contenido existentes:

| Tipo de bloque (`block_content_type`) | Etiqueta | Bloque existente (id) |
|---|---|---|
| `lscm_home_page` | LSCM Home Page | id 1 |
| `lscm_about_page` | LSCM About Page | id 2 |
| `lscm_contents_page` | LSCM Contents Page | id 3 |
| `lscm_admission_page` | LSCM Admission Page | id 4 |
| `lscm_elegibility_page` | LSCM Elegibility Page | id 5 |

(Conviven con otros tipos de bloque de distintas épocas del desarrollo: `basic`, `component_block`,
`reusable_block` («Pattern»), `ula_landing`.)

**Implicaciones:**
- El método que se diseñe para migrar «About» será **reutilizable** para las demás páginas heredadas
  (Contents, Admission, Elegibility), que comparten el mismo patrón estructural. Esto refuerza el valor
  de «About» como piloto representativo.
- Existe un `lscm_home_page` (id 1): la home heredada usaba este mecanismo (vista + bloque), hoy
  sustituida por la home como nodo + plantilla Twig. Es el rastro a seguir cuando se aborde la
  limpieza de la vista heredada `page_home` (TO-DO transversal, condicionado al avance de
  independencia de BI).

---

## 6. Qué es reutilizable y qué se descarta (resumen para el plan)

| Elemento | ¿Reutilizable? | Observación |
|---|---|---|
| Modelo de campos del bloque `lscm_about_page` | **Posiblemente** | El esquema (textos + imagen) puede servir de base, decidiéndolo en el plan. El prefijo `lscm_*` ya es coherente con la nomenclatura del proyecto. |
| Contenido del `body` | Marginal | Único texto real; decisión editorial, fuera de este análisis. |
| Estructura semántica (What/Where/Why/Students & Alumni) | Como *idea* | Esqueleto razonable para un About; la presentación se rehará. |
| Componentes `grid_row` / `card` (BI) | **No** | Se sustituyen por componentes `ula_*` propios. |
| Clases Bootstrap (`col-md-*`, `g-0`) | **No** | Se sustituyen por el CSS propio del componente. |
| Formato `bootstrap_italia_2` | **No** | Se usa `basic_html` (no inyecta markup de BI). |
| Mecanismo Views + UI Patterns | **A decidir en el plan** | Flujo distinto al de la home; el plan decidirá el flujo de la nueva página. |
| Subvista `page_about_consortium` | **A decidir (análisis aparte)** | Ver §4. |

> **Siguiente paso (fase de plan).** Con este análisis cerrado, el siguiente paso del método es
> **elaborar el plan de diseño e implementación** de la nueva página «About» (en `docs/plans/`), en
> clave `ula_*` / `lscm_*`, sin dependencias de Bootstrap Italia, bajo el header/footer compartido que
> se construya para las páginas internas. El plan decidirá el flujo (cómo se sirve la página y cómo se
> presenta) y qué se hace con la subvista del consorcio.
