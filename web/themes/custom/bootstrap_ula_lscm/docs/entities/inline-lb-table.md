# Entidad — bloque de contenido `inline_lb_table` (tabla de contenido)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Naturaleza:** **ficha de entidad** de un artefacto de la librería de inline blocks. Reúne dos partes:
> primero la **especificación de diseño** con la que se construyó —**requerimientos funcionales** (§2),
> **diseño visual** (§3) y **forma de implementación** (§4)—, y después las secciones **as-built** que se
> añaden tras implementar y validar: **modelo de datos** (§7), **cómo se consume** (§8) y **decisiones de
> implementación** (§9). La entidad de diseño `ula_table` se materializó como el **tipo de bloque**
> `inline_lb_table` (con el paragraph anidado `inline_lb_p_trow`); el documento se renombró de
> `ula-table.md` a `inline-lb-table.md` para alinearse con la convención de la familia (`inline-lb-*.md`).
>
> **Estado:** **implementado y validado** en el Drupal real (v1.8.1). El §5 («pendiente de diseño técnico»)
> queda **resuelto**: sus decisiones se registran en el §9. La especificación de diseño (§2–§6) se conserva
> íntegra como fuente del *porqué*; donde el diseño y lo construido difieran, **manda la parte as-built**.
>
> **Relación:** la **forma de implementación** (§4) ancla la tabla a la familia de inline blocks; ver
> `../elements/layout/INLINE-BLOCKS-CATALOG.md` y `../elements/layout/CONTENT-LAYOUT.md` (§11,
> ADR-LAYOUT-005). El **diseño visual** (§3) se apoya en los tokens de `../../css/ula-tokens.css`.

---

## 1. Qué es y por qué existe

`ula_table` modela **contenido en forma de tabla**, definible por el editor y con una **estética
homogénea en todo el sitio**. Cubre la necesidad de presentar datos tabulares (requisitos, comparativas,
calendarios, listados con cabeceras) sin recurrir a la tabla heredada de Bootstrap Italia (componente
`table`, basado en `.table`/`.table-*`), en línea con la dirección estratégica de independencia de BI.

El elemento se caracteriza en tres capas, deliberadamente separadas:

- **§2 — Requerimientos funcionales:** *qué hace y qué permite* (agnóstico del mecanismo y del aspecto).
- **§3 — Diseño visual:** *qué aspecto tiene* (validado contra maqueta).
- **§4 — Forma de implementación:** *cómo se construye* (mecanismo fijado por el proyecto).

---

## 2. Requerimientos funcionales

Enunciados como requisitos verificables, desde el punto de vista de quien compone el contenido (el
editor) y de cómo se consume. Independientes del mecanismo (§4) y del aspecto visual (§3).

### 2.1. Propósito

- **RF-01.** El elemento debe permitir definir contenido en forma de tabla, reutilizable en cualquier
  página del sitio, con una estética única y homogénea.

### 2.2. Composición estructural

La tabla se organiza sobre un eje de **m columnas**, con **m variable** (**mínimo 1**; **máximo 10**, tope
práctico por legibilidad y comportamiento responsive). Sobre ese eje:

- **RF-02.** Debe soportar una fila **header** **opcional** que **ocupa las m columnas en una sola celda
  combinada**.
- **RF-03.** Debe soportar una fila **sub-header** **opcional** con **una celda por columna** (m celdas).
- **RF-04.** Debe soportar de **1 a n filas de contenido**, cada una con **una celda por columna** (m
  celdas). **Al menos una** fila de contenido es obligatoria.
- **RF-05.** Debe soportar una fila **footer** **opcional** con **una celda por columna** (m celdas).

### 2.3. Configuración / opciones

- **RF-06.** header, sub-header y footer deben poder activarse/desactivarse de forma **independiente**.
- **RF-07.** Debe existir una opción **«la primera columna es de títulos»** (sí/no). Cuando está activa,
  la primera celda de cada fila de contenido se trata como **celda de título**, con tratamiento visual y
  semántico propio (§3).

