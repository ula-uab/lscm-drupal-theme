# Entidad — `ct_programme_semester` (Programme semester)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** v1.1.6 · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_programme_semester` modela los **semestres del recorrido académico** (journey) del máster. Cada
nodo es un semestre. Alimenta la sección del journey de la home (componente `ula_sem_card`).

Es la colección más rica en campos y la **última de las 8** de la home en migrarse a editable. Combina
todo lo aprendido en las anteriores: descripción **rich text** (como especializaciones) e **imágenes
de Media**, esta vez **multivalor** (uno o dos logos de universidad por semestre).

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Título temático del semestre ("Foundations of LSCM"…). → prop `title`. |
| `field_sem_label` | string | Etiqueta del semestre ("Semester 1"). → prop `semester`. |
| `field_sem_university` | string | Universidad · ciudad, como texto ("UAB · Barcelona"). → prop `university`. |
| `field_sem_logos` | entity_reference → media (bundle `image`), **cardinalidad 2** | Uno o dos logos de universidad. → prop `logos` (array de URLs). |
| `field_sem_description` | text_long (formato **Basic HTML**) | Descripción enriquecida: las asignaturas como lista. → prop `description` (HTML). |
| `field_sem_variant` | string ('1'..'4') | Variante de color de la tarjeta (caja de logos + pastilla). → prop `variant`. |
| `field_order` | integer | Orden de los semestres. |

**Logos multivalor.** `field_sem_logos` tiene **cardinalidad 2**: admite uno o dos logos (algunos
semestres se imparten en una universidad, otros en dos — "RTU or UASW"). Referencia a la biblioteca de
**Media** (bundle `image`). SVG quedó descartado como formato; se usan PNG/JPG.

**Descripción enriquecida.** Mismo enfoque que `ct_programme_specialisation`: formato **Basic HTML**
(restringido a solo ese formato en "Allowed text formats"), las asignaturas como lista `<ul>`. El
antiguo `subjects[]` de la maqueta se redacta ahora dentro de esta descripción.

**Variant y university se mantienen** (a diferencia de especializaciones, donde el variant se
eliminó): aquí el color por semestre aporta y la pastilla de universidad en texto sigue presente,
además de los logos.

---

## 3. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), con resolvers
especiales para el rich text y los logos multivalor:

```
journey_semesters  ← get_collection('ct_programme_semester', {
    semester:    field_sem_label (texto),
    logos:       _bootstrap_ula_lscm_media_image_urls(nodo, 'field_sem_logos'),  // multivalor → array URLs
    university:  field_sem_university (texto),
    title:       label del nodo,
    description: _bootstrap_ula_lscm_text_value(nodo, 'field_sem_description'),   // rich text → HTML
    variant:     field_sem_variant (texto),
  })
```

- **`_bootstrap_ula_lscm_media_image_urls()`** — variante **multivalor** del resolver de imágenes de
  Media: devuelve un array con las URLs de todas las imágenes referenciadas (aquí, los 1-2 logos).
  Se añadió en esta colección, junto a la versión singular usada por especializaciones.
- **`_bootstrap_ula_lscm_text_value()`** — render del rich text (compartido con especializaciones).

El array se pasa como prop `journey_semesters` al marco, que lo pinta con `ula_sem_card`. Si la carga
viene vacía, el marco usa su array de fábrica (`|default`).

---

## 4. Rediseño del componente `ula_sem_card`

Como las especializaciones, esta colección conllevó **rediseñar el componente**:

- **Logos en vez de icono:** la antigua caja con un emoji se sustituye por una caja (del color de la
  variante) con **uno o dos logos** de universidad, mostrados con **altura normalizada** (`height`
  fijo + `object-fit: contain`) sea cual sea el tamaño/formato de origen, y un `gap` entre los dos.
- **Descripción enriquecida** (HTML) en vez de la lista `subjects[]`; el CSS estila el `<ul>/<li>`
  manteniendo el aspecto de asignaturas (punto amarillo), sin depender de clases.
- **Cajas de igual altura:** la tarjeta es `flex column` y el cuerpo (`.sem-body`) crece (`flex: 1`);
  la rejilla de la sección (`.journey-track`) las estira a la altura de la más alta vía
  `align-items: stretch`. (Antes era `align-items: start`, que dejaba alturas dispares; se cambió en
  el CSS del marco.) **No** se usa `height: 100%` (frágil: dependía de un padre con altura, y
  deformaba el componente en aislado).
- Se mantienen `semester`, `university` (texto), `title` y `variant`.

---

## 5. Contenido actual (datos de la maqueta)

| order | label | university | title | variant |
|---|---|---|---|---|
| 0 | Semester 1 | UAB · Barcelona | Foundations of LSCM | 1 |
| 1 | Semester 2 | RTU · Riga | Advanced Logistics | 2 |
| 2 | Semester 3 | RTU or UASW | Specialisation | 3 |
| 3 | Semester 4 | RTU or UASW | Master's Thesis | 4 |

Las asignaturas de cada semestre se redactan en la descripción enriquecida. Los **logos** se añaden
manualmente desde la biblioteca de Media al editar cada nodo (no los pone el script de creación).
