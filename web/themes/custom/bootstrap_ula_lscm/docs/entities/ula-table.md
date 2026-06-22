# Entidad — tabla de contenido `ula_table` (especificación)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Naturaleza:** **especificación de diseño** de un elemento **aún no implementado**. Reúne las tres
> capas acordadas en fase de diseño —**requerimientos funcionales**, **diseño visual** y **forma de
> implementación**— para entregárselas al desarrollador backend. Es el artefacto que se le pasa para
> implementar; **no** es el registro de una entidad ya construida.
>
> **Estado:** pendiente de implementación. Las secciones de **modelo de campos** y **cómo se consume**
> (las propias de una entidad ya construida, como en `inline-lb-stack.md`) se añaden **tras implementar y
> validar** en el Drupal real (principio del proyecto: documentar tras validar). Mientras tanto, este
> documento es la **fuente de verdad del diseño** del elemento.
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

---

## 6. Relación con otros

- **Familia:** miembro previsto de la librería de inline blocks (`inline_lb_*`); comparte patrón con
  `inline-lb-richtext.md`, `inline-lb-statgrid.md`, `inline-lb-cardgrid.md`, `inline-lb-pills.md` e
  `inline-lb-stack.md`.
- **Sustituye** (a futuro, en el contenido que lo adopte) el uso de la tabla heredada de Bootstrap Italia
  (componente `table`).
- **Tokens:** `../../css/ula-tokens.css`.