### 2.4. Contenido

- **RF-08.** El contenido de toda celda es **texto plano** (sin texto enriquecido), para **primar la
  facilidad de entrada de datos**.
- **RF-09.** El tipo de contenido es **el mismo en todas las partes** (header, sub-header, filas de
  contenido, footer): texto plano.

### 2.5. Comportamiento

- **RF-10.** La tabla debe tener un **comportamiento responsive** (requisito funcional, no solo visual).
  *La forma concreta de ese comportamiento (p. ej. scroll horizontal frente a apilado en móvil) queda por
  especificar.*

### 2.6. Invariantes

- **RF-11.** sub-header, filas de contenido y footer tienen **una celda por columna**: todas comparten el
  mismo número de columnas (m). El header es el único que abarca las m columnas en **una celda combinada**.

### 2.7. Consistencia e independencia (restricciones de proyecto)

- **RF-12.** Estética **única y homogénea** en todo el sitio; el elemento es **reutilizable** en cualquier
  página.
- **RF-13.** **Sin Bootstrap Italia**: el elemento no introduce markup ni clases de BI. El estilado lo
  aporta el design system `ula_*`.

---

## 3. Diseño visual

> **Fuente de verdad del aspecto:** esta sección. La maqueta HTML usada para validar (`maqueta-ula-table`)
> es solo su **comprobación visual**; donde difieran, **manda esta especificación**.

### 3.1. Modelo estructural (recordatorio)

El de §2.2: header (celda combinada a m columnas, opcional) · sub-header (m, opcional) · filas de
contenido (n × m, ≥ 1) · footer (m, opcional). Tipografía **toda en Manrope** (`--font-body`); la display
(Playfair) queda reservada al hero, no se usa aquí.

### 3.2. Especificación visual por parte

Todos los valores derivan de tokens `ula_*` (`css/ula-tokens.css`); no hay colores sueltos.

| Parte | Relleno | Color texto | Tamaño letra | Peso |
|---|---|---|---|---|
| **header** | `--eu-blue` (`#003399`) | `--white` | `1.125rem` | 700 |
| **sub-header** | `--border` (`#d0d9ef`) | `--text-dark` | `0.95rem` | 700 |
| **filas de contenido** | `--off-white` (`#f4f6fc`) | `--text-mid` | `0.9rem` | 400 |
| **columna de títulos** (1.ª col., si opción activa) | `color-mix(in srgb, var(--border) 30%, var(--off-white))` ≈ `#e9edf8` | `--text-dark` | `0.9rem` | 700 |
| **footer** | `--border` (`#d0d9ef`) | `--text-dark` | `0.95rem` | 700 |

La jerarquía de relleno es una rampa de cuatro niveles dentro del propio sistema: azul profundo (header) →
azul pálido (sub-header / footer) → azul muy suave (columna de títulos) → casi blanco (contenido).

### 3.3. Reglas de relleno

- La **columna de títulos no comparte** el relleno del sub-header: usa un tono propio, **un punto más
  claro**, derivado por mezcla de los tokens `--border` y `--off-white` (30 % / 70 %) para quedar *entre*
  ambos —más claro que el sub-header/footer, pero por encima del relleno de contenido para que la columna
  se lea como títulos—. (Esta regla **anula** el enunciado inicial de que la columna de títulos usaría el
  relleno del sub-header.)
- El **footer sí** mantiene relleno y tamaño del sub-header (`--border`, `0.95rem` / 700).

### 3.4. Reglas de marcado / CSS

- **Contenedor (wrapper):** `border: 1px solid var(--border)`, `border-radius: var(--radius)` (12px) y
  `overflow: hidden` para **recortar las esquinas de las bandas** al radio.
- **Tabla:** `border-collapse: collapse`; separadores de fila con `1px solid var(--border)`; el **footer
  sin borde inferior**.
