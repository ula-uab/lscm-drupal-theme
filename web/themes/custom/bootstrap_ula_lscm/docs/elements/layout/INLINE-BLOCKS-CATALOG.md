# Catálogo de artefactos inline block para el body de páginas (Layout Builder)

> **Nivel:** elemento layout (transversal a las páginas de contenido). Este documento es un **catálogo
> de diseño/especificación** —no implementación— de los **artefactos de inline block** (mecanismo A/B/C
> de Layout Builder, Core) necesarios para cubrir el **body** de las páginas de contenido sin Bootstrap
> Italia. Complementa la guía y los ADR de `CONTENT-LAYOUT.md` (§11 guía de inline blocks, §12
> ADR-LAYOUT-005), que define **qué** es cada modalidad A/B/C; aquí se concreta **qué artefactos
> construir** y con **qué especificaciones mínimas**.
>
> **Fuentes analizadas.** La maqueta de **About** (cuerpo de la página) como fuente principal, y la
> maqueta de la **landing** como fuente de artefactos útiles a futuro. **Quedan fuera del catálogo** (se
> resuelven por otros mecanismos ya documentados): el **hero** de página (vista + `ula_hero`, §5.7 de
> `CONTENT-LAYOUT.md`), **Faculty & Research** (vista + `ula_faculty_card` + `ula_carousel`), la **CTA
> band** (bloque `cta_band` + `ula_cta_band`) y el **footer** (marco compartido).
>
> **Naturaleza del entregable.** Tabla + texto de apoyo para que un desarrollador implemente la
> librería de artefactos. No incluye código; las decisiones marcadas «a evaluar / a validar» las resuelve
> quien implemente, en el Drupal real.

---

## Índice

