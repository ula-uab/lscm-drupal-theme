# Entidad — bloque de contenido `inline_lb_statgrid` (rejilla de cifras)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** hito «librería de artefactos inline block» (en curso, sobre la línea v1.7.0; **el salto de
> versión —previsiblemente v1.8.0— se hará al completar la librería**, no en este artefacto) ·
> **Naturaleza:** **tipo de bloque de contenido** (`block_content`) colocado como **inline block
> de Layout Builder**, **no** un tipo de contenido (nodo) ni un bloque reutilizable. · **Mecanismo de
> consumo:** inline block + **plantilla del bloque que compone componentes SDC** (`ula_grid_row` +
> `ula_hero_stat`), patrón B del catálogo de inline blocks (campos → composición de SDC). Ver
> `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.2, `../elements/layout/CONTENT-LAYOUT.md` §11 (guía de
> inline blocks, ADR-LAYOUT-005), `../COMPONENTS.md` §1.2 y §3.3, y el plan
> `../plans/paginas-contenido/plan-libreria-inline-blocks.md`.

---

## 1. Qué es y por qué existe

`inline_lb_statgrid` modela una **rejilla de cifras** del body de una página: cada cifra es un **número
grande** (p. ej. «120», «2», «EN», «MSc») con una **etiqueta** debajo («ECTS», «Years», «Instruction
Language», «Degree»). En la maqueta de About cubre el `highlight-grid` (§1, 4 cifras) y el `stat-row` (§3,
3 cifras). La presentación la ponen dos componentes propios: `ula_grid_row` (la rejilla, con su número de
columnas) y `ula_hero_stat` (cada celda de cifra). Es el **primer artefacto de la librería de inline
blocks** y el primer body de página servido **íntegramente sin Bootstrap Italia**.

**Por qué un inline block y no un bloque reutilizable ni un nodo.** Una rejilla de cifras **no es una
página** ni una pieza compartida entre páginas: es **body específico de una página**, redactado para esa
sección concreta. Esa es exactamente la naturaleza de un **inline block de Layout Builder**: se crea desde
el propio Layout Builder (*Add block → Create custom block*), **vive con el layout del nodo** y no contamina
la biblioteca de bloques con piezas de un solo uso (ver `../elements/layout/CONTENT-LAYOUT.md` §11.3). Es la
diferencia con `cta_band`/`section_header`, que se modelaron como bloques **reutilizables** por ser piezas
compartidas; aquí, al ser contenido de una página, el inline block encaja mejor.

**Por qué el patrón B (campos → composición de SDC) y no Views → UI Patterns.** Las cifras son **datos
propios del bloque** (no una colección de entidades a listar), redactados por el editor en la propia página.
El mecanismo natural es un bloque con campos estructurados cuya plantilla **compone** los SDC, no una vista.
Encaja además con la fragilidad conocida de UI Patterns con campos en este sitio (ver `../../TODO.md`, nota
sobre `source_id`/`textfield`).

**Por qué la presentación la aportan los componentes y no el contenido.** El bloque solo guarda **datos**
(pares número/etiqueta, tono y columnas). El aspecto (celdas con borde, número y etiqueta) lo ponen
`ula_grid_row` y `ula_hero_stat` (design system `ula_*`), de modo que el contenido editable queda libre de
markup y de clases de Bootstrap Italia.

---

## 2. Modelo de datos

El artefacto se compone de **dos** entidades de configuración propias: el **tipo de bloque** y un **tipo de
paragraph** anidado para los pares de cifra.

### 2.1. Tipo de bloque `inline_lb_statgrid`

| Campo | Tipo | Card. | Por defecto | Para qué |
|---|---|---|---|---|
| **Block description** (base) | — | 1 | — | Nombre **administrativo** del ejemplar; identifica el inline block. **No** se muestra al visitante. |
| `field_inline_lb_stats` | Paragraphs (`inline_lb_p_stat`) | **multivalor** | — | Las cifras: un delta por cada par {número, etiqueta}. Número variable de cifras (lo apila el editor). |
| `field_inline_lb_sg_tone` | list_string (`light`/`dark`) | 1 | **`light`** | Paleta de las cifras según el fondo de la sección. Se pasa a la prop `tone` de `ula_hero_stat`. |
| `field_inline_lb_sg_cols` | list_string (`1`–`4`) | 1 | **`3`** | Columnas en escritorio. Se pasa a la prop `columns` de `ula_grid_row`. |

### 2.2. Tipo de paragraph `inline_lb_p_stat` (par de cifra)

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `field_inline_lb_st_number` | string | 1 | El número grande («120», «EN»…). → prop `number` de `ula_hero_stat`. |
| `field_inline_lb_st_label` | string | 1 | La etiqueta bajo el número («ECTS»…). → prop `label` de `ula_hero_stat`. |

**Por qué paragraph multivalor y no campos fijos.** Las cifras varían en número entre secciones (4 en
`highlight-grid`, 3 en `stat-row`). Un paragraph multivalor permite **N cifras** sin fijar un máximo, y
reutiliza la misma idea que el hero de la landing (`field_hero_stats` → paragraph `hero_stat`), terreno
conocido.

**Por qué `tone` y `cols` como `list_string` en el bloque.** Las opciones del editor (paleta, columnas) se
modelan como **campos de lista en el propio bloque** (no como variantes del SDC ni tipos de bloque
separados). Es la decisión transversal **D5-mecanismo** del plan (ver
`../plans/paginas-contenido/plan-libreria-inline-blocks.md` §4): un único tipo de bloque cuya plantilla lee
la opción y la traslada a la prop del componente. `tone` por defecto **`light`** porque el uso esperado de
este artefacto es el **body de páginas (fondo claro)**.

**Convención de nombres.** `inline_lb_*` (tipo de bloque), `inline_lb_p_*` (paragraph), `field_inline_lb_*`
(campos) — decisión transversal **D6** del plan. Las abreviaturas: `sg` = stat **g**rid (campos del bloque),
`st` = **st**at (campos del paragraph).

---

## 3. Cómo se consume (lógica en el tema)

El bloque se **crea y coloca** desde el Layout Builder de la página (*Add block → Create custom block →
inline_lb_statgrid*), con la casilla **«Display title» desmarcada**. El flujo de render:

1. **Plantilla del bloque** `templates/content/block--block-content--type--inline-lb-statgrid.html.twig`. La
   sugerencia `block--block-content--type--<bundle>` es la que emite Layout Builder (patrón confirmado con el
   debug de Twig en el CTA band y reconfirmado aquí; un inline block ofrece además sugerencias
   `block--inline-block--<bundle>` y `block--layout-builder`, pero la elegida es la `--type--`).
2. **Armazón estándar de bloque — imprescindible en un inline block.** La plantilla emite
   `<div{{ attributes }}>` + `{{ title_prefix }}` + `{% if label %}…{% endif %}` + `{{ title_suffix }}`. El
   **control de Layout Builder** (lápiz Configure/Move/Remove) viaja en `title_suffix` y en `attributes`
   (`data-contextual-id`); **sin ese armazón, el inline block no se puede editar** (lección documentada en
   `../elements/layout/CONTENT-LAYOUT.md` §11.3–§11.4.1).
3. **Composición en la propia plantilla (no por `{{ content.field }}`).** La plantilla recorre
   `field_inline_lb_stats`, y por cada paragraph construye un `ula_hero_stat` ya renderizado (`include`),
   acumulándolos en un **array** (`stats`). Ese array se pasa al **slot `content`** de `ula_grid_row` junto
   con `columns`. Es **necesario** pasar una **secuencia** (un elemento por celda): el slot trata cada
   elemento del array como una celda; un único string concatenado se trataría como **una sola** celda. Por
   eso este artefacto **no** usa una plantilla de paragraph ni el view display del campo: lee los valores
   planos de cada paragraph y compone los SDC directamente.
4. **Paso de valores — anti-BI.** `number` y `label` se pasan como **valor plano** (`.value`) a las props de
   `ula_hero_stat`; `tone` y `cols` igual, leídos con `|default('dark')` / `|default('3')` en la plantilla
   (los `default` del `.component.yml` no se inyectan de forma fiable en runtime; ver `../ARCHITECTURE.md`
   §6.4). Al pasar valores planos a props, el render **no** atraviesa `field.html.twig` (que en este sitio,
   por herencia de subtema, sirve **Bootstrap Italia**).

**CSS — sin librería ni CSS propios del artefacto.** `ula_grid_row` y `ula_hero_stat` **autoadjuntan** su
propio CSS (son SDC); la paleta `light` vive en `ula_hero_stat.css`. Por eso este artefacto **no** toca la
mecánica de carga de CSS que dio problemas en el piloto (librería registrada + `attach_library` en la
plantilla, ver `../elements/layout/CONTENT-LAYOUT.md` §11.4.2): aquí **no hay** CSS propio que cargar.

> **Configuración en BD, no en git.** El tipo de bloque `inline_lb_statgrid`, el paragraph
> `inline_lb_p_stat`, sus campos, los form/view displays y cada ejemplar colocado son
> **configuración/contenido**: viven en la base de datos, no en el repositorio (ver `../ARCHITECTURE.md`,
> separación de fuentes de verdad). El repo solo versiona el **código**: los componentes `ula_grid_row` /
> `ula_hero_stat` y la plantilla del bloque. La configuración se creó con un **script de un solo uso** (no
> versionado). Cualquier operación sobre esta configuración exige **dump previo** de la BD.

---

## 4. El tono de `ula_hero_stat` (contraste sobre fondo claro)

`ula_hero_stat` se diseñó para el **hero (fondo azul)**: número en `--eu-yellow`, etiqueta en blanco al
65 %. Sobre el **fondo claro** del body, ambos quedaban invisibles (el fallo observado en el piloto). La
solución adoptada (decisión transversal **D1** del plan, opción 1) fue **añadir una prop `tone` al propio
componente**, no una clase envolvente del artefacto ni un componente de cifra nuevo:

- **`dark`** (por defecto): paleta original del hero — número dorado, etiqueta clara. Es la **base** del CSS,
  **sin cambios**, de modo que el hero (que no pasa `tone`) queda intacto.
- **`light`**: override **aditivo** — número `--eu-blue`, etiqueta `--text-light`. Es el que usa este
  artefacto.

Se eligió la prop en el componente (frente a aislar el color en el artefacto) porque `ula_hero_stat` va a
usarse en **ambos fondos** a futuro; centralizar la paleta en el componente es más limpio y reutilizable. El
detalle de la prop está en `../COMPONENTS.md` §3.3. La regla de independencia se mantiene: el contraste lo
resuelve el **design system** (`ula_*`), no Bootstrap Italia.

---

## 5. Relación con otros componentes y artefactos

- **`ula_grid_row`** (`../COMPONENTS.md` §1.2): contenedor en rejilla reutilizable; aquí recibe las cifras
  por el slot `content` y el número de columnas por la prop `columns`. Lo comparten otros artefactos de tipo
  B/C (p. ej. `inline_lb_cardgrid`).
- **`ula_hero_stat`** (`../COMPONENTS.md` §3.3): la celda de cifra; compartida con el hero de la landing
  (allí en `dark`, aquí en `light`).
- **vs. resto de la librería** (`../elements/layout/INLINE-BLOCKS-CATALOG.md`): `statgrid` es el patrón **B**
  (campos → composición de SDC). Sirve de referencia para los demás artefactos del catálogo en cuanto a
  armazón de bloque, composición por array a un slot, y modelado de opciones por `list_string`.