- **Semántica:** la celda combinada del header va como `<th colspan="m" scope="colgroup">`; la celda de
  título de cada fila (cuando la opción está activa) va como **`<th scope="row">`** (cabecera de fila),
  no como `<td>`.

### 3.5. Decisiones de diseño visual a arrastrar a la implementación

- El relleno de la columna de títulos (`#e9edf8`) **no es hoy un token**; vive como `color-mix` de dos
  tokens existentes, por lo que **sigue dentro del sistema**. Si en implementación resulta recurrente,
  **promoverlo a token propio** en `css/ula-tokens.css` (p. ej. `--ula-table-title-fill`) en lugar de
  repetir el `color-mix`. Decisión a tomar en su fase, no antes.
- `color-mix()` requiere navegadores modernos (Chrome 111+, Safari 16.2+, Firefox 113+); sin impacto para
  este proyecto, anotado por rigor.

---

## 4. Forma de implementación (requisito de mecanismo)

> Esto **no** es un requerimiento funcional (el «qué hace»), sino una **restricción sobre la forma de
> implementación** (el «cómo se construye»). Se enuncia explícitamente porque fija el elemento dentro del
> patrón ya establecido de la librería inline, en lugar de dejar que quien implemente invente un mecanismo
> nuevo.

La tabla debe implementarse como un **artefacto de la librería de inline blocks** (`inline_lb_*`) del
tema: un **tipo de bloque de contenido (`block_content`) colocado como inline block de Layout Builder
(Core)**, compartiendo las convenciones de esa familia, conforme al catálogo
(`../elements/layout/INLINE-BLOCKS-CATALOG.md`) y a la guía/ADR de `../elements/layout/CONTENT-LAYOUT.md`
(§11, ADR-LAYOUT-005). El principio que lo sostiene está en el propio catálogo: el contenido **específico
de la página** (no compartido entre páginas) se sirve como inline block; una tabla de contenido encaja ahí.

- **Naming de la familia.** El tipo de bloque sigue el patrón `inline_lb_*` (por la convención,
  `inline_lb_table` — **nombre a confirmar**); su plantilla,
  `block--block-content--type--inline-lb-table.html.twig`; los paragraph types asociados, si los hubiera,
  `inline_lb_p_*`.
- **Composición en la plantilla (anti-BI).** El render se compone en la plantilla del bloque leyendo la
  entidad —pasando valores planos al componente de presentación—, **nunca enrutando por
  `field.html.twig`** ni introduciendo markup/clases de Bootstrap Italia. El estilado lo aporta el design
  system `ula_*`.
- **Armazón estándar de bloque inline.** La plantilla incluye el armazón obligatorio (`attributes`,
  `title_prefix`, `{% if label %}`, `title_suffix`) para que el lápiz de edición de Layout Builder no
  desaparezca.
- **CSS como librería registrada.** Los estilos propios del artefacto se registran como librería en
  `bootstrap_ula_lscm.libraries.yml` y se adjuntan con `attach_library` desde la plantilla (no carga
  global).
- **Configuración en BD, no en git.** El tipo de bloque, sus campos y los ejemplares viven en la base de
  datos (el sitio no tiene gestión de configuración); el repo versiona plantilla, CSS y librería. Dump
  previo a cualquier cambio de configuración.

---

## 5. Pendiente de diseño técnico (lo que este documento NO fija aún)

Estas decisiones se toman en la **fase de diseño técnico**, partiendo del catálogo y de la naturaleza
estructurada de la tabla; **no se infieren** en esta especificación:

- La **modalidad concreta** del artefacto dentro de la librería: A (texto), B (campos estructurados →
  composición de SDC `ula_*`) o C (stack de paragraphs heterogéneos).
- Si la presentación se encapsula en un **componente SDC `ula_table`** dedicado que la plantilla del
  bloque compone, y su contrato de props/slots.
- El **modelo de campos** del tipo de bloque (cómo se capturan m, las partes opcionales, el flag «primera
  columna de títulos» y las celdas de texto plano).
