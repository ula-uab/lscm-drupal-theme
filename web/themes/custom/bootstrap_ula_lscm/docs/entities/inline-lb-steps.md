# Entidad — bloque de contenido `inline_lb_steps` (pasos / cronología)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque de
> contenido** (`block_content`) + **tipo de paragraph** `inline_lb_p_step`, colocado como **inline block de
> Layout Builder**. · **Mecanismo:** patrón C (paragraphs dentro de un bloque) que compone el SDC
> `ula_timeline_item` por paso. Ver `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.6, `inline-lb-statgrid.md`
> (patrón de composición por array a un contenedor) y `../COMPONENTS.md` §3.4 (`ula_timeline_item`).

---

## 1. Qué es y por qué existe

`inline_lb_steps` modela una **cronología de pasos** (timeline): cada paso es un punto + línea conectora +
título + descripción. Cubre la **«Application Roadmap»** de la maqueta (§5). Decisión del hito: la roadmap
**no** se hace con una lista numerada en un panel, sino con un artefacto de pasos dedicado, **más
impactante** visualmente, reutilizando el componente `ula_timeline_item` que ya existía (origen: la sección
«Admissions» de la landing).

---

## 2. Modelo de datos

### 2.1. Tipo de bloque `inline_lb_steps`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| **Block description** (base) | — | 1 | Nombre administrativo. No se muestra. |
| `field_inline_lb_steps` | Paragraphs (`inline_lb_p_step`) | **multivalor** | Los pasos: un delta por paso. |

### 2.2. Tipo de paragraph `inline_lb_p_step`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `field_inline_lb_sp_title` | string | 1 | Título del paso → prop `title`. |
| `field_inline_lb_sp_description` | string_long | 1 | Descripción → prop `description`. |

---

## 3. Cómo se consume (lógica en el tema)

Plantilla `templates/content/block--block-content--type--inline-lb-steps.html.twig`, con el **armazón
estándar de bloque**. Recorre `field_inline_lb_steps` y, por cada paragraph, compone un `ula_timeline_item`
**dentro del contenedor `.timeline`** (flex column).

- **El contenedor `.timeline` lo aporta el artefacto, no el componente** (así lo indica `ula_timeline_item`):
  vive en `css/inline-lb-steps.css`, registrado como **librería `inline_lb_steps`** y adjuntado con
  `attach_library`. Replica el `.timeline` de la landing **sin** su `margin-top` (en páginas de contenido el
  ritmo lo aporta el marco, ADR-LAYOUT-006).
- **Última línea conectora:** se pasa `show_line: not loop.last`, de modo que el último paso no dibuja la
  línea final. Mismo patrón que la landing.
- **Anti-BI:** título y descripción se pasan como valor plano (`.value`) a las props del SDC.

> **Configuración en BD, no en git.** Tipo de bloque, paragraph, campos y ejemplares en BD; el repo versiona
> la plantilla, el CSS del contenedor y la librería. El SDC `ula_timeline_item` ya existía. Dump previo
> obligatorio. La config se creó con script de un solo uso (no versionado); el campo Paragraphs se clonó del
> de `inline_lb_statgrid`.

## 4. Relación con otros

- **`ula_timeline_item`** (`../COMPONENTS.md` §3.4): el paso; compartido con la landing.
- **Patrón:** misma idea que `inline-lb-statgrid.md` (paragraph multivalor → componer un SDC por delta),
  pero el contenedor es HTML propio (`.timeline`), no un SDC.
