# Entidad — bloque de contenido `section_header` (Section header)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.6.3 · **Naturaleza:** **tipo de bloque de contenido** (`block_content`), **no** un
> tipo de contenido (nodo). · **Mecanismo de consumo:** bloque colocado en Layout Builder + **plantilla del
> bloque que compone un componente SDC** (`ula_section_header`), mismo patrón que el CTA band (ver
> `cta_band.md`, `../COMPONENTS.md` §1.5 y `../CONCEPTOS-DRUPAL.md`).

---

## 1. Qué es y por qué existe

`section_header` modela la **cabecera de una sección** de página: la etiqueta corta (tag) con su rayita
dorada, el título de la sección y una descripción breve opcional. Es el patrón que en la maqueta aparece
como `.section-tag` + `.section-title` + `.section-desc`, repetido en cada sección (Program Overview,
Curriculum, Careers, Faculty & Research, Admissions…). Es, probablemente, el patrón **más reutilizable** del
sitio. La presentación la pone el componente propio `ula_section_header` (ver `../COMPONENTS.md` §1.5).

**Por qué un tipo de bloque y no un tipo de contenido (nodo).** Una cabecera de sección **no es una página**:
es una pieza que se **coloca dentro** de una página y se repite. Esa es la naturaleza de un **bloque de
contenido** (`block_content`). Modelarlo como block type permite crear un **ejemplar por sección** (con su
texto) y colocarlo donde toque en Layout Builder.

**Mismo mecanismo que el CTA band.** Se adopta deliberadamente el patrón ya validado del CTA band
(block_content + plantilla que compone el SDC), por coherencia y por ser terreno conocido. Encaja con que la
página About siga la arquitectura de Layout Builder y con que otras páginas adopten ese modelo.

**Acoplamiento cabecera ↔ contenido (límite conocido).** A diferencia del CTA band (pieza de cierre
aislada), una cabecera de sección **encabeza el contenido que va debajo**. Al ser bloques separados en Layout
Builder, mantener juntas cabecera y contenido es **disciplina del editor**, no algo que el sistema fuerce
(igual que la unicidad del hero es editorial). Es un límite asumido del enfoque actual, atado al modelo de
secciones de las páginas, aún abierto (ver `../elements/layout/CONTENT-LAYOUT.md` §9.3).

---

## 2. Campos (tipo de bloque `section_header`)

| Campo | Tipo | Card. | Requerido | Para qué |
|---|---|---|---|---|
| **Block description** (base) | — | 1 | sí | Nombre **administrativo** del ejemplar (patrón «Section header - About : {tag}»); identifica el bloque en la gestión. **No** se muestra al visitante. |
| `field_section_tag` | string | 1 | **no** | Etiqueta corta de la sección («Admissions»). → slot `tag`. Opcional. |
| `field_section_title` | string | 1 | **sí** | Título de la sección. → slot `title`. |
| `field_section_description` | string_long | 1 | **no** | Párrafo descriptivo. Texto plano. → slot `description`. Opcional. |

Solo `field_section_title` es obligatorio; `tag` y `description` son **opcionales** (coinciden con los slots
opcionales del componente).

---

## 3. Cómo se consume (lógica en el tema)

El bloque se **coloca** en una sección del **Layout Builder** de la página, con la casilla **«Display title»
desmarcada** (la etiqueta administrativa no se muestra). El flujo de render:

1. **Plantilla del bloque** `templates/content/block--block-content--type--section-header.html.twig`. La
   sugerencia `block--block-content--type--section-header` es la que emite Layout Builder (mismo patrón
   `block--block-content--type--<bundle>` confirmado con el debug de Twig en el CTA band).
2. La plantilla **compone** `ula_section_header` por inclusión, pasando los campos como **valor crudo**
   (`content['#block_content'].field_*.value`), no como render array: así no pasan por `field.html.twig` (que
   en este sitio, por herencia de subtema, sirve **Bootstrap Italia**) ni meten `<div class="field…">` dentro
   de los elementos del componente. Mismo criterio que el CTA band (ver `cta_band.md` §3).
3. **Campos opcionales con guard.** `tag` y `description` se pasan **solo si no están vacíos**: la plantilla
   comprueba `field_section_*.isEmpty` y pasa `null` cuando no hay valor. Esto es **necesario**: acceder a
   `.value` de un campo vacío **rompía el render** del bloque. Con el guard, el componente recibe `null` y, por
   su `{% if %}`, no pinta esa pieza. `title` (obligatorio) se pasa directo.

> **Configuración en BD, no en git.** El tipo de bloque `section_header`, sus campos y cada ejemplar son
> **configuración/contenido**: viven en la base de datos, no en el repositorio (ver `../ARCHITECTURE.md`,
> separación de fuentes de verdad). El repo solo versiona el **código**: el componente `ula_section_header` y
> la plantilla del bloque. Los ejemplares de About se crearon con un **script de un solo uso** (no versionado)
> a partir de las cabeceras de la maqueta. Cualquier operación sobre esta configuración exige **dump previo**.

---

## 4. Relación con otros componentes

- **vs. `ula_hero`** (`COMPONENTS.md` §1.3): el hero es la cabecera de **página** (arriba, fondo azul,
  full-bleed); `section_header` es la cabecera de **sección** dentro de la página (fondo claro). Comparten la
  idea «etiqueta corta + título», con tratamiento distinto (rayita dorada vs. píldora).
- **vs. `cta_band`** (`cta_band.md`): comparten **mecanismo** (block_content + plantilla que compone un SDC),
  pero distinto rol (cierre vs. cabecera de sección) y distinto sitio en la página.
