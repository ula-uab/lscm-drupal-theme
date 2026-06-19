# Componentes propios del tema

> **Nivel tema (transversal).** Catálogo de los **componentes SDC propios** del tema (los que
> diseñamos nosotros), con su **función** y sus **atributos principales** (slots y props). No cubre
> los componentes heredados de Bootstrap Italia: el inventario completo (propios vs heredados en uso
> vs herencia muerta) está en `analysis/inventario-bi.md` §2. Este documento **describe los
> componentes en sí**; cómo se **usan** para componer páginas (el patrón Views → UI Patterns, los dos
> niveles) se documenta en `elements/layout/CONTENT-LAYOUT.md`, que referencia a este.
>
> Referenciado desde `README.md` y `ARCHITECTURE.md` §3.

---

## Índice

- [Convenciones comunes](#convenciones-comunes)
- [1. Componentes genéricos reutilizables (design system `ula_*`)](#1-componentes-genéricos-reutilizables-design-system-ula_)
  - [1.1. `ula_card_simple`](#11-ula_card_simple)
  - [1.2. `ula_grid_row`](#12-ula_grid_row)
  - [1.3. `ula_hero`](#13-ula_hero)
  - [1.4. `ula_cta_band`](#14-ula_cta_band)
- [2. Tarjetas de contenido (`ula_*`, monopropósito)](#2-tarjetas-de-contenido-ula_-monopropósito)
  - [2.1. `ula_uni_card`](#21-ula_uni_card)
  - [2.2. `ula_spec_card`](#22-ula_spec_card)
  - [2.3. `ula_sem_card`](#23-ula_sem_card)
  - [2.4. `ula_req_card`](#24-ula_req_card)
- [3. Ítems de sección (`ula_*`)](#3-ítems-de-sección-ula_)
  - [3.1. `ula_feature_item`](#31-ula_feature_item)
  - [3.2. `ula_why_item`](#32-ula_why_item)
  - [3.3. `ula_hero_stat`](#33-ula_hero_stat)
  - [3.4. `ula_timeline_item`](#34-ula_timeline_item)
- [4. Marco propio (`lscm_*` / `lscm-*`)](#4-marco-propio-lscm_--lscm-)

---

## Convenciones comunes

Aplican a todos los componentes propios salvo que la ficha diga lo contrario:

- **Autónomos, sin Bootstrap Italia.** No incluyen markup ni clases del tema base (`@bi-bcl`,
  `container/row/col/it-*`). El aspecto lo aportan su CSS propio y los **tokens** de
  `css/ula-tokens.css` (`--eu-blue`, `--white`, `--border`, `--radius-lg`, `--text-dark`,
  `--font-display`…).
- **CSS auto-adjuntado.** Cada componente lleva su `<nombre>.css` en su carpeta; SDC lo adjunta
  automáticamente al renderizar (no hay que declararlo en una librería).
- **El contenedor en rejilla lo aporta la sección, no el componente.** Las tarjetas e ítems se diseñan
  para colocarse dentro de un contenedor (un grid) que define quien los compone. **Excepción:**
  `ula_grid_row` **es** ese contenedor.
- **Convención de nombres.** `ula_*` se reserva para **desarrollos nuevos** del design system. Los
  `lscm_*` / `lscm-*` (§4) son propios pero **nacieron antes** de fijar esa convención (son el marco);
  cuando se adopte un heredado y se haga propio, se renombrará con prefijo `ula_*`.
- **Props vs. slots (distinción clave).** Un **slot** recibe contenido **renderizable** (un campo de
  Drupal ya renderizado, HTML); una **prop** recibe un **valor** que el componente formatea (string,
  booleano, array). Esto determina cómo se conecta cada componente con los datos:
  - Los componentes **de la home** (§2 y §3) usan **props string**: el contenido se les pasa como texto
    desde el marco de la home (`lscm-master-page`) por mapeo preprocess → prop.
  - Los componentes **nuevos genéricos** (§1) usan **slots**: aceptan **campos renderizados**, lo que les
    permite alimentarse desde **Views → UI Patterns** sin atarse a una entidad concreta (y evita el error
    "got object" que da una prop string cuando recibe un campo). Ver `CONTENT-LAYOUT.md` §5.

---

## 1. Componentes genéricos reutilizables (design system `ula_*`)

Diseñados para ser **reutilizables entre tipos de contenido** y alimentarse por **slots** (campos
renderizados). Son la base del modelo de composición de páginas no-home con Layout Builder.

### 1.1. `ula_card_simple`

Tarjeta genérica de contenido, para fondo **claro/blanco**. El contenido entra por **slots**, de modo
que acepta campos renderizados de cualquier entidad (encaja en Views → UI Patterns). La imagen se
muestra por presencia (sin variantes). Efecto *hover* tomado de las tarjetas de la home.

Slots:

| Slot | Función |
|---|---|
| `image` | Imagen de cabecera (campo de imagen ya renderizado). Opcional |
| `title` | Título |
| `subtitle` | Dato secundario (acrónimo, ubicación, categoría). Opcional |
| `body` | Texto/descripción; acepta HTML saneado (párrafos, listas) |
| `link` | Enlace de la tarjeta (p. ej. campo con *link to entity*). Opcional |

Props:

| Prop | Tipo | Función |
|---|---|---|
| `shadow` | boolean | Sombra de reposo (además del realce al pasar el cursor) |

### 1.2. `ula_grid_row`

Rejilla propia para disponer una colección de elementos (tarjetas u otros) en columnas de **igual
altura** (CSS Grid + `align-items: stretch`). Pensada como **Nivel 1** (Format de una vista): recibe las
filas en el slot `content` (fuente `view_rows`). Sustituye al `grid_row` heredado (que usa clases de
Bootstrap Italia).

Slots:

| Slot | Función |
|---|---|
| `content` | Los elementos a disponer (p. ej. `view_rows` de una vista). Cada elemento ocupa una celda |

Props:

| Prop | Tipo | Función |
|---|---|---|
| `columns` | enum `1`–`4` | Columnas en escritorio (por defecto 3); se reduce solo a 2 en tablet y 1 en móvil |

> Conectores visuales entre tarjetas (como en la home) **no** están en esta versión; aplazados a una
> versión sofisticada (ver `CONTENT-LAYOUT.md` §9.1).

### 1.3. `ula_hero`

Hero / **cabecera de página**: el bloque superior sobre fondo azul degradado, con eyebrow, título (con una
parte resaltada en dorado), subtítulo, llamadas a la acción y, opcionalmente, una fila de estadísticas.
Autónomo (sin Bootstrap Italia); el degradado, el dorado, la píldora del eyebrow y el estilo de los botones
están tomados del **hero de la home** y de los tokens. El contenido entra por **slots**, así que se alimenta
de campos renderizados (Views → UI Patterns) sin atarse a una entidad. Es el componente que pinta los nodos
del tipo de contenido `hero` (ver `entities/hero.md`).

Slots:

| Slot | Función |
|---|---|
| `eyebrow` | Etiqueta superior corta (píldora con punto). Opcional |
| `title` | Título principal (parte no resaltada) |
| `title_highlight` | Parte del título resaltada en dorado. Opcional |
| `subtitle` | Párrafo descriptivo. Opcional |
| `actions` | CTAs (enlaces ya renderizados); se estilan como botón. Opcional, por presencia |
| `stats` | Colección de estadísticas (componentes `ula_hero_stat` ya renderizados). Opcional, por presencia |

Props:

| Prop | Tipo | Función |
|---|---|---|
| `size` | enum `page` / `home` | Presentación del componente (ver abajo). Por defecto `page` |

**La prop `size` y las dos presentaciones («variantes»).** `size` no cambia el contenido, solo la
**presentación** del mismo componente. Es lo que en lenguaje informal llamamos «variante» del hero, aunque
técnicamente es una prop `enum`, **no** una *variant* de UI Patterns:

- **`page`** (por defecto): cabecera de **página interna**. Más baja (no ocupa toda la pantalla). En el marco
  de páginas, su CSS la extiende a **todo el ancho** (full-bleed, rompiendo el contenedor de contenido) y la
  **pega bajo el header**, como la portada. Es la que usa About.
- **`home`**: **portada a pantalla completa** (`min-height: 100vh`), con resplandores decorativos y flecha de
  scroll. Pensada para que, el día que se migre la home a este componente, reproduzca su hero.

El eyebrow (píldora con punto) y el resaltado en dorado son **comunes a ambas**; en `home` el resaltado se
muestra en su propia línea y en cursiva.

**Stats, por composición.** El slot `stats` recibe una colección de `ula_hero_stat` **ya renderizados**; el
componente no los itera. El mapeo de cada estadística a `ula_hero_stat` lo hace la plantilla del paragraph
`hero_stat` (ver `entities/hero.md` §3 y `CONCEPTOS-DRUPAL.md`, composición de SDC). `ula_hero_stat` se
reutiliza sin modificar (lo usa también la home).

**Consumo y full-bleed.** Se alimenta vía una **vista con filtro contextual** por el nodo de la página
(`entities/hero.md`, `CONTENT-LAYOUT.md`). En `page`, el full-bleed requiere que la página sea de **una sola
columna**; los detalles y avisos (dependencia del `padding-top` del marco, posible scroll horizontal) están
comentados en el propio `ula_hero.css`.

---

### 1.4. `ula_cta_band`

Franja / **tarjeta de llamada a la acción (CTA)** para el **cierre de una página** (justo antes del footer).
A diferencia de `ula_hero`, **no** es una banda a todo el ancho de la pantalla: es una **tarjeta que ocupa el
ancho de su contenedor**, con **borde azul marcado** (`--eu-blue`, 2px) y **fondo claro** (`--off-white`),
pensada para destacar sin romper el contenedor de contenido (evita el full-bleed del hero). Autónoma (sin
Bootstrap Italia); colores y tipografía salen de los tokens. El contenido entra por **slots**. Sin hover en
la tarjeta (el botón sí tiene su realce).

Slots:

| Slot | Función |
|---|---|
| `title` | Título de la llamada a la acción (p. ej. «Ready to Apply?») |
| `text` | Párrafo descriptivo. Opcional |
| `actions` | Enlace(s) de llamada a la acción (campo Link ya renderizado); se estilan como **botón sólido dorado**. Opcional, por presencia |

No tiene props: una sola presentación.

**Consumo (block_content + plantilla, no Views).** A diferencia del hero (Views → UI Patterns), el CTA band
se alimenta de un **bloque de contenido propio** (`block_content` tipo `cta_band`) colocado en Layout
Builder; una **plantilla del bloque** (`templates/content/block--block-content--type--cta-band.html.twig`)
compone este componente con los campos del bloque, pasando `title` y `text` como valor crudo y el enlace como
campo renderizado. Es el patrón de **composición desde plantilla** (ver `entities/cta_band.md` y
`CONCEPTOS-DRUPAL.md`).

**Distinción con `ula_hero`.** `ula_hero` es la **cabecera** de la página (arriba, fondo azul, full-bleed);
`ula_cta_band` es la **franja de cierre** (abajo, tarjeta clara, dentro del contenedor). No se reutiliza el
hero para cierres ni viceversa — la decisión y su porqué están en el ADR de `entities/cta_band.md`.

---

## 2. Tarjetas de contenido (`ula_*`, monopropósito)

Tarjetas diseñadas para secciones concretas de la **home**. Usan **props string** (contenido como texto,
vía el marco de la home). No son genéricas; para una tarjeta reutilizable por slots, ver §1.1.

### 2.1. `ula_uni_card`

Tarjeta de universidad socia, pensada para **fondo oscuro** (sección azul). Se compone en el slot
`universities` de la home.

| Prop | Tipo | Función |
|---|---|---|
| `flag` | string | Bandera como emoji |
| `country` | string | País y ciudad |
| `name` | string | Nombre completo |
| `abbr` | string | Acrónimo |
| `description` | string | Texto descriptivo |
| `tags` | array `{label, info}` | Pastillas de semestre/rol (`info` reservado para popover futuro) |

### 2.2. `ula_spec_card`

Tarjeta de especialización: cabecera con imagen de fondo (overlay + título + ubicación superpuestos) y
cuerpo con descripción enriquecida. La imagen entra como **URL en prop** (no como slot).

| Prop | Tipo | Función |
|---|---|---|
| `title` | string | Nombre de la especialización (sobre la imagen) |
| `location` | string | Universidad y país (sobre la imagen) |
| `image` | string (URL) | Imagen de fondo de la cabecera (opcional; si falta, color de respaldo) |
| `description` | string (HTML) | Descripción enriquecida (párrafos/listas), sin escapar |

### 2.3. `ula_sem_card`

Tarjeta de semestre del recorrido académico (fondo claro). Iguala su altura a la más alta de la fila
(cuerpo que crece). Se compone en el slot `journey_semesters`.

| Prop | Tipo | Función |
|---|---|---|
| `semester` | string | Etiqueta del semestre |
| `logos` | array de URLs | Uno o dos logos de universidad (altura normalizada) |
| `university` | string | Universidad y ciudad (pastilla) |
| `title` | string | Título temático |
| `description` | string (HTML) | Asignaturas como lista (sin escapar) |
| `variant` | enum `1`–`4` | Variante de color (logos y pastilla) |

### 2.4. `ula_req_card`

Tarjeta de requisito de admisión (icono + título + descripción, vertical). Se compone en el slot
`requirements_cards`.

| Prop | Tipo | Función |
|---|---|---|
| `icon` | string | Icono (emoji o carácter) |
| `title` | string | Título del requisito |
| `description` | string | Texto descriptivo |

---

## 3. Ítems de sección (`ula_*`)

Piezas pequeñas de las secciones de la home/landing, basadas en **props string**.

### 3.1. `ula_feature_item`

Ítem de la sección "About" (icono + título + texto, horizontal). Slot de composición: `about_features`.

| Prop | Tipo | Función |
|---|---|---|
| `icon` | string | Icono (emoji o carácter) |
| `title` | string | Título corto |
| `description` | string | Texto breve |

### 3.2. `ula_why_item`

Ítem de la sección "Why LSCM" (número destacado + título + descripción). Slot: `why_items`.

| Prop | Tipo | Función |
|---|---|---|
| `number` | string | Número o símbolo destacado |
| `title` | string | Título corto |
| `description` | string | Texto descriptivo |

### 3.3. `ula_hero_stat`

Estadística individual del hero de la landing (un número grande + una etiqueta). Slot: `hero_stats`.

| Prop | Tipo | Función |
|---|---|---|
| `number` | string | Texto grande destacado |
| `label` | string | Etiqueta bajo el número |

### 3.4. `ula_timeline_item`

Paso de una cronología (punto + línea conectora + título + descripción). Slot: `timeline_items`.

| Prop | Tipo | Función |
|---|---|---|
| `title` | string | Título del paso |
| `description` | string | Texto descriptivo |
| `show_line` | boolean | Dibuja la línea conectora al siguiente paso (`false` en el último). Por defecto `true` |

---

## 4. Marco propio (`lscm_*` / `lscm-*`)

Componentes propios **anteriores a la convención `ula_*`**: son el **marco** (header/footer de páginas y
marco de la home), no el design system de contenido. Se describen aquí en breve; su funcionamiento
detallado vive en su documento de elemento.

| Componente | Función | Atributos principales | Documentación |
|---|---|---|---|
| `lscm_page_header` | Header compartido de las páginas de contenido (no la home): estética del header de la home con **navegación de sitio estándar** (menú de Drupal) | props: `logo_url`, `brand_top`, `brand_sub`, `menu_links`, `active_url` | `elements/layout/SHARED-FRAME-LAYOUT.md` |
| `lscm_page_footer` | Footer **provisional** compartido de las páginas de contenido (contenido mínimo, hasta definir el definitivo) | props: `brand_top`, `contact_email` | `elements/layout/SHARED-FRAME-LAYOUT.md` |
| `lscm-master-page` | Marco de la **home**: compone los componentes `ula_*` en sus secciones (hero, about, journey, universities, specializations, why, admission) | props de texto editables por sección (hero/about/journey/uni/spec/adm/contact…), mapeables a campos del bloque de la home | `elements/home/HOME-ARCHITECTURE.md` |
| `lscm-master-static` | Versión **estática** de `lscm-master-page` (todo el contenido fijo en plantilla). **No en producción**; útil para despliegue sin CMS dinámico | sin props ni slots | `elements/home/HOME-ARCHITECTURE.md` |