- La **forma concreta del comportamiento responsive** (RF-10): scroll horizontal, apilado u otra.
- Promoción (o no) del relleno de la columna de títulos a token (§3.5).

Al cerrarse e implementarse, se añaden a este documento las secciones de **modelo de datos** y **cómo se
consume**, y se actualiza el estado de la cabecera.

> **Resuelto (v1.8.1).** Estas decisiones se cerraron al implementar y validar; cada una se registra en el
> **§9 («Decisiones de implementación»)**. El **modelo de datos** as-built está en el **§7** y el **consumo**
> en el **§8**. Esta sección §5 se conserva como traza de lo que quedaba abierto en la fase de diseño.

---

## 6. Relación con otros

- **Familia:** **miembro** de la librería de inline blocks (`inline_lb_*`); comparte patrón con
  `inline-lb-statgrid.md`, `inline-lb-section-header.md`, `inline-lb-richtext.md`, `inline-lb-steps.md`,
  `inline-lb-pills.md`, `inline-lb-cardgrid.md` e `inline-lb-stack.md`.
- **Sustituye** (a futuro, en el contenido que lo adopte) el uso de la tabla heredada de Bootstrap Italia
  (componente `table`).
- **Tokens:** `../../css/ula-tokens.css`.

---

## 7. Modelo de datos (as-built)

El artefacto se compone de **dos** entidades de configuración propias: el **tipo de bloque** y **un único
tipo de paragraph de fila**, reutilizado en las tres posiciones de fila (sub-header, contenido y footer).

### 7.1. Tipo de bloque `inline_lb_table`

| Campo | Tipo | Card. | Por defecto | Para qué |
|---|---|---|---|---|
| **Block description** (`info`, base) | — | 1 | — | Nombre **administrativo** del ejemplar; identifica el inline block. **No** se muestra al visitante. |
| `field_inline_lb_tb_cols` | integer (`min` 1, `max` 10) | 1 | **3** | `m` = nº de columnas. Gobierna el `colspan` de la celda combinada del header y **cuántas celdas pinta la plantilla por fila** → garantiza que todas las filas comparten `m` (RF-11). |
| `field_inline_lb_tb_header` | string | 1 | — | Celda **combinada** del header a `m` columnas (RF-02). Se pinta **si no está vacía** (activación por presencia, RF-06). |
| `field_inline_lb_tb_titlecol` | boolean | 1 | **No** | Opción «la primera columna es de títulos» (RF-07). Cuando está activa, la 1.ª celda de cada **fila de contenido** se trata como celda de título. |
| `field_inline_lb_tb_subheader` | Paragraphs (`inline_lb_p_trow`) | 0..1 | — | Fila **sub-header** opcional (RF-03): sus celdas son las cabeceras de columna. Activación por presencia. |
| `field_inline_lb_tb_rows` | Paragraphs (`inline_lb_p_trow`) | **1..n** (requerido) | — | Filas de **contenido** (RF-04). **Al menos una** obligatoria. |
| `field_inline_lb_tb_footer` | Paragraphs (`inline_lb_p_trow`) | 0..1 | — | Fila **footer** opcional (RF-05). Activación por presencia. |

### 7.2. Tipo de paragraph `inline_lb_p_trow` (una fila)

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `field_inline_lb_tr_cells` | string | **multivalor (cardinalidad fija 10)** | Las celdas de la fila (texto plano, RF-08/09). La plantilla pinta **exactamente `m`** celdas: rellena con vacío las que falten y **ignora** las que sobren (enforce de RF-11). Sobre la cardinalidad fija 10 y su efecto en la UX de entrada, ver §9. |

**Por qué un solo paragraph type reutilizado en tres sitios.** sub-header, filas de contenido y footer
comparten **estructura** (`m` celdas de texto plano); lo que cambia es el **rol**, y el rol lo da el **campo
del bloque** que referencia al paragraph, no el tipo. El **header** es la excepción (una sola celda
combinada) → se modela como `string` en el bloque, sin paragraph.

