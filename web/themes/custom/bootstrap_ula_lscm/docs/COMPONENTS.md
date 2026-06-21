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
  - [1.5. `ula_section_header`](#15-ula_section_header)
  - [1.6. `ula_carousel`](#16-ula_carousel)
- [2. Tarjetas de contenido (`ula_*`, monopropósito)](#2-tarjetas-de-contenido-ula_-monopropósito)
  - [2.1. `ula_uni_card`](#21-ula_uni_card)
  - [2.2. `ula_spec_card`](#22-ula_spec_card)
  - [2.3. `ula_sem_card`](#23-ula_sem_card)
  - [2.4. `ula_req_card`](#24-ula_req_card)
  - [2.5. `ula_faculty_card`](#25-ula_faculty_card)
- [3. Ítems de sección (`ula_*`)](#3-ítems-de-sección-ula_)
  - [3.1. `ula_feature_item`](#31-ula_feature_item)
  - [3.2. `ula_why_item`](#32-ula_why_item)
  - [3.3. `ula_hero_stat`](#33-ula_hero_stat)
  - [3.4. `ula_timeline_item`](#34-ula_timeline_item)
- [4. Marco propio (`lscm_*` / `lscm-*`)](#4-marco-propio-lscm_--lscm-)
- [5. Fichas de detalle (`ula_*`)](#5-fichas-de-detalle-ula_)
  - [5.1. `ula_faculty_detail`](#51-ula_faculty_detail)

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

### 1.5. `ula_section_header`

**Cabecera de sección**: el patrón reutilizable que encabeza cada sección de una página (en la maqueta,
`.section-tag` + `.section-title` + `.section-desc`). Tres piezas: una **etiqueta corta** (tag) en azul y
mayúsculas precedida de una **rayita dorada**, un **título grande** y una **descripción** opcional.
Autónomo (sin Bootstrap Italia); colores y la rayita dorada de los tokens. Pensado para **fondo claro**. El
contenido entra por **slots**.

Slots:

| Slot | Función |
|---|---|
| `tag` | Etiqueta corta de la sección (p. ej. «Admissions»); mayúsculas, azul, con rayita dorada delante. Opcional |
| `title` | Título de la sección (p. ej. «Ideal Candidate Profile & Admissions») |
| `description` | Párrafo descriptivo bajo el título. Opcional, por presencia |

No tiene props.

**Tipografía del título.** Usa la tipografía de **cuerpo** (`--font-body`, Manrope) en **negrita**, **no** la
*display* (Playfair). Decisión deliberada: la display se reserva para el hero/portada, y el cuerpo-negrita
distingue «cabecera de sección» de «cabecera de página» en la jerarquía tipográfica.

**Consumo (block_content + plantilla, como el CTA band).** Se alimenta de un **bloque de contenido propio**
(`block_content` tipo `section_header`) colocado en Layout Builder; la plantilla
`templates/content/block--block-content--type--section-header.html.twig` compone este componente con los
campos del bloque, pasando los valores como **valor crudo** (ver `entities/section-header.md`). Los campos
opcionales (`tag`, `description`) se pasan **solo si no están vacíos** (`isEmpty`): acceder a `.value` de un
campo vacío rompe el render (ver `CONCEPTOS-DRUPAL.md`).

**Relación con el hero.** Comparte la idea «etiqueta corta + título grande» con el eyebrow del hero, pero con
tratamiento propio (rayita dorada en vez de píldora, sobre fondo claro) y otro rol: el hero es la cabecera de
**página**; `ula_section_header`, la cabecera de **sección** dentro de la página.

### 1.6. `ula_carousel`

Contenedor que pagina una colección de elementos en un **carrusel** (tira deslizante con flechas, puntos y
*swipe*), como alternativa a la rejilla estática `ula_grid_row`. Pensado como **Nivel 1** (Format de una
vista): recibe las filas en el slot `content` (fuente `view_rows`) y muestra **N tarjetas a la vez**,
paginando el resto. Autónomo (sin Bootstrap Italia); colores y tipografía de los tokens. El Nivel 2 (la
tarjeta de cada fila) es ajeno al carrusel: el contenedor es intercambiable con la rejilla sin tocar la
tarjeta (ver `elements/layout/CONTENT-LAYOUT.md` §5.12).

Slots:

| Slot | Función |
|---|---|
| `content` | Los elementos a paginar (p. ej. `view_rows` de una vista). Cada elemento es una diapositiva |

Props:

| Prop | Tipo | Función |
|---|---|---|
| `visible` | enum `1`–`4` | Tarjetas visibles a la vez en escritorio (por defecto 3); mobile-first, se reduce a 2 en tablet (≥600) y 1 en móvil |
| `label` | string | `aria-label` de la región del carrusel (p. ej. «Faculty & Research»). Opcional |

**Comportamiento (JS propio `ula_carousel.js`).** JavaScript vanilla (IIFE, el patrón del tema; lo carga
automáticamente el SDC), **idempotente** (marca con `data-` para no inicializar dos veces). Paginación **por
grupos** según `visible`; genera los **puntos** según el número de grupos; **flechas** prev/next; soporte de
**swipe** táctil y de **teclado**; **recalcula** al redimensionar; respeta `prefers-reduced-motion`. **Sin
autoplay** (decisión de diseño: el avance es siempre acción del usuario).

**Primer uso.** La sección Faculty & Research de `/about`, con `ula_faculty_card` como Nivel 2 (ver §2.5 y
`entities/faculty-member.md` §4.2).

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

### 2.5. `ula_faculty_card`

Tarjeta de un miembro del Faculty para el **carrusel** de la sección Faculty & Research de `/about`. A
diferencia del resto de §2 (tarjetas de la home alimentadas por **props string**), esta es **slot-based** —del
mismo modelo que `ula_card_simple` (§1.1)— porque se alimenta por el flujo **Views → UI Patterns** (slots ←
`view_field` desde la vista `faculty_cards`; ver `entities/faculty-member.md` §4.2). Es el **Nivel 2** que
pinta cada fila dentro del contenedor `ula_carousel` (§1.6). Autónomo (sin Bootstrap Italia); colores y
tipografía de los tokens. Pensada para **fondo claro**. Cada bloque se pinta **por presencia**.

Slots:

| Slot | Función |
|---|---|
| `image` | Foto del profesor (campo media ya renderizado por su formatter en la vista). Opcional: si no hay foto real, se pinta el retrato de **iniciales** |
| `name` | Nombre completo (con *link to entity* enlaza a la ficha de detalle). De su texto se calculan las iniciales del retrato de respaldo |
| `academic_title` | Título académico (p. ej. «PhD»); se integra atenuado en la línea del nombre. Opcional |
| `position` | Posición principal. Opcional |
| `affiliation` | Afiliación compacta: acrónimo de la universidad (interna) o texto externo. Opcional |
| `expertise` | Áreas de expertise como **chips** (cada valor, un elemento). Opcional |
| `expertise_more` | Indicador «+N» de expertise restantes (chip de contorno discontinuo). Opcional; **hoy sin alimentar** |
| `link` | Botón «View profile» a la ficha (campo **«Link to Content»** de la vista; ver `CONTENT-LAYOUT.md` §5.9). Opcional |

No tiene props.

**Retrato: foto o iniciales.** Si el slot `image` trae una `<img>` real se muestra (recortada en círculo de
84px por CSS, `object-fit: cover`); si no, se pinta un avatar con las **iniciales** (primera letra de la
primera y de la última palabra del nombre, calculadas en Twig). El guard que decide «hay imagen o no» **no**
puede ser `{% if image %}`: en el flujo Views → UI Patterns con Twig debug activado el slot vacío trae
comentarios de depuración y nunca sería falsy. Se usa el guard que elimina los comentarios HTML y comprueba si
queda contenido (ver `elements/layout/CONTENT-LAYOUT.md` §5.8).

**Altura uniforme en la pista.** La card es *flex column*; los chips crecen (`flex: 1`) y el botón se ancla
abajo (`margin-top: auto`), de modo que todas las tarjetas de la fila igualan a la más alta.

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

Estadística individual: un número grande + una etiqueta. Origen: el hero de la landing (slot `hero_stats`).
**Reutilizado** por el artefacto `inline_lb_statgrid` en el body de las páginas (ver
`entities/inline-lb-statgrid.md`), de ahí la prop `tone`.

| Prop | Tipo | Función |
|---|---|---|
| `number` | string | Texto grande destacado |
| `label` | string | Etiqueta bajo el número |
| `tone` | string (`dark`/`light`) | Paleta según el fondo. `dark` (por defecto): número dorado, etiqueta clara (hero / fondo oscuro). `light`: número `--eu-blue`, etiqueta `--text-light` (fondo claro). Por defecto `dark` |

**Tono — `dark` es la base, `light` un override aditivo.** La paleta `dark` es el CSS base del componente
(sin cambios respecto al diseño original del hero); `light` solo sobreescribe los colores del número y la
etiqueta. Así, quien no pasa `tone` (el hero) queda **intacto**. El default se fija en el `.twig` con
`|default('dark')` porque los `default` del `.component.yml` no se inyectan de forma fiable en runtime (ver
`ARCHITECTURE.md` §6.4). Decisión transversal **D1** de la librería de inline blocks (ver
`elements/layout/INLINE-BLOCKS-CATALOG.md` §4.2 y el plan).

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

---

## 5. Fichas de detalle (`ula_*`)

Componentes **bespoke** que pintan la **página de detalle completa** de una entidad (todo el bloque main
content), no una pieza reutilizable ni una tarjeta de listado. A diferencia de los genéricos por slots (§1) y
de las tarjetas de la home por props string (§2), reciben **datos estructurados por props** (arrays de
etiquetas, chips, objetos) preparados por un **preprocess dedicado**, y el markup vive íntegro en el
componente (sin pasar por `field.html.twig`, que en este subtema sirve Bootstrap Italia).

### 5.1. `ula_faculty_detail`

Ficha de detalle de un miembro del Faculty: todo el contenido de un nodo `ct_faculty_member` —cabecera con
retrato (foto o **iniciales** de respaldo), nombre, título académico y pastillas de posición/rol; cuerpo con
biografía, chips de *expertise* y *application areas*, y *courses*; rail con contacto, enlaces, *research
profiles*, afiliación y estado «activo»—. Autónomo (sin Bootstrap Italia), sobre **fondo claro**; tokens de
`ula-tokens.css`. Cada bloque se pinta **por presencia** (guards): la ficha degrada con elegancia ante los
muchos campos opcionales.

| Prop | Tipo | Función |
|---|---|---|
| `name` | string | Nombre completo (**obligatorio**) |
| `academic_title` | string | Título académico. Opcional |
| `initials` | string | Iniciales para el retrato de respaldo (sin foto) |
| `photo_url` | string (URL) | Foto (media). Si falta, retrato de iniciales |
| `positions` | array string | Pastillas de posición (sólidas) |
| `roles` | array string | Pastillas de rol (contorno) |
| `bio` | string (HTML) | Biografía (Basic HTML), sin escapar |
| `expertise` | array string | Chips de *expertise* |
| `application_areas` | array string | Chips de áreas de aplicación |
| `courses` | array `{title, url}` | Asignaturas que imparte (enlazadas) |
| `email` | string | Correo de contacto |
| `website`, `linkedin` | string (URL) | Enlaces. Opcionales |
| `research_profiles` | array `{label, url}` | Perfiles de investigación (`label` = proveedor) |
| `affiliation` | object `{department, university_name, university_url, location}` | Afiliación; universidad enlazada si hay `university_url` (interna), texto plano si no (externa) |
| `active` | boolean | Estado: «Currently teaching» / «Not currently teaching» |

**Consumo (plantilla de nodo + preprocess).** Se alimenta desde la página canónica del nodo (view mode
`full`): la plantilla `templates/content/node--ct-faculty-member--full.html.twig` compone este componente con
la variable `faculty`, que prepara el preprocess `bootstrap_ula_lscm_preprocess_node__ct_faculty_member` con
**valores crudos** (etiquetas de listas, nombres de términos, `{title,url}` de referencias, HTML saneado de
la bio, enlaces resueltos). Ver `entities/faculty-member.md` §4.1.

**Iconos de *research profiles*.** Como el proveedor es **dato** (el título del enlace), se usa un **icono
genérico** para todos; los iconos por proveedor quedarían atados a etiquetas concretas (pendiente opcional).
