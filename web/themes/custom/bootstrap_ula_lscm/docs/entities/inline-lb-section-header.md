# Entidad — bloque de contenido `inline_lb_section_header` (cabecera de sección, inline)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque
> de contenido** (`block_content`) colocado como **inline block de Layout Builder**. · **Mecanismo:** patrón
> B (block type + plantilla que compone un componente SDC). Reutiliza el SDC `ula_section_header` **sin
> cambios**. Ver `../elements/layout/INLINE-BLOCKS-CATALOG.md` §3.1, `inline-lb-statgrid.md` (patrón B de
> referencia) y `section-header.md` (el bloque **reutilizable** equivalente, que se conserva intacto).

---

## 1. Qué es y por qué existe

`inline_lb_section_header` modela la **cabecera de sección** (tag + título + descripción) como **inline
block** del body, editable en la propia página por el lápiz de Layout Builder. Misma presentación que el
bloque **reutilizable** `section_header` (mismo SDC `ula_section_header`), distinto **mecanismo de
colocación**: aquí la cabecera es contenido específico de la página, no una pieza compartida entre páginas.

**Por qué un tipo nuevo y no reaprovechar el `section_header` reutilizable (Opción 1).** El `section_header`
reutilizable se modeló antes de adoptar el modelo de inline blocks; su plantilla emite el `<header>`
**pelado** (sin armazón de bloque), lo que funciona como reutilizable (se edita desde
`/admin/content/block`) pero **pierde la edición** al colocarse como inline block. Se crea un **tipo de
bloque nuevo** con su plantilla con armazón, dejando **intacto** el reutilizable y sus cabeceras ya
colocadas en `/about`. (Alternativa descartada: arreglar el tipo existente para servir en ambos modos —
cambiaría el DOM de todas las cabeceras ya colocadas.)

---

## 2. Campos (tipo de bloque `inline_lb_section_header`)

| Campo | Tipo | Card. | Requerido | Para qué |
|---|---|---|---|---|
| **Block description** (base) | — | 1 | sí | Nombre administrativo del ejemplar. No se muestra. |
| `field_inline_lb_sh_tag` | string | 1 | **no** | Etiqueta corta → slot `tag`. Opcional. |
| `field_inline_lb_sh_title` | string | 1 | **sí** | Título → slot `title`. |
| `field_inline_lb_sh_description` | string_long | 1 | **no** | Descripción → slot `description`. Opcional. |

---

## 3. Cómo se consume (lógica en el tema)

Plantilla `templates/content/block--block-content--type--inline-lb-section-header.html.twig`. Compone
`ula_section_header` pasando los campos como **valor plano** (`.value`, anti-BI) con **guard `isEmpty`** en
los opcionales (mismo criterio que `section-header.md` §3).

Dos puntos propios del inline block:

1. **Armazón estándar de bloque, imprescindible.** La plantilla envuelve el `include` del SDC en
   `<div{{ attributes }}>` + `title_prefix` + `{% if label %}…{% endif %}` + `title_suffix`. El lápiz de
   Layout Builder viaja en `title_suffix` y `attributes` (`data-contextual-id`); sin armazón el inline block
   no se puede editar (lección de `../elements/layout/CONTENT-LAYOUT.md` §11.3–§11.4.1).
2. **Clase marcadora para el ritmo (ADR-LAYOUT-006).** Al envolver la cabecera en el armazón,
   `.ula-section-header` deja de ser hijo directo de `.layout__region`, así que el selector de ritmo
   `> * + .ula-section-header` no casa. La plantilla añade la clase **`inline-lb-section-header`** al `<div>`
   del bloque (`attributes.addClass`), y `css/lscm-page.css` añade la regla
   `.layout__region > * + .inline-lb-section-header { margin-top: var(--lb-section-gap); }`. Validado sobre
   el render real.

> **Configuración en BD, no en git.** Tipo de bloque, campos, form display y ejemplares son
> configuración/contenido (BD, no repo). El repo versiona el **código** (plantilla; el SDC ya existía). Se
> creó con un **script de un solo uso** (no versionado). Dump previo obligatorio. Ver `../ARCHITECTURE.md`.

---

## 4. Relación con otros

- **vs. `section_header` (reutilizable, `section-header.md`):** misma presentación (mismo SDC), distinto
  mecanismo (reutilizable vs inline block). Conviven; la migración de las cabeceras de `/about` al modelo
  inline es una tarea de contenido posterior, no forzada.
- **Patrón B:** comparte con `inline-lb-statgrid.md` el armazón de bloque y el paso de valores planos al SDC.