**Por qué `m` como `integer` y no `list_string`.** En este sitio crear campos `list_string` por script
**falla** (ver `../ARCHITECTURE.md` §6.7); una opción **numérica** se modela como `integer` (scriptable, sin
paso por UI), igual que en `inline_lb_cardgrid` (`field_inline_lb_cg_cols`). Que `m` gobierne el render da el
invariante de columnas (RF-11) **por construcción**.

**Por qué activación por presencia y no booleanos.** RF-06 (header, sub-header y footer activables de forma
independiente) se cumple con **campo opcional vacío / paragraph ausente = desactivado**, sin añadir campos
booleanos de visibilidad.

**Convención de nombres.** `inline_lb_*` (tipo de bloque), `inline_lb_p_*` (paragraph), `field_inline_lb_*`
(campos) — decisión transversal **D6** del plan. Abreviaturas: `tb` = **t**a**b**le (campos del bloque),
`tr` = **t**able **r**ow (campos del paragraph).

**Acortamiento de machine name.** El flag de RF-07 se nombró **`field_inline_lb_tb_titlecol`** y **no**
`field_inline_lb_tb_first_col_titles`: este último tiene **35 caracteres** y supera el **límite de 32** que
Drupal impone a los nombres de campo.

---

## 8. Cómo se consume (lógica en el tema)

El bloque se **crea y coloca** desde el Layout Builder de la página (*Add block → Create custom block →
inline_lb_table*), con la casilla **«Display title» desmarcada**. El flujo de render:

1. **Plantilla del bloque** `templates/content/block--block-content--type--inline-lb-table.html.twig`. La
   sugerencia `block--block-content--type--<bundle>` es la que emite Layout Builder (mismo patrón que el
   resto de la familia).
2. **Armazón estándar de bloque — imprescindible en un inline block.** La plantilla emite
   `<div{{ attributes }}>` + `{{ title_prefix }}` + `{% if label %}…{% endif %}` + `{{ title_suffix }}`. El
   control de Layout Builder (lápiz Configure/Move/Remove) viaja en `title_suffix`/`attributes`; **sin ese
   armazón, el inline block no se puede editar** (lección documentada en
   `../elements/layout/CONTENT-LAYOUT.md` §11.3–§11.4.1).
3. **Composición en la propia plantilla (no por `{{ content.field }}`).** Se lee la entidad del bloque y, por
   cada paragraph de fila, sus celdas como **valor plano** (`item.value`); un **macro de fila** (`trow`)
   pinta **exactamente `m`** celdas (rellena/trunca). Al leer valores planos, el render **no** atraviesa
   `field.html.twig` (que en este subtema sirve **Bootstrap Italia**). Por eso el artefacto **no** depende
   del view display del campo Paragraphs (igual que `inline_lb_statgrid`/`inline_lb_stack`).
4. **Semántica (HTML accesible).** header → `<th colspan="m" scope="colgroup">`; sub-header → `<th
   scope="col">` (cabeceras de columna); 1.ª celda de cada fila de contenido → `<th scope="row">` si
   `titlecol` está activo, resto `<td>`; footer → `<td>`. El texto va siempre **autoescapado** (RF-08).
5. **CSS — librería propia registrada.** Los estilos viven en `css/inline-lb-table.css`, registrados como
   librería `inline_lb_table` en `bootstrap_ula_lscm.libraries.yml` y adjuntados con `attach_library` desde
   la plantilla (no carga global). Aportan `.ula-table` y sus modificadores sobre tokens `ula_*` (rampa de
   azules); el relleno de la columna de títulos se compone con `color-mix` de dos tokens (ver §9). Footer y
   última fila sin borde inferior; **responsive por scroll horizontal** del wrapper (`overflow-x: auto`).

