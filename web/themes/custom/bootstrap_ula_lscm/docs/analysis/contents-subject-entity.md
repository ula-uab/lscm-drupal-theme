# Análisis — entidad `ct_contents_subject` (Contents - Subject)

> **Tipo de documento:** *análisis* de una entidad **preexistente** del sitio (no diseñada en este
> proyecto). Va en `analysis/` —no en `entities/`— porque documenta un hallazgo de investigación
> sobre contenido heredado, no una entidad que hayamos diseñado nosotros. Se documenta de cara a la
> **fase futura de adaptación de todo el sitio** (desvinculación de Bootstrap Italia), donde esta
> entidad y su relación con los semestres serán relevantes.
>
> **Estado:** preexistente, **no** la creamos ni la tocamos. Documentada en v1.1.6 a petición.

---

## 1. Qué es

`ct_contents_subject` ("Contents - Subject") modela las **asignaturas reales del máster**. Tiene
**15 nodos** (las 15 asignaturas del plan de estudios). Alimenta la sección de contenidos del sitio
actual.

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Nombre de la asignatura. |
| `field_ct_ctssbj_modal_title` | text | Título para el modal (la asignatura se muestra en un modal/popover en el sitio actual). |
| `field_ct_ctssbj_semester` | entity_reference | **Referencia al semestre** al que pertenece la asignatura. |
| `field_order` | integer | Orden. |

## 3. El hallazgo importante: relación asignatura → semestre

El dato más relevante para el futuro es **`field_ct_ctssbj_semester`**: cada asignatura **ya está
vinculada de forma estructurada a un semestre** en el sitio actual. Es decir, existe una relación real
asignatura → semestre en los datos.

Esto contrasta con cómo se resolvió la home (ver `../entities/programme-semester.md`): allí, las
asignaturas de cada semestre se redactan como una **lista de texto** dentro de la descripción
enriquecida del semestre (un resumen visual, suficiente para la home). Son dos representaciones
distintas del mismo hecho:

- **Sitio actual (datos estructurados):** 15 asignaturas, cada una un nodo, cada una referenciando su
  semestre vía `field_ct_ctssbj_semester`.
- **Home (resumen visual):** las asignaturas como texto en la descripción del semestre, sin vínculo
  estructurado.

## 4. Por qué importa para la fase futura

Cuando se rehaga el sitio completo (desvinculación de Bootstrap Italia), habrá que decidir cómo se
relacionan estas representaciones. Posibilidades a estudiar entonces:

- Si la sección de contenidos del sitio se rehace con el patrón del tema (entidad propia + componente
  ULA), `ct_contents_subject` y su relación con el semestre serían la fuente estructurada.
- Podría plantearse si la home debería derivar sus asignaturas de esta relación real (en lugar del
  texto redactado a mano), unificando la fuente. Eso acoplaría la home a esta entidad —decisión a
  tomar con criterio en su momento, igual que se pospuso la relación universidad↔semestre.
- El `field_ct_ctssbj_modal_title` sugiere que las asignaturas se presentan en **modales** en el sitio
  actual: relevante para entender el patrón de interactividad heredado (que también se rehará).

## 5. Lista de asignaturas (15 nodos)

Basics of LSCM · Systems Thinking · Decision Making · Project Management · Engineering fundamentals ·
Information Technology · Material Handling and Transportation Technologies (MHT) · Supply Chain Network
& Flow Management · Generic Management Skills · LSCM European Dimension · Logistics Information Systems
· Logistics Management · Logistics System Implementation & Ramp-Up · Logistics Management & Control
System Specification & Evaluation · Material Handling System Design & Analysis.

> Nota: el conjunto de asignaturas y su reparto por semestre es la **fuente real** del contenido que,
> en la home, aparece resumido en las descripciones de los semestres. Cualquier discrepancia entre
> ambos se resolvería en la fase de adaptación.