- [1. Cómo leer este catálogo](#1-cómo-leer-este-catálogo)
- [2. Paleta, fondos y contraste (contexto para todo el catálogo)](#2-paleta-fondos-y-contraste-contexto-para-todo-el-catálogo)
- [3. Elemento recurrente ya cubierto: la cabecera de sección](#3-elemento-recurrente-ya-cubierto-la-cabecera-de-sección)
- [4. Catálogo de artefactos](#4-catálogo-de-artefactos)
  - [4.1. `inline_lb_richtext` (A)](#41-inline_lb_richtext-a)
  - [4.2. `inline_lb_statgrid` (B)](#42-inline_lb_statgrid-b)
  - [4.3. `inline_lb_cardgrid` (C)](#43-inline_lb_cardgrid-c)
  - [4.4. `inline_lb_pills` (B)](#44-inline_lb_pills-b)
  - [4.5. `inline_lb_stack` (C)](#45-inline_lb_stack-c)
- [5. Mapa maqueta About → artefactos (por sección)](#5-mapa-maqueta-about--artefactos-por-sección)
- [6. Candidatos a futuro (de la landing)](#6-candidatos-a-futuro-de-la-landing)
- [7. Decisiones de contraste y de reutilización que debe tomar quien implemente](#7-decisiones-de-contraste-y-de-reutilización-que-debe-tomar-quien-implemente)

---

## 1. Cómo leer este catálogo

**Las tres modalidades (recordatorio de `CONTENT-LAYOUT.md` §11.2):**

- **A — texto enriquecido.** Bloque con un campo de texto largo (Basic HTML); la plantilla imprime el
  HTML procesado (`…processed|raw`). Para prosa, listas y encabezados.
- **B — campos estructurados → composición de SDC `ula_*`.** Bloque con campos estructurados; la
  plantilla **compone componentes propios** pasándoles esos campos.
- **C — stack de paragraphs heterogéneos.** Bloque con un campo Paragraphs multivalor que admite varios
  tipos de pieza; el editor las apila en el orden que quiera; cada pieza se pinta con su plantilla.

**Convención de nombres.** Los artefactos siguen el patrón **`inline_lb_*`**, donde `*` describe su
naturaleza (`richtext`, `statgrid`, `cardgrid`, `pills`, `stack`). Es el nombre del **tipo de bloque**
(`block_content`) y, por extensión, de su plantilla (`block--block-content--type--inline-lb-*.html.twig`)
y de los paragraph types asociados (`inline_lb_p_*`).

**Reutilización de componentes SDC `ula_*`.** Se propone reutilizar componentes existentes siempre que
sea posible. Hay una distinción crítica validada en el piloto:

- **Paso por _props_** (valores escalares a propiedades del componente): **validado** (es lo que hizo el
  piloto B con `ula_hero_stat`).
- **Paso por _slots_** (contenido renderizable a huecos del componente): **NO ejercitado por el piloto
  A/B/C**. Se marca **«slots — a validar»** en cada artefacto que lo requiera.
  - *Matiz que reduce el riesgo:* los bloques de producción **`section_header`** y **`cta_band`** ya
    componen sus componentes (`ula_section_header`, `ula_cta_band`) **pasando valores a slots** desde la
    plantilla del bloque, y funcionan. Es decir, el paso por slots **es viable**; lo que falta es
    **validarlo en el contexto de cada artefacto nuevo** (sobre todo con contenido rico y multivalor),
    no descubrir si la técnica existe.

**Aviso de contraste (ver §2).** Cada componente `ula_*` trae **supuestos de color** (pensado para fondo
claro u oscuro). Reutilizarlo sobre un fondo distinto del previsto puede dejar texto invisible. Cada
artefacto declara el **fondo sobre el que se diseña** y, cuando reutiliza un componente con supuesto
contrario, lo marca como **riesgo de contraste** con opciones a evaluar.

---

## 2. Paleta, fondos y contraste (contexto para todo el catálogo)

**Tokens relevantes** (de `css/ula-tokens.css`; valores de la maqueta):

| Token | Valor | Uso |
|---|---|---|
| `--eu-blue` | `#003399` | Azul corporativo: títulos de tarjeta, números de cifras (sobre claro), texto de pastilla |
| `--eu-blue-light` | `#1a4db3` | Degradados de panel azul |
| `--eu-yellow` | `#FFCC00` | Acento dorado: rayita de tag, viñetas, números (sobre **oscuro**) |
| `--white` | `#ffffff` | Fondo de sección clara y de tarjetas/pastillas |
| `--off-white` | `#f4f6fc` | Fondo de sección alterna (`.alt`) |
| `--text-dark` | `#0d1b3e` | Texto principal sobre claro |
| `--text-mid` | `#3a4a6b` | Texto secundario sobre claro |
| `--text-light` | `#6b7fa3` | Etiquetas/captions sobre claro |
| `--border` | `#d0d9ef` | Bordes de tarjetas y pastillas |

**Fondos en el body de About — dato decisivo para el contraste:**

- **Secciones claras:** fondo `--white` o, en las secciones `.alt`, `--off-white`. La mayoría del body.
- **Paneles oscuros _dentro_ del body:** dos piezas concretas van sobre **azul** (degradado
  `--eu-blue → --eu-blue-light`) con **texto blanco** y acentos dorados: el panel **«The Engineering
  Edge»** (§1) y el **«Application Roadmap»** (§5, lista numerada). No son secciones completas: son
  bloques destacados sobre la sección clara.

**La regla de contraste que atraviesa el catálogo.** Un componente diseñado para **fondo oscuro** (texto
claro/dorado) puesto sobre **fondo claro** deja el texto **invisible**, y viceversa. El caso central es
**`ula_hero_stat`**: sus cifras usan `--eu-yellow` (número) y blanco al 65 % (etiqueta), porque nació
para el hero (fondo azul). En la maqueta de About, en cambio, las cifras van **sobre fondo claro con
número azul** (`--eu-blue`). Reutilizar `ula_hero_stat` tal cual sobre fondo claro → cifras ilegibles
(es exactamente el síntoma observado en el piloto). Las opciones para resolverlo están en §4.2 y §7.

---

## 3. La cabecera de sección: del bloque reutilizable al inline block

Todas las secciones de la maqueta abren con el mismo patrón: **tag corto** (mayúsculas, azul, rayita
dorada) + **título** + **descripción**. La **presentación** de ese patrón ya existe y **se reutiliza tal
cual**: el componente **`ula_section_header`** (slots `tag`/`title`/`description`; ver
`../../COMPONENTS.md` §1.5).

**Lo que cambia es el artefacto que lo coloca.** Hasta ahora la cabecera se sirve con el bloque de
contenido **reutilizable** `section_header` (ver `entities/section-header.md`), colocado al inicio de cada
sección. Funciona, pero se modeló **antes** de adoptar el modelo de **inline blocks** de Layout Builder
(§4, ADR-LAYOUT-005). Para el body de página, el inline block es el mecanismo **más natural** (la cabecera
es contenido específico de la página, no una pieza compartida entre páginas). Por eso se añade al catálogo
un artefacto **inline block** para la cabecera de sección, **`inline_lb_section_header`**, aprovechando el
SDC y la composición ya existentes.

### 3.1. `inline_lb_section_header` (cabecera de sección, inline block)

**Función.** Cabecera de sección (tag + título + descripción) como **inline block** del body, editable en
la propia página por el lápiz de Layout Builder. Misma presentación que el `section_header` reutilizable
(mismo SDC), distinto **mecanismo de colocación**.

**Estructura.** Tipo de bloque `inline_lb_section_header` con campos `field_inline_lb_sh_tag` (string,
opcional), `field_inline_lb_sh_title` (string, requerido) y `field_inline_lb_sh_description` (string_long,
opcional) — convención **D6**. La plantilla compone `ula_section_header` pasando los campos como **valor
plano** (`.value`, anti-BI) con **guard `isEmpty`** en los opcionales (igual que el `section_header`
reutilizable; ver `entities/section-header.md` §3).

**Reutilización.** `ula_section_header` **sin cambios** (el SDC ya expone los tres slots). La composición se
copia de la plantilla del bloque reutilizable; lo único que se **añade** es el **armazón estándar de
bloque** (ver más abajo).

**Lección imprescindible — el armazón (si no, desaparece la edición).** Un inline block **solo** se edita
por el lápiz de Layout Builder, y ese lápiz viaja en `<div{{ attributes }}>` (`data-contextual-id`) y
`{{ title_suffix }}`. La plantilla del `section_header` **reutilizable** emite el `<header>` **pelado** (sin
armazón): como bloque reutilizable se edita desde `/admin/content/block`, así que no lo necesita; pero
colocado **como inline block**, sin armazón, **se renderiza pero desaparece el lápiz** y no se puede editar.
La plantilla de `inline_lb_section_header` **debe** envolver el `include` del SDC en el armazón estándar
(`<div{{ attributes }}>` + `title_prefix` + `{% if label %}…{% endif %}` + `title_suffix`), igual que hace
`inline_lb_statgrid`. Detalle en `CONTENT-LAYOUT.md` §11.3–§11.4.1.

**Opción 1 — tipo nuevo, sin romper lo existente.** Se crea un tipo de bloque **nuevo**
(`inline_lb_section_header`) y se deja **intacto** el reutilizable `section_header` y su plantilla. Las
cabeceras ya colocadas en `/about` siguen funcionando; la migración de las existentes al modelo inline es
una tarea de **contenido** posterior, no forzada. (Alternativa descartada de momento: arreglar el tipo
existente para que sirva como reutilizable e inline a la vez — aprovecharía más, pero cambia el DOM de todas
las cabeceras ya colocadas y obliga a revalidarlas.)

**Interacción con el ritmo del body — a resolver al implementar.** Al envolver la cabecera en el armazón,
`.ula-section-header` deja de ser **hijo directo** de `.layout__region` (pasa a serlo el `<div>` del
armazón). Eso rompe el selector de ritmo `.layout__region > * + .ula-section-header` (ADR-LAYOUT-006), que
dejaría esa cabecera en `--lb-block-gap` (1,5rem) en vez de `--lb-section-gap` (2,5rem). Alcance limitado al
caso «cabecera que sigue a otro bloque en la misma sección». Se ajustará el selector (p. ej. clase marcadora
en el `<div>` del armazón) **al implementar el artefacto**, validándolo sobre el render real.

**Configuración en BD.** Tipo de bloque, campos, form display y ejemplares son configuración/contenido (BD,
no git); creación con script de un solo uso (no versionado); **dump previo** obligatorio.

---

## 4. Catálogo de artefactos

> El catálogo siguiente cubre **el body que va debajo** de la cabecera de sección. La cabecera en sí está en
> §3 (`inline_lb_section_header`).

Tabla resumen (las especificaciones de estilo y las decisiones de contraste se detallan en las
subsecciones 4.1–4.5):

| Artefacto | Tipo | Cubre en la maqueta | Estructura / campos | SDC `ula_*` reutilizado | Fondo previsto | Riesgo de contraste |
|---|---|---|---|---|---|---|
| **`inline_lb_richtext`** | A | «The Engineering Edge» (§1), «Application Roadmap» (§5), prosa/listas generales | 1 campo texto largo (Basic HTML) + opción de **panel/tono** (claro / panel azul) | — (no compone SDC) | Claro **o** panel azul (según opción) | **Sí**: si se usa la variante panel azul, el texto y las viñetas deben ir en claro |
| **`inline_lb_statgrid`** | B | `highlight-grid` (§1, 4 cifras), `stat-row` (§3, 3 cifras) | N pares {número, etiqueta} + columnas | `ula_grid_row` (prop `columns`) + `ula_hero_stat` (props `number`/`label`) | **Claro** | **Sí, alto**: `ula_hero_stat` está pensado para fondo oscuro (número dorado, etiqueta blanca) → invisible sobre claro. Ver §4.2 |
| **`inline_lb_cardgrid`** | C | `card-grid` (§2, 3 tarjetas), `adm-cols` (§5, 2 columnas) | Stack de paragraphs «tarjeta» (título + cuerpo rich text) + columnas | `ula_grid_row` (props) + `ula_card_simple` (**slots** `title`/`body`… — a validar) | Claro (blanco/off-white) | Bajo: `ula_card_simple` es tarjeta clara; legible sobre blanco y off-white |
| **`inline_lb_pills`** | B | `tools` (§2, pastillas) y `role-grid` (§3, roles) como variante | 1 campo string **multivalor** + opción de variante (pastilla / etiqueta-tarjeta) | — (no hay SDC de pastilla; ver §4.4) | Claro | Medio: pastillas azul-sobre-blanco; sobre panel oscuro necesitan variante clara |
| **`inline_lb_stack`** | C | Cualquier sección que **mezcle** piezas en un único bloque editable | Campo Paragraphs multivalor con varios tipos de pieza (texto, pastillas…) | Composición de las piezas (ver 4.1/4.4) | Según pieza | Hereda el de cada pieza |

### 4.1. `inline_lb_richtext` (A)

**Función.** Body en prosa: párrafos, listas, encabezados intermedios. Cubre el texto libre de las
secciones y, en particular, los **dos paneles destacados** de la maqueta: «The Engineering Edge» (§1) y
«Application Roadmap» (§5).

**Estructura.** Un tipo de bloque con un campo de texto largo (Basic HTML). La plantilla imprime
`campo.0.processed|raw` (anti-BI, sin `field.html.twig`). El aspecto lo da el CSS propio.

**Opción de panel/tono — necesaria por el contraste.** En la maqueta, el mismo «artefacto de texto»
aparece en dos fondos opuestos: prosa normal sobre fondo claro, y los paneles «Edge»/«Roadmap» sobre
**azul con texto blanco**. Para no inventar un artefacto por fondo, se propone una **opción de
presentación** (lista de valores fija, o variante) que el editor elija:

- **`plain`** — sin caja; texto `--text-mid`/`--text-dark` sobre el fondo claro de la sección.
- **`panel_blue`** — caja con fondo degradado `--eu-blue → --eu-blue-light`, `border-radius:
  var(--radius-lg)`, padding ~2.5rem, **texto blanco**, encabezado `h3` blanco, viñetas con acento
  dorado (`→` o `•` en `--eu-yellow`), nota final en blanco al ~70 %. (Replica «Edge» y «Roadmap».)

**Specs mínimas de estilo.** Encabezados en `--font-display`; listas con interlineado cómodo; «nota»
secundaria en tamaño menor y color atenuado. En `panel_blue`, **todo el texto en claro** (es el punto de
contraste): el CSS del artefacto fuerza el color del texto dentro del panel, no se hereda del tema.

**Reutilización SDC.** Ninguna (es texto enriquecido). 

**Contraste — a evaluar por quien implemente.** Confirmar que en `panel_blue` ningún color heredado deja
texto oscuro sobre azul. **Resuelto (decisión del hito):** la «Application Roadmap» **no** se cubre con una
lista numerada en Basic HTML, sino con un **artefacto de pasos dedicado** basado en `ula_timeline_item`
(`COMPONENTS.md` §3.4) — más impactante visualmente. Es decir, `inline_lb_richtext` cubre la prosa y los
paneles de texto; los «pasos» van a su propio artefacto (a catalogar al planificarlo).

### 4.2. `inline_lb_statgrid` (B) — **implementado**

> **Estado:** implementado y validado. Detalle completo en `entities/inline-lb-statgrid.md`. Esta entrada se
> conserva como referencia de catálogo; las decisiones abiertas que listaba quedaron resueltas como se indica.

**Función.** Rejilla de **cifras** (número grande + etiqueta). Cubre `highlight-grid` (§1: 2 / 120 / EN /
MSc) y `stat-row` (§3: 92% / 40+ / 15).

**Estructura (resuelta: multivalor).** Paragraph `inline_lb_p_stat` **multivalor** (`field_inline_lb_stats`),
un delta por par {número, etiqueta} → **número variable** de cifras. Opciones del editor como `list_string`
en el bloque (D5-mecanismo): `field_inline_lb_sg_tone` (`light`/`dark`, def. `light`) y
`field_inline_lb_sg_cols` (`1`–`4`, def. `3`). La plantilla recorre los paragraphs, arma un **array** de
`ula_hero_stat` y lo pasa al slot `content` de `ula_grid_row`.

**Reutilización SDC.** `ula_grid_row` (prop `columns`) como contenedor + `ula_hero_stat` (props
`number`/`label`/`tone`) por celda. En la maqueta: `columns: 4` para `highlight-grid`, `columns: 3` para
`stat-row`.

**Specs de estilo.** Las del componente `ula_hero_stat` (paleta `light`: número `--eu-blue`, etiqueta
`--text-light`) dentro de las celdas de `ula_grid_row`.

**Riesgo de contraste — resuelto (D1, opción 1).** `ula_hero_stat` estaba pensado para fondo oscuro (número
dorado, etiqueta blanca al 65 %), invisible sobre claro. Se resolvió **añadiendo la prop `tone` al
componente** (opción 1): `dark` es la base (hero intacto), `light` un override aditivo (número azul,
etiqueta atenuada) que usa este artefacto. Ver `entities/inline-lb-statgrid.md` §4 y `COMPONENTS.md` §3.3.

### 4.3. `inline_lb_cardgrid` (C)

**Función.** Rejilla de **tarjetas simples** (título + lista/cuerpo). Cubre `card-grid` (§2:
«Foundational Modules», «Specialization Pathways», «Software & Tools») y `adm-cols` (§5: «Academic
Background», «Technical Skills»).

**Estructura.** Stack de paragraphs «tarjeta» (`inline_lb_p_card`), cada uno con **título** + **cuerpo
rich text** (la lista). La plantilla del bloque coloca el stack en `ula_grid_row` (columnas según
sección: 3 para `card-grid`, 2 para `adm-cols`). Tipo C porque el número de tarjetas es variable y el
editor las apila.

**Reutilización SDC.** `ula_grid_row` (prop `columns` → validado) como contenedor + **`ula_card_simple`**
por tarjeta. `ula_card_simple` expone **slots** (`title`, `subtitle`, `body`, `image`, `link`) y la prop
`shadow`. → **Pasar el título y el cuerpo por _slots_: a validar** (ver §1; producción ya compone por
slots en `cta_band`/`section_header`, así que es viable). Si la validación diera problemas con contenido
rico, **plan B**: plantilla de paragraph propia que pinte la tarjeta sin reutilizar el SDC.

**Specs mínimas de estilo (según maqueta).** Tarjeta `--white`, `border: 1px solid var(--border)`,
`border-radius: var(--radius-lg)`, padding ~1.5–2rem, `box-shadow` suave en hover; título `h3` `--eu-blue`;
ítems de lista separados por línea inferior `--border`, texto `--text-mid`. Variante `adm-box`: viñetas
con check dorado (`✓` en `--eu-yellow`) — es estilo de lista en el cuerpo, lo aporta el CSS.

**Riesgo de contraste — bajo.** `ula_card_simple` es una **tarjeta clara** (fondo blanco, texto oscuro):
legible tanto sobre sección blanca como sobre `.alt` (off-white). Sin acción especial.

### 4.4. `inline_lb_pills` (B)

**Función.** Fila de **pastillas/etiquetas** desde un campo multivalor. Cubre `tools` (§2: SAP,
AnyLogic, Python, R, Arena Simulation). Como **variante**, puede cubrir `role-grid` (§3: roles
profesionales), que visualmente son etiquetas más grandes en rejilla.

**Estructura.** Un tipo de bloque con un campo **string multivalor**; la plantilla recorre los valores y
pinta una pastilla por valor (es el patrón `pilot_p_pill` del piloto, ahora como artefacto autónomo). Una
**opción de variante** distingue `pill` (pastilla inline) de `tag_card` (etiqueta-tarjeta en rejilla,
para roles).

**Reutilización SDC — resuelto (D2): crear SDC `ula_pill` / `ula_pill_group`.** No existe un componente
`ula_*` de pastilla (el piloto las pintó con CSS propio `.pilot-pill`). Se decide **crear un SDC
reutilizable** `ula_pill` / `ula_pill_group` (más alineado con el design system; reutilizable en otras
páginas), **no** CSS propio del artefacto. **Referencia de estilo:** las **pastillas/chips** de
`ula_faculty_detail` (las de expertise/rol), **no** el botón «View profile» de la faculty card. El estilo
exacto se extraerá del CSS real de esos componentes al implementar.

**Variante `pill` vs `tag_card` — resuelto (D5): prop `variant` en `ula_pill_group`.** La distinción entre
pastilla inline (`pill`) y etiqueta-tarjeta en rejilla (`tag_card`, roles) se modela como **prop `variant`**
del grupo. (Pendiente menor a decidir al implementar: si se prevé ya una variante clara para uso sobre panel
oscuro o no se contempla aún.)

**Specs mínimas de estilo (según maqueta).** `pill`: fondo `--white`, `border: 1px solid var(--border)`,
`border-radius: 100px`, padding ~8px 20px, texto `--eu-blue`, peso 600; fila con `flex-wrap` y `gap`
~10px. `tag_card` (roles): fondo `--white`, `border-left: 3px solid var(--eu-yellow)`, `border-radius:
var(--radius)`, padding ~1.4rem, texto `--text-dark` en negrita, sombra suave; en rejilla (4 columnas en
la maqueta).

**Riesgo de contraste — medio.** Las pastillas son azul-sobre-blanco: correctas sobre fondo claro. Si se
colocaran sobre un **panel oscuro**, harían falta una variante clara (texto y borde claros). Preverlo si
el artefacto se va a poder usar dentro de paneles azules.

### 4.5. `inline_lb_stack` (C)

**Función.** Stack **heterogéneo** de propósito general: combina varias piezas de body (texto
enriquecido, pastillas y, si se quiere, cifras o tarjetas) en **un único bloque editable**, apiladas en
el orden que el editor decida. Es el `pilot_stack` del piloto, generalizado. Útil cuando una sección
mezcla piezas y se prefiere un solo bloque a varios bloques sueltos en la sección.

**Estructura.** Un tipo de bloque con un campo Paragraphs multivalor que admite varios paragraph types de
pieza: como mínimo `inline_lb_p_text` (texto rich) y `inline_lb_p_pill` (pastillas); ampliable a piezas
de tarjeta o cifra. Cada pieza se pinta con su plantilla propia (anti-BI). Requiere el **view display**
del campo Paragraphs (lección de `CONTENT-LAYOUT.md` §11.4).

**Reutilización SDC.** La que aporte cada pieza (las mismas notas de 4.1 y 4.4). 

**Cuándo preferirlo frente a bloques sueltos.** Si las piezas de una sección **se editan juntas** y su
**orden** importa, el stack las mantiene en un solo bloque. Si son piezas independientes reordenables a
nivel de sección, pueden ser bloques sueltos (`richtext`, `pills`, …) en la región. Es una decisión de
edición, no de capacidad.

**Riesgo de contraste.** El de cada pieza que contenga (hereda 4.1/4.4).

---

## 5. Mapa maqueta About → artefactos (por sección)

Excluidas hero, Faculty & Research, CTA y footer. Cada sección abre con `section_header` (§3) y debajo
coloca los artefactos del body:

| Sección de la maqueta | Fondo | Body → artefactos |
|---|---|---|
| **§1 Program Overview** | Claro (blanco) | `inline_lb_statgrid` (`highlight-grid`, 4 col — **riesgo de contraste de `ula_hero_stat`**) + `inline_lb_richtext` variante `panel_blue` («The Engineering Edge») |
| **§2 Curriculum** (`.alt`) | Claro (off-white) | `inline_lb_cardgrid` (3 tarjetas título+lista) + `inline_lb_pills` variante `pill` (`tools`) |
| **§3 Careers** | Claro (blanco) | `inline_lb_pills` variante `tag_card` (`role-grid`, roles) + `inline_lb_statgrid` (`stat-row`, 3 col — **mismo riesgo de contraste**) |
| **§5 Admissions** | Claro (blanco) | `inline_lb_cardgrid` (2 columnas, `adm-cols`, viñetas ✓) + `inline_lb_richtext` variante `panel_blue` («Application Roadmap», lista numerada) |

> Alternativa de composición: cualquiera de estas combinaciones por sección puede montarse como varios
> bloques sueltos en la región **o** como un único `inline_lb_stack` que apile las piezas. Es la decisión
> de edición descrita en §4.5.

---

## 6. Candidatos a futuro (de la landing)

La landing se resuelve hoy mayoritariamente con **componentes de entidad consumidos por Views** (home).
De cara a futuros bodies de página con inline blocks, los componentes `ula_*` **prop-based** existentes
son candidatos directos a artefactos **tipo B** (composición por props → técnica ya validada), sin crear
nada nuevo salvo el tipo de bloque que los alimente:

| Patrón visual (landing) | Componente `ula_*` reutilizable | Props | Artefacto candidato | Nota de contraste |
|---|---|---|---|---|
| Tarjeta de característica con icono | `ula_feature_item` | `icon`, `title`, `description` | `inline_lb_featuregrid` (B) | Verificar fondo de la sección destino |
| Ítem numerado «por qué» | `ula_why_item` | `number`, `title`, `description` | `inline_lb_whygrid` (B) | La sección «LSCM Advantage» de la landing es **oscura** (título forzado a blanco) → el componente debe leerse claro sobre oscuro |
| Paso / hito de proceso | `ula_timeline_item` | `title`, `description`, `show_line` | `inline_lb_timeline` (B/C) | Candidato para «Application Roadmap» (§5) en vez de lista numerada en `panel_blue` |
| Tarjeta de requisito con icono | `ula_req_card` | `icon`, `title`, `description` | `inline_lb_reqgrid` (B) | Candidato para «Academic Background»/«Technical Skills» (§5) si se quiere icono |

> Todos son **prop-based**, por lo que su composición está dentro de lo validado por el piloto. Antes de
> reutilizarlos, comprobar el **fondo** de la sección destino frente al supuesto de color del componente
> (§2): varios nacieron para secciones concretas de la home (algunas oscuras).

---

## 7. Decisiones de contraste y de reutilización que debe tomar quien implemente

Resumen accionable de lo que **no** está cerrado en este catálogo y debe resolverse al implementar, en el
Drupal real:

1. **Cifras sobre fondo claro (`inline_lb_statgrid`).** `ula_hero_stat` es de fondo oscuro; en About van
   sobre claro. Elegir entre: variante/prop `tone` en `ula_hero_stat`, clase envolvente que sobreescriba
   el color, o componente de cifra claro propio (§4.2). **Bloqueante para §1 y §3.**
2. **Texto en panel azul (`inline_lb_richtext` `panel_blue`).** Forzar el color claro de todo el texto y
   de las viñetas dentro del panel; no heredar colores oscuros del tema (§4.1).
3. **Paso por slots a `ula_card_simple` (`inline_lb_cardgrid`).** Validar el paso de título y cuerpo rich
   text por slots (viable: producción ya compone por slots en `cta_band`/`section_header`); si diera
   problemas, plantilla de tarjeta propia como plan B (§4.3).
4. **Pastillas sin SDC (`inline_lb_pills`).** Decidir CSS propio del artefacto vs crear `ula_pill_group`
   reutilizable; prever variante clara si han de ir sobre panel oscuro (§4.4).
5. **Componentes de la landing reutilizados (§6).** Comprobar el supuesto de color de cada componente
   frente al fondo de la sección destino antes de reutilizarlo.

> Regla general que cierra el catálogo: **antes de reutilizar un componente `ula_*`, confirmar (a) si su
> dato va por prop o por slot, y (b) sobre qué fondo está diseñado.** Las dos preguntas determinan,
> respectivamente, si la composición está validada y si habrá problema de contraste.