> **Configuración en BD, no en git.** El tipo de bloque `inline_lb_table`, el paragraph `inline_lb_p_trow`,
> sus campos, los form displays y cada ejemplar colocado son **configuración/contenido**: viven en la base de
> datos, no en el repositorio (ver `../ARCHITECTURE.md`, separación de fuentes de verdad). El repo solo
> versiona el **código**: la plantilla del bloque, el CSS y la entrada de `libraries.yml`. La configuración se
> creó con un **script de un solo uso** (no versionado). Cualquier operación sobre esta configuración exige
> **dump previo** de la BD.

---

## 9. Decisiones de implementación (as-built)

Resuelven los puntos que el §5 dejaba abiertos y registran las decisiones tomadas al construir y validar.

- **Modalidad (resuelve §5).** Variante del mecanismo **C** (Paragraphs multivalor para las filas) pero
  **homogénea**: todas las filas son del mismo paragraph `inline_lb_p_trow`; el rol (sub-header / contenido /
  footer) lo da el campo del bloque que lo referencia, no el tipo. La **presentación** se compone en la
  plantilla del bloque (un `<table>` propio) con **CSS propio por librería** (patrón de `richtext`/`stack`),
  **no** reutilizando ningún SDC ni el componente `table` de Bootstrap Italia.
- **SDC dedicado `ula_table`: NO (resuelve §5).** La tabla es **una estructura autocontenida** (un único
  `<table>`), no una composición de subcomponentes reutilizables; pasar un grid 2D (filas × celdas + cabecera
  + flags) por props/slots añadiría un contrato complejo **sin caso de reutilización presente**, y la familia
  ya tiene precedente de «librería CSS propia + composición en plantilla» (`richtext`, `stack`). Si a futuro
  hiciera falta una tabla servida por **Views**, se promovería entonces a SDC; hoy no se justifica.
- **Modelo de campos (resuelve §5).** El descrito en el §7 (`cols` integer, `header` string, `titlecol`
  boolean, y `subheader`/`rows`/`footer` como Paragraphs sobre un mismo `inline_lb_p_trow` con celdas
  `string` multivalor).
- **Comportamiento responsive (RF-10, resuelve §5).** **Scroll horizontal**: el wrapper `.ula-table` desborda
  en X (`overflow-x: auto`) y recorta las esquinas de las bandas al radio (`overflow-y: hidden`).
- **Promoción del `color-mix` a token (resuelve §3.5 y §5): NO**, mientras sea el único uso. El criterio de
  «recurrente» es el **nº de contextos independientes** que necesitan ese valor (componentes/artefactos/
  selectores distintos), **no** el nº de apariciones textuales ni de celdas pintadas. Hoy el relleno de la
  columna de títulos (`color-mix(in srgb, var(--border) 30%, var(--off-white))`) es el **único** `color-mix`
  del tema y tiene **un solo consumidor**. Se promovería a token (p. ej. `--ula-table-title-fill`) cuando un
  **segundo** artefacto o componente lo necesite.
- **Entrada de datos — cardinalidad fija 10 del campo de celdas (validado tal cual).** El widget multivalor
  de un campo de **cardinalidad fija N** pinta **siempre N casillas** (aquí 10), con independencia del valor
  de `Columns (m)`. En Drupal Core, la cardinalidad es configuración de **storage** (global y fija) y **no
  existe** mecanismo nativo por el que el nº de deltas de un campo dependa del valor de **otro** campo. El
  **render es correcto en todo caso**: la plantilla pinta exactamente `m` celdas por fila (rellena/trunca), de
  modo que con `m = 2` la tabla sale con dos columnas aunque el formulario muestre 10 casillas. Se aceptó esa
  **incomodidad de captura** a cambio de **no** introducir un widget a medida ni lógica de formulario reactiva
  **entre entidades** (el bloque padre tiene `m`; las celdas viven en el paragraph hijo), que sería frágil y
  de mantenimiento alto. **Alternativa nativa anotada** por si se retoma: cardinalidad **−1** (ilimitada) → el
  widget mostraría **una casilla vacía + «Add another item»** en vez de 10 (no limita a `m`, pero elimina las
  10 cajas); es un cambio de **storage** (dump previo).
