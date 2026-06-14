# Entidad — `ct_programme_feature` (Programme feature)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** v1.1.3 · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_programme_feature` modela las **características o ventajas del programa** (acreditación, cohorte
internacional, vínculos con la industria, enfoque investigador, orientación profesional, acceso a
doctorado…). Cada nodo es **una feature**.

Alimenta la colección de *features* de la sección **About** de la home (la rejilla de iconos +
título + descripción breve que resume las ventajas del máster).

Se nombró `ct_programme_feature` (no "about feature") porque estas ventajas son del **programa**, no
de una sección concreta: aunque hoy se muestran en About, conceptualmente pertenecen al máster y
podrían reutilizarse en otras secciones. Mantiene la familia `ct_programme_*` junto a
`ct_programme_facts`.

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Título de la feature ("Accredited Programme"…). → prop `title` de `ula_feature_item`. |
| `field_feature_icon` | string (16) | Emoji del icono (🎓, 🌍, 🏭…). → prop `icon`. |
| `field_feature_desc` | string_long | Descripción breve. → prop `description`. |
| `field_order` | integer | Orden de aparición. |

> **Sobre el icono:** se modela como `string` con un emoji, igual que `field_uni_flag`. Es simple y
> suficiente. Varias entidades del tema comparten este enfoque de "icono = emoji en un string"
> (features, requisitos, especializaciones, semestres); si en el futuro se migrara a iconos SVG o una
> librería de iconos, afectaría a todas a la vez.

---

## 3. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), con una llamada:

```
about_features  ← get_collection('ct_programme_feature',
                     { icon: field_feature_icon, title: title (label), description: field_feature_desc })
```

El array se pasa como prop `about_features` al marco `lscm-master-page`, que lo pinta con
`ula_feature_item`. Si la carga viene vacía, el marco usa su array de fábrica (`|default`).

---

## 4. Contenido actual (datos de la maqueta)

| order | icon | title | description |
|---|---|---|---|
| 0 | 🎓 | Accredited Programme | Verified by legal bodies in all three countries |
| 1 | 🌍 | International Cohort | Study alongside students from across Europe |
| 2 | 🏭 | Industry Links | Strong ties with logistics companies & consultancies |
| 3 | 🔬 | Research Focus | Close connection to academic research projects |
| 4 | 💼 | Career-Ready | Practical projects with real companies |
| 5 | 📄 | PhD Access | Eligible to continue to doctoral studies |
