# Entidad — `ct_university_semester` (University–Semester)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
> Es una **entidad de relación** (through entity): cada nodo representa el cruce de otras dos
> entidades (una universidad × un semestre).
>
> **Creada en:** v1.3.0 (Sub-hito 4a) · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002 y ADR-004).

---

## 1. Qué es y por qué existe

`ct_university_semester` modela la **relación entre una universidad y un semestre**: "qué hace una
universidad concreta en un semestre concreto". Cada nodo es un cruce universidad × semestre.

**Por qué una entidad de relación y no un campo.** La información asociada a este cruce (el texto que
se muestra al pulsar una pastilla de semestre en la tarjeta de universidad) **no es un atributo de la
universidad ni del semestre por separado**: depende de la **combinación** de ambos. "RTU en el
Semestre 3" tiene un contenido distinto de "TH Wildau en el Semestre 3". Una información que depende
de la combinación de dos entidades es el signo de que **la combinación misma es una entidad** (patrón
"through entity" / entidad de unión).

**Consumidores (presente y futuro).** Esta relación se diseñó **previendo más de un consumidor**, por
eso es una entidad independiente y no un campo dentro de la universidad:
- **Ahora:** las pastillas de semestre de la tarjeta `ula_uni_card` en la home (Sub-hito 4a; el modal
  al pulsarlas, Sub-hito 4b).
- **A futuro:** la página **Consortium** (aún no existe en Drupal), cuyo objetivo será, entre otros,
  visualizar qué hace cada universidad en cada semestre. Al ser una entidad independiente, esa página
  podrá consultar la relación desde el ángulo que necesite (por universidad, por semestre, en tabla)
  sin reestructurar nada.

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Identificación interna del cruce (p. ej. "RTU — Semester 3"). No se muestra al visitante. |
| `field_us_university` | entity_reference → **node** `ct_about_consortium_university` | Qué universidad. |
| `field_us_semester` | entity_reference → **taxonomy_term** vocabulario `semester` | Qué semestre. **Lee** la taxonomía existente (la misma que usan las asignaturas); no la altera. |
| `field_us_pill_label` | string | Etiqueta de la pastilla tal como se ve en la tarjeta ("Semester 3"). Es propia: puede diferir del nombre del término de taxonomía. |
| `field_us_modal_text` | text_long (formato **Basic HTML**) | Texto del modal/popover de esa pastilla (específico del cruce). |
| `field_order` | integer | Orden de las pastillas de una misma universidad. |

**Sobre las dos referencias.** Es la primera entidad del tema con **dos `entity_reference` de
distinto `target_type`**: una a un **nodo** (universidad) y otra a un **término de taxonomía**
(semestre). Ambas se rellenan seleccionando (autocompletar), no escribiendo. Referenciar la taxonomía
`semester` es el mismo patrón que ya usa `ct_contents_subject` (ver
`../analysis/contents-subject-entity.md`).

**Sobre `field_us_pill_label`.** Se mantiene una etiqueta propia porque la pastilla de la maqueta no
siempre coincide con el nombre del término: el término es "Third Semester (RTU)" pero la pastilla dice
"Semester 3". La etiqueta corta va en la pastilla; el matiz (p. ej. la opcionalidad de 3º/4º) se
explica en el texto del modal, no en la etiqueta.

---

## 3. Qué NO está aquí: la pastilla "Lead Partner"

La tarjeta de universidad muestra, además de las pastillas de semestre, una pastilla **"Lead
Partner"** (solo en UAB). Esa pastilla **NO es un nodo de esta entidad**, porque "Lead Partner" no es
un semestre: es un **rol/atributo de la universidad**. Se modela con dos campos en
`ct_about_consortium_university`:

- `field_uni_is_lead` (boolean): si la universidad es la líder del consorcio.
- `field_uni_lead_modal_text` (text_long, Basic HTML): el texto de su modal.

La etiqueta "Lead Partner" es **fija** (en el código del tema), no editable. La unicidad ("solo una
líder") la garantiza el editor al marcar el booleano en una sola universidad; no se fuerza a nivel de
datos. Ver ADR-004.

---

## 4. Cómo se consume (lógica en el tema)

La carga de universidades (`_bootstrap_ula_lscm_get_universities()`) construye las pastillas (`tags`
de `ula_uni_card`) combinando las **dos fuentes**, mediante
`_bootstrap_ula_lscm_get_university_pills($university)`:

1. **Pastillas de semestre:** consulta los nodos `ct_university_semester` que referencian esa
   universidad (`field_us_university`), ordenados por `field_order`. De cada uno:
   `{label: field_us_pill_label, info: field_us_modal_text (rich text)}`.
2. **Pastilla "Lead Partner":** si la universidad tiene `field_uni_is_lead = true`, se añade al final
   `{label: 'Lead Partner', info: field_uni_lead_modal_text}`.

El resultado es un array de `{label, info}`, exactamente lo que `ula_uni_card` espera en `tags`. El
componente pinta cada pastilla con `info` como un **botón** que, al pulsarse, abre un **modal**
(`<dialog>` nativo único en el marco) con el contenido de `info` (Sub-hito 4b, v1.3.1). Las pastillas
sin `info` son etiquetas estáticas.

---

## 5. Contenido actual (Sub-hito 4a)

6 nodos de relación + el marcado de UAB como lead:

| Universidad | Semestre (término) | pill_label |
|---|---|---|
| UAB | First Semester | Semester 1 |
| RTU | Second Semester | Semester 2 |
| RTU | Third Semester (RTU) | Semester 3 |
| RTU | Fourth semester (RTU) | Semester 4 |
| TH Wildau | Third Semester (TH Wildau) | Semester 3 |
| TH Wildau | Fourth semester (TH Wildau) | Semester 4 |

+ UAB con `field_uni_is_lead = true` → pastilla "Lead Partner".

Resultado en la home: UAB = Semester 1 + Lead Partner; RTU = Semester 2/3/4; TH Wildau = Semester 3/4.

Los **textos de modal** se crearon provisionales; se afinan editando cada nodo de relación (y el nodo
UAB para el de Lead Partner). La opcionalidad de 3º/4º (elección RTU vs TH Wildau) se explica en esos
textos.
