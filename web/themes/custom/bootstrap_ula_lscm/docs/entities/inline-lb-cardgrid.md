# Entidad — bloque de contenido `inline_lb_cardgrid` (rejilla de tarjetas)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque de
> contenido** (`block_content`) + **tipo de paragraph** `inline_lb_p_card`, colocado como **inline block de
> Layout Builder**. · **Mecanismo:** patrón C (paragraphs dentro de un bloque) que compone `ula_card_simple`
> en `ula_grid_row`. Ver `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.3, `inline-lb-statgrid.md` y
> `../COMPONENTS.md` (§1.1 `ula_card_simple`, §1.2 `ula_grid_row`).

---

## 1. Qué es y por qué existe

`inline_lb_cardgrid` modela una **rejilla de tarjetas simples** (título + cuerpo rich text). Cubre «card-grid»
(§2: Foundational Modules, Specialization Pathways, Software & Tools) y «adm-cols» (§5: Academic Background,
Technical Skills). Tipo C porque el número de tarjetas es variable y el editor las apila.

---

## 2. Modelo de datos

### 2.1. Tipo de bloque `inline_lb_cardgrid`

| Campo | Tipo | Card. | Por defecto | Para qué |
|---|---|---|---|---|
| **Block description** (base) | — | 1 | — | Nombre administrativo. No se muestra. |
| `field_inline_lb_cards` | Paragraphs (`inline_lb_p_card`) | **multivalor** | — | Las tarjetas. |
| `field_inline_lb_cg_cols` | **integer** (1–4) | 1 | **3** | Columnas en escritorio → prop `columns` de `ula_grid_row`. |

**Por qué `cols` es integer y no `list_string`.** En este sitio crear un `list_string` por script falla (ver
nota transversal en `../ARCHITECTURE.md`). Un campo **integer** (min 1, max 4, def. 3) es scriptable, evita
ese problema y no requiere paso por UI; la plantilla lo convierte a string para la prop `columns`.

### 2.2. Tipo de paragraph `inline_lb_p_card`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `field_inline_lb_cd_title` | string | 1 | Título → slot `title`. |
| `field_inline_lb_cd_body` | text_long (Basic HTML) | 1 | Cuerpo rich text (la lista) → slot `body`. |

---

## 3. Cómo se consume (lógica en el tema) — y la validación D3

Plantilla `templates/content/block--block-content--type--inline-lb-cardgrid.html.twig`, con el **armazón
estándar de bloque**. Recorre las tarjetas, compone un `ula_card_simple` por tarjeta y las pasa al slot
`content` de `ula_grid_row` con `columns`.

**D3 — cuerpo rico por slot (validado).** `ula_card_simple` pinta `body` con `{{ body }}` (sin `|raw`). Para
que el HTML del Basic HTML se **renderice** (y no se escape) **sin tocar el SDC** (lo usa `ula_faculty_card`)
ni atravesar `field.html.twig`, el `body` se pasa como **render array `processed_text`** (elemento de core
que aplica el filtro del formato). El `title` se pasa como valor plano. **Validado en el Drupal real:** el
cuerpo rico (párrafos y listas) se renderiza correctamente. Quedó descartado el plan B (plantilla de tarjeta
propia).

**Variante `adm-box` (descartada).** El catálogo contemplaba viñetas con check dorado para §5; se descarta
porque el propio `ula_card_simple.css` establece que sobre fondo blanco no se usa el dorado como color
protagonista. La lista usa el estilo por defecto del componente.

**CSS.** `ula_card_simple` y `ula_grid_row` son SDC y autoadjuntan su CSS (incluido el estilo de
`p`/`ul`/`ol`/`li` del cuerpo). El artefacto **no** necesita librería propia.

> **Configuración en BD, no en git.** Tipo de bloque, paragraph, campos y ejemplares en BD; el repo versiona
> la plantilla. Los SDC ya existían. Dump previo. La config se creó con script (no versionado); el campo
> Paragraphs se clonó del de `inline_lb_statgrid`.

## 4. Relación con otros

- **`ula_card_simple`** (`../COMPONENTS.md` §1.1) y **`ula_grid_row`** (§1.2): reutilizados sin cambios.
- **Patrón:** como `inline-lb-statgrid.md` y `inline-lb-steps.md` (paragraph multivalor → componer SDC por
  delta dentro de un contenedor).
