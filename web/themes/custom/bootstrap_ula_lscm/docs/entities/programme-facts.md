# Entidad — `ct_programme_facts` (Programme Facts)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). A diferencia de
> `analysis/`, que documenta entidades heredadas tras investigarlas, `entities/` documenta el diseño
> de entidades creadas en este proyecto.
>
> **Creada en:** v1.1.1 · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_programme_facts` modela los **hechos/cifras del programa** LSCM: ECTS, número de universidades,
número de países, especializaciones, idioma, acreditación, etc. Cada hecho es **un nodo**.

**Origen del diseño.** Se detectó que el **hero** y la sección **"Why choose LSCM"** de la home
mostraban **los mismos hechos** con distinto texto (p. ej. "120 ECTS" y el "3" aparecían en ambas
secciones, redactados de forma distinta). Eran, en realidad, atributos de una misma entidad —el
programa de estudios— representados de dos formas. En lugar de duplicarlos en dos colecciones
separadas, se unifican en esta entidad única (principio "una entidad, varias representaciones", ver
`../ARCHITECTURE.md` §5.3).

**Nivel de ambición (decidido):** se centralizan los **hechos** (el valor/número y los textos de
cada sección) en la entidad, pero **no** se fuerza un texto único: cada hecho lleva el texto
específico de cada sección donde aparece (el hero usa un label corto; el why, un título + una
descripción persuasiva). Es el equilibrio entre no duplicar el dato y conservar flexibilidad
editorial por sección.

**Crecimiento previsto:** al ser cada hecho un nodo (no un campo), añadir un hecho nuevo (p. ej.
"nº de egresados", "doctores graduados") es **crear un nodo**, sin tocar estructura ni código.

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Nombre interno del hecho, para identificarlo en el admin (p. ej. "ECTS credits"). No se muestra en la home. |
| `field_fact_key` | string (64) | Identificador máquina del hecho (`ects`, `universities`, `countries`…). Requerido. |
| `field_fact_value` | string (32) | El valor que ocupa el hueco del "número". Puede ser una cifra (`120`, `3`, `2`), un símbolo (`∞`), un código (`EN`) o emojis (`🇪🇸 🇱🇻 🇩🇪`). Requerido. |
| `field_fact_hero_label` | string (128) | Etiqueta del hecho cuando aparece como **hero stat** (p. ej. "ECTS Credits"). |
| `field_fact_why_title` | string (128) | Título del hecho cuando aparece como **why item** (p. ej. "ECTS — full master's"). |
| `field_fact_why_desc` | string_long | Descripción persuasiva del hecho en la sección why. |
| `field_show_in_hero` | boolean | ¿Aparece en las hero stats? |
| `field_show_in_why` | boolean | ¿Aparece en la sección "why"? |
| `field_order` | integer | Orden de aparición. **Compartido** entre ambas secciones (mismo orden relativo en hero y why). |

---

## 3. Decisiones de diseño

### 3.1. Selección por booleanos explícitos (no por campos vacíos)
Cada hecho declara explícitamente en qué secciones aparece, mediante `field_show_in_hero` y
`field_show_in_why`. Se eligió esto frente a la alternativa de "aparece si tiene el texto relleno"
por ser **explícito y controlable**: el editor decide la aparición con una casilla, no como efecto
colateral de rellenar (o no) un texto.

### 3.2. Número de ítems dinámico
El número de hechos en cada sección **no está fijado** (antes el hero tenía 2 stats hardcodeados +
2 sueltos, y el why 6 ítems fijos). Ahora cada sección muestra **tantos hechos como nodos tengan el
booleano correspondiente activo**. Activar/desactivar un booleano cambia cuántos se ven, sin tocar
código.

### 3.3. Orden compartido
Un único `field_order` ordena el hecho en ambas secciones (mismo orden relativo). Se descartó, por
ahora, tener dos órdenes independientes (`hero_order`/`why_order`): se empezó simple, y si en la
práctica se necesita ordenar distinto cada sección, se añadiría el segundo campo entonces.

### 3.4. `countries` y `country_flags` como hechos distintos
El concepto "países" aparece en la home de dos maneras: como cifra ("3 · Countries, one degree" en el
why) y como banderas ("🇪🇸 🇱🇻 🇩🇪 · Partner Countries" en el hero). Aunque hoy ambos giran en torno al
"3", se modelan como **dos hechos distintos** (`countries` y `country_flags`):

- Son conceptos distintos (contar países ≠ mostrar las banderas) que **no comparten el mismo
  `value`** (uno es "3", otro es los emojis). Fusionarlos obligaría a un hecho con dos valores y
  lógica especial.
- Modelarlos separados mantiene el modelo uniforme (cada hecho, un `value`, sin casos especiales) y
  es más robusto si los números divergieran en el futuro.

### 3.5. El stat de banderas se unifica con el resto (sin presentación invertida)
En la maqueta original, el stat de banderas del hero tenía una **presentación especial** (orden
invertido: label "STUDY IN" arriba, banderas abajo; y tamaños propios), y estaba **hardcodeado**
aparte. Al migrarlo a un hecho (`country_flags`), se decidió (opción A) **renderizarlo como un stat
normal** (valor arriba, label debajo), aceptando un pequeño cambio visual respecto a la maqueta a
cambio de uniformidad y de eliminar el hardcodeo. Para que el label leyera bien **debajo** de las
banderas, se cambió "STUDY IN" por **"Partner Countries"** (en paralelo a "Partner Universities").

> La alternativa (mantener la presentación invertida con una variante del componente `ula_hero_stat`)
> se descartó por no complicar el componente con un caso especial. Queda como posible mejora futura
> si se quisiera recuperar ese matiz visual.

---

## 4. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), con **dos
llamadas** sobre los mismos nodos —una por representación—:

```
hero_stats  ← get_collection('ct_programme_facts',
                 { number: value, label: hero_label },
                 filtro: field_show_in_hero)

