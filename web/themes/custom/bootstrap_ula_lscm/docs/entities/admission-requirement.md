# Entidad — `ct_admission_requirement` (Admission requirement)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** v1.1.4 · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_admission_requirement` modela los **requisitos de admisión** del máster (formación previa, nivel
de inglés, documentación, apertura a estudiantes EU/no-EU…). Cada nodo es **un requisito**.

Alimenta la sección de **requisitos** de la home (la rejilla de tarjetas con icono + título +
descripción).

**Por qué una entidad nueva y no reutilizar las de Eligibility.** El sitio tiene una página
*Eligibility* con entidades propias (`ct_elegibility_criteria`, `ct_elegibility_precondition`,
`ct_elegibility_rank`) que describen el **detalle normativo** de la elegibilidad. Pero, igual que
ocurrió con la timeline (ver `admission-journey-step.md`), esas entidades cumplen un **propósito
distinto**: en la home se quiere un **resumen visual** de 4 requisitos clave, no el detalle normativo
completo. Reutilizarlas acoplaría la home a un modelo (Eligibility) que cumple otra función y que
probablemente se rehaga en una fase posterior. Por eso la home tiene su **propia entidad de resumen,
independiente**.

> **Relación futura.** Al rehacer la sección Eligibility, se decidirá si este resumen de la home se
> mantiene independiente o se vincula con el detalle. De momento, **independiente**.

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Título del requisito ("Academic Background", "English Proficiency"…). → prop `title` de `ula_req_card`. |
| `field_req_icon` | string (16) | Emoji del icono (🎓, 🌐, 📋, 🌍). → prop `icon`. |
| `field_req_desc` | string_long | Descripción del requisito. → prop `description`. |
| `field_order` | integer | Orden de aparición. |

> **Sobre el icono:** emoji en un `string`, como en `ct_programme_feature` y otras entidades del tema
> (ver nota compartida en `programme-feature.md` §2).

---

## 3. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), con una llamada:

```
requirements_cards  ← get_collection('ct_admission_requirement',
                         { icon: field_req_icon, title: title (label), description: field_req_desc })
```

El array se pasa como prop `requirements_cards` al marco `lscm-master-page`, que lo pinta con
`ula_req_card`. Si la carga viene vacía, el marco usa su array de fábrica (`|default`).

---

## 4. Contenido actual (datos de la maqueta)

| order | icon | title | description |
|---|---|---|---|
| 0 | 🎓 | Academic Background | Bachelor's degree in engineering, technology, business, or a related field from a recognised institution. |
| 1 | 🌐 | English Proficiency | TOEFL 90+ (internet-based) or equivalent B2 level according to the CEFR framework. |
| 2 | 📋 | Documents | CV, motivation letter, academic transcripts, degree certificate, and language certificate. |
| 3 | 🌍 | Open to EU & non-EU | International students outside the EU are supported through UAB's International Support Service for visa applications. |
