# Entidad — `ct_admission_journey_step` (Admission journey step)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** v1.1.x · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_admission_journey_step` modela **las fases del proceso de admisión** del máster, para el
**timeline-resumen** que aparece en la home. Cada nodo es **una fase** del proceso.

Las cuatro fases de la cronología de admisión son:

1. **Application process** — actor: el futuro estudiante.
2. **Selection process** — actor: el comité de selección.
3. **Visa & Accommodation** — actores: el servicio de apoyo internacional y el estudiante admitido.
4. **Registration** — actores: la oficina académica y el estudiante admitido.

**Por qué una entidad nueva y no reutilizar las de Admission.** La sección Admission del sitio (a
rehacer en una fase posterior) ya tiene entidades que describen el **detalle paso a paso** de algunas
fases: `ct_admission_preenrolment_step` (4 pasos: Application, Preparation, Communication,
Reservation), `ct_admission_registration_step` (4 pasos: Orientation, Tutorial, Documents, Payment) y
`admission_visa_services`. Pero esas entidades modelan el **detalle** (los pasos *dentro* de cada
fase), mientras que la home necesita el **resumen** (una entrada *por fase*). Son dos niveles de
granularidad distintos:

- **Detalle** (Admission): varios pasos por fase → entidades existentes.
- **Resumen** (home): una entrada por fase (4 fases) → esta entidad.

Además, las entidades de Admission **no están modeladas de forma homogénea hoy** (la fase de selección
no existe como tipo; `admission_visa_services` tiene una estructura distinta y un solo nodo), y la
sección está a medio desarrollar. Acoplar la home a ese modelo inestable sería prematuro. Por eso la
home tiene su **propia entidad de resumen, independiente**: la home y Admission juegan papeles
distintos y se mantienen por separado (ver decisión en
`../analysis/` cuando se documente el rediseño de Admission).

> **Relación futura.** Cuando se rehaga la sección Admission (fase posterior, en el marco de la
> desvinculación de Bootstrap Italia), habrá que decidir si el resumen de la home se mantiene
> independiente o se vincula con el detalle homogeneizado. De momento, **independiente**.

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Nombre de la fase ("Application process", "Selection process", "Visa & Accommodation", "Registration"). → prop `title` de `ula_timeline_item`. |
| `field_journey_summary` | string_long | Resumen de la fase para la home (1–2 frases). → prop `description` de `ula_timeline_item`. |
| `field_order` | integer | Orden de las fases (1–4). |

**No hay campo para la línea conectora.** El componente `ula_timeline_item` tiene una prop `show_line`
(dibuja la línea vertical que une un paso con el siguiente), pero **no es un dato del contenido**: el
marco la calcula en el bucle con `show_line: not loop.last` (verdadero en todos los ítems menos el
último). Por tanto no se modela como campo — sería redundante y propenso a error.

**No hay campo de actor.** Aunque cada fase tiene actores asociados (ver §1), no se mostrarán en el
timeline de la home (el componente `ula_timeline_item` solo pinta `title` + `description`), así que no
se añade el campo. Si en el futuro se quisiera mostrar, se añadiría entonces.

---

## 3. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), con una llamada:

```
timeline_items  ← get_collection('ct_admission_journey_step',
                     { title: title (label del nodo), description: field_journey_summary })
```

El array se pasa como prop `timeline_items` al marco `lscm-master-page`, que lo pinta con
`ula_timeline_item`. La prop `show_line` la añade el bucle del marco (`not loop.last`), no la carga.
Si la carga viene vacía, el marco usa su array de fábrica (`|default`).

---

## 4. Notas sobre el contenido

El contenido (los textos de cada fase) lo define el usuario directamente en los nodos. La home
muestra un **resumen** de la cronología completa; el resultado puede no coincidir exactamente con los
elementos de la maqueta original (que era provisional) — lo relevante es que refleje las fases reales
del proceso de admisión.
