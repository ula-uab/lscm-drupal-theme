# Entidad — bloque de contenido `inline_lb_stack` (pila heterogénea de piezas)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque de
> contenido** (`block_content`) + **dos tipos de paragraph** (`inline_lb_p_text`, `inline_lb_p_pills`),
> colocado como **inline block de Layout Builder**. · **Mecanismo:** patrón C heterogéneo. Ver
> `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.5, `inline-lb-richtext.md` y `inline-lb-pills.md` (las
> piezas reutilizan su render).

---

## 1. Qué es y por qué existe

`inline_lb_stack` modela un body que **mezcla varias piezas** (texto enriquecido, pastillas) en un **único
bloque editable**, en el orden que el editor decida. Es el comodín para secciones que combinan piezas sin
justificar un artefacto propio.

**Decisión de composición (estaba diferida).** La plantilla del bloque **itera el campo Paragraphs y compone
cada pieza según su bundle** (un `switch`), igual que statgrid/steps/cardgrid (componer en la plantilla
leyendo la entidad), en vez del `{{ content.field }}` del piloto (que pasaría por `field.html.twig` = BI). No
hay plantillas de paragraph: los paragraphs solo guardan datos.

---

## 2. Modelo de datos

### 2.1. Tipo de bloque `inline_lb_stack`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| **Block description** (base) | — | 1 | Nombre administrativo. No se muestra. |
| `field_inline_lb_stack` | Paragraphs **heterogéneo** (`inline_lb_p_text`, `inline_lb_p_pills`) | **multivalor** | Las piezas apiladas, en el orden del editor. |

### 2.2. Tipos de paragraph (piezas)

| Paragraph | Campo | Tipo | Para qué |
|---|---|---|---|
| `inline_lb_p_text` | `field_inline_lb_pt_body` | text_long (Basic HTML) | Pieza de texto enriquecido. |
| `inline_lb_p_pills` | `field_inline_lb_pp_labels` | string (multivalor) | Pieza de pastillas. |

---

## 3. Cómo se consume (lógica en el tema)

Plantilla `templates/content/block--block-content--type--inline-lb-stack.html.twig`, con el **armazón
estándar de bloque** y el contenedor `.inline-lb-stack` (flex column con `gap`). Itera `field_inline_lb_stack`
y, según `p.bundle`:

- **`inline_lb_p_text`:** render array `processed_text` dentro de `.inline-lb-richtext--plain` (reutiliza el
  CSS y la librería de `inline_lb_richtext`).
- **`inline_lb_p_pills`:** array de `ula_pill` → slot `pills` de `ula_pill_group` (variante `pill`).

**CSS.** El contenedor `.inline-lb-stack` lo aporta la **librería `inline_lb_stack`** (adjuntada con
`attach_library`); las piezas de texto reutilizan la librería `inline_lb_richtext` (adjuntada también aquí);
las pastillas son SDC (autoadjuntan). Anti-BI en todas las piezas (valores planos / `processed_text`, sin
`field.html.twig`).

> **Configuración en BD, no en git.** Tipos de bloque/paragraph, campos y ejemplares en BD; el repo versiona
> la plantilla, el CSS del contenedor y la librería. Dump previo. Config por script (no versionado); el campo
> Paragraphs heterogéneo se clonó del de `inline_lb_statgrid` fijando los **dos** target_bundles.

## 4. Mejora futura

> **[MEJORA] Ampliar tipos de pieza.** Hoy admite texto y pastillas. Candidatos a añadir como nuevos
> paragraph types de pieza: cifra(s) (reutilizando `ula_hero_stat`), cita/quote, imagen, sub-encabezado,
> botón/CTA, o mini-tarjeta. Cada uno = nuevo paragraph type + su rama en el `switch` de la plantilla.

## 5. Relación con otros

- **Reutiliza** el render de `inline-lb-richtext.md` (texto) y los SDC `ula_pill`/`ula_pill_group` de
  `inline-lb-pills.md` (pastillas). Es el único artefacto que combina piezas de otros.