why_items   ← get_collection('ct_programme_facts',
                 { number: value, title: why_title, description: why_desc },
                 filtro: field_show_in_why)
```

Cada array se pasa como prop (`hero_stats`, `why_items`) al marco `lscm-master-page`, que los pinta
con `ula_hero_stat` y `ula_why_item` respectivamente. Si una carga viene vacía, el marco usa su array
de fábrica (`|default`).

Es el ejemplo canónico de **una entidad con dos representaciones**: los mismos nodos, dos mapeos y dos
filtros, dos secciones distintas.

---

## 5. Contenido actual (datos de la maqueta)

Hechos creados al migrar (v1.1.1), con sus booleanos:

| key | value | hero | why | hero_label / why_title |
|---|---|:---:|:---:|---|
| `ects` | 120 | ✓ | ✓ | ECTS Credits / ECTS — full master's |
| `universities` | 3 | ✓ | ✗ | Partner Universities |
| `country_flags` | 🇪🇸 🇱🇻 🇩🇪 | ✓ | ✗ | Partner Countries |
| `countries` | 3 | ✗ | ✓ | Countries, one degree |
| `specialisations` | 2 | ✓ | ✓ | Specialisations / Focused specialisations |
| `industry` | ∞ | ✗ | ✓ | Industry connections |
| `language` | EN | ✗ | ✓ | Fully in English |
| `accreditation` | 🇪🇺 | ✗ | ✓ | EU accredited |

Resultado: **hero = 4 stats** (ects, universities, country_flags, specialisations) · **why = 6 items**
(ects, countries, specialisations, industry, language, accreditation).

---

## 6. Posibles usos futuros

Al ser una entidad de "hechos del programa", puede alimentar otras secciones del sitio que muestren
cifras del máster (About, materiales promocionales, etc.) añadiendo, si hiciera falta, nuevos campos
de representación (p. ej. `field_fact_about_label`) y nuevas llamadas al cargador genérico con su
mapeo. El patrón es extensible sin reestructurar la entidad.
