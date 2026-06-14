# Elemento: Home

> Documentación del elemento **home** del tema `bootstrap_ula_lscm`.
> Para la arquitectura global del tema (design system `ula_*`, sistema de CSS en capas, notas
> técnicas y restricciones del entorno, versionado), ver [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md).

---

## 1. Qué es la home

La home del sitio es una *landing page* del máster LSCM: un escaparate que presenta el programa
por secciones e **invita a entrar** a las páginas de detalle del sitio. Su contenido es
mayoritariamente estático, con ajustes ocasionales.

Se construye íntegramente con el **design system propio** del tema (componentes `ula_*`, tokens
y base CSS — ver [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §3 y §4), sin depender de
frameworks externos ni de las clases/CSS de ningún tema base.

Características clave de la implementación:

- **Diseño autónomo**, fiel a una maqueta original, independiente de frameworks externos (no usa
  sus clases ni su CSS).
- Construida componiendo los **componentes SDC** `ula_*` del design system del tema.
- Un **componente-marco** (`lscm-master-page`) que ensambla todo.
- Servida como un **nodo** (tipo `landing`) con plantillas de tema dedicadas.
- **Textos editables** desde el admin (campos del nodo); colecciones de ítems pendientes de
  migrar a editables (ver §5).

---

## 2. El marco `lscm-master-page`

Ubicación: `components/lscm-master-page/`. Es el componente que **ensambla la landing completa**.

- **`.twig`**: define al inicio (a) los **valores por defecto de fábrica** de todas las props de
  texto (con `|default()`), y (b) las **colecciones** como arrays fijos (universidades,
  semestres, etc. — ver §5). Luego ensambla nav + hero + about + journey + universities +
  specializations + why + admission + "Get in touch" + footer, componiendo los 8 `ula_*` con
  `include()`.
- **`.component.yml`**: ~44 props de texto editables (logo, marca, textos por sección, botones de
  salto, contacto). Las props de **descripción** llevan `maxLength: 1000`.
- **`.css`**: solo CSS estructural (nav, hero, fondos de sección, grids contenedores, conectores
  del journey, footer, CTA, responsive). No duplica base ni componentes.
- **`.js`**: animaciones scroll-reveal + sombra del nav.

### Decisiones del marco

- **[DECISIÓN] `libraryOverrides` con dependencia de `ula_landing_base`.** El marco declara en su
  `.component.yml` que depende de `bootstrap_ula_lscm/ula_landing_base` y `core/drupal`, para que
  esa librería base se cargue **solo** cuando se renderiza la landing (no en todo el sitio,
  evitando colisiones de clases genéricas).
- **[DECISIÓN] Valores por defecto "de fábrica" en el `.twig` del componente** (con `|default()`).
  Motivo: SDC **no inyecta de forma fiable** los `default` del `.component.yml` al renderizar vía
  `include()` con props parciales (ver [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §6.4).
  Estos defaults son el contenido "out of the box"; el contenido editable (campos del nodo) los
  sobreescribe. **No es hardcodear contenido:** es el estado de fábrica del componente.
- **[DECISIÓN] Menú del header = anclas internas** (`#about`, `#journey`…) para navegar dentro de
  la landing. **Botones de salto por sección** = enlaces a las páginas de detalle del sitio
  (`/about`, `/programme`…), con texto y URL editables. (Opción "C": ambas cosas.)
- **[DECISIÓN] Logo del máster** como prop `logo_url` (editable), con default
  `/sites/default/files/2026-06/logo-MASTER-LSCM.png`. Sustituye al SVG de estrellas de la
  maqueta. Su tamaño se controla con `.nav-logo-img { height: 38px }`.
- **[DECISIÓN] Sección "Get in touch"** (CTA final con email y FAQ) incluida; sus textos/URLs son
  props editables.

> El componente `ula_journey_connector` se descartó como componente (es decoración del layout del
> journey); la decisión y su justificación están a nivel de design system en
> [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §3.

> El menú hamburguesa (móvil) y las pastillas interactivas de `ula_uni_card` son iteraciones
> posteriores; ver los pendientes en §5.

---

## 3. Cómo se sirve la home

La home es un **nodo** del tipo de contenido `landing`, servido con plantillas dedicadas del tema.

- **Tipo de contenido `landing`**: contiene los campos editables de los textos (ver §4). El nodo
  actual de la home es **`/node/55`** ("Home Master LSCM").
- **Front page**: configurada en `admin/config/system/site-information` apuntando a `/node/55`.
- **`templates/layout/page--front.html.twig`**: plantilla de **portada**. Sobreescribe la del
  tema base y renderiza **solo** el contenido (sin header/footer/rows del tema base), para que la
  landing — que trae su propia nav y footer — ocupe la página entera sin conflictos.
- **`templates/content/node--landing.html.twig`**: renderiza el nodo `landing` con el componente
  `lscm-master-page`, **mapeando cada campo del nodo a su prop**. Si un campo está vacío, no se
  pasa y el componente usa su default de fábrica.

> **[DECISIÓN] Camino elegido:** nodo + plantilla Twig (mapeo campo→prop en código), **no** Layout
> Builder ni UI Patterns Blocks. Motivo: UI Patterns 2.x no ofrece "renderizar entidad completa
> con componente" salvo vía Layout Builder (capa pesada, config en BD). La plantilla Twig es más
> ligera, va a git, y no mete config crítica en una BD sin gestión de configuración (ver
> [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §6.1).

---

## 4. EDICIÓN DE CONTENIDO — guía para quien mantiene el sitio

> **Esta es la sección más importante para el mantenimiento diario de la home.**

El contenido de la home se divide en dos familias que se editan en **sitios distintos**:

### Familia A — Textos simples → editables en el ADMIN (sin tocar código)

**Dónde:** editando el nodo de la home → `/node/55/edit` (o Content → "Home Master LSCM" → Edit).

**Qué incluye:** logo (URL), marca, y por cada sección: tag, título, descripción, y textos+URLs
de los botones de salto; además email y FAQ de contacto.

**Cómo funciona:**
- Campo **con valor** → se muestra ese valor.
- Campo **vacío** → se muestra el **texto por defecto de fábrica** (el de la maqueta).

Es decir, **solo hace falta rellenar los campos que se quieran cambiar** respecto a la maqueta.
Los vacíos muestran el contenido por defecto. No hay que rellenarlos todos.

### Familia B — Colecciones de ítems → HOY en código (ver §5, en migración a editable)

**Qué incluye:** las tarjetas de universidades, especializaciones, semestres del journey,
why-items, pasos de la timeline de admisión, requisitos, features del about y stats del hero.

**Dónde (estado actual, provisional):** definidas como arrays al inicio de
`components/lscm-master-page/lscm-master-page.twig` (bloques `{% set universities = [...] %}`,
etc.). Cambiarlas requiere editar ese fichero (código → git → `ddev drush cr`).

> **IMPORTANTE:** este estado es **provisional**. La §5.1 describe el plan para hacer estas
> colecciones editables desde el admin leyendo los nodos y pasándolos como prop al marco
> (mecanismo **preprocess → prop**, ver ADR-002 en §7).

---

## 5. Pendientes de la home

Pendientes específicos de la home. (Los pendientes transversales del tema están en `TODO.md` en
la raíz del tema.)

### 5.1. Colecciones editables (preprocess → prop) — EN CURSO

**Estado:** las 8 colecciones están hoy como datos fijos en el `.twig` del marco (decisión
**provisional** para desbloquear la home). Plan acordado: hacerlas **editables desde el admin**
leyendo los nodos y pasándolos como prop al marco. El mecanismo elegido es **preprocess → prop**, no
vistas; la justificación, las alternativas descartadas (vista embebida, sección fuera del marco) y la
tabla comparativa están en la **ADR-002** (§7).

**Mecanismo por colección:**
1. Un **tipo de contenido** con los campos del ítem (editable en el admin). Para universidades se
   reutiliza el existente `ct_about_consortium_university`, ampliado con campos nuevos (ver
   [`../../analysis/about-and-university-entity.md`](../../analysis/about-and-university-entity.md)).
2. **Nodos** (el contenido editable).
3. Una **preprocess** del tema lee esos nodos (ordenados) y construye el array de la colección.
4. El array se pasa como **prop** al marco `lscm-master-page`, que lo pinta con el componente `ula_*`
   correspondiente y su grid propio — igual que hoy, pero con datos de nodos en vez de hardcodeados.

**Colecciones — estado de migración:**

- ✅ **universidades** (`ula_uni_card`) — migrada en v1.1.0. Entidad: `ct_about_consortium_university`
  (ver [`../../analysis/about-and-university-entity.md`](../../analysis/about-and-university-entity.md)).
- ✅ **stats del hero** (`ula_hero_stat`) — migrada en v1.1.1. Entidad: `ct_programme_facts`.
- ✅ **why-items** (`ula_why_item`) — migrada en v1.1.1. Entidad: `ct_programme_facts`
  (ver [`../../entities/programme-facts.md`](../../entities/programme-facts.md)).
- ✅ **timeline** (`ula_timeline_item`) — migrada en v1.1.2. Entidad: `ct_admission_journey_step`
  (ver [`../../entities/admission-journey-step.md`](../../entities/admission-journey-step.md)).
- ✅ **features** (`ula_feature_item`) — migrada en v1.1.3. Entidad: `ct_programme_feature`
  (ver [`../../entities/programme-feature.md`](../../entities/programme-feature.md)).
- ✅ **requisitos** (`ula_req_card`) — migrada en v1.1.4. Entidad: `ct_admission_requirement`
  (ver [`../../entities/admission-requirement.md`](../../entities/admission-requirement.md)).
- ✅ **especializaciones** (`ula_spec_card`) — migrada en v1.1.5. Entidad: `ct_programme_specialisation`
  (rich text + imagen de Media; rediseño del componente). Ver
  [`../../entities/programme-specialisation.md`](../../entities/programme-specialisation.md). El
  antiguo `modules[]` se redacta ahora dentro de la descripción enriquecida.
- ⬜ **semestres** (`ula_sem_card`) — pendiente. Última colección; tiene un array anidado
  (`subjects[]`) que decidir cómo modelar.

**Método:** se validó el patrón con un piloto (**universidades**, v1.1.0); con la segunda y tercera
colección (hero stats y why items, ambas vía `ct_programme_facts`, v1.1.1) se extrajo el **cargador
genérico** `_bootstrap_ula_lscm_get_collection()` (regla de tres, ver ADR-002). Las restantes
reutilizan ese genérico. Decidir, por colección, si el contenido tendrá página de detalle propia.


### 5.2. Menú hamburguesa (móvil)

La maqueta oculta los enlaces de navegación en móvil sin sustituirlos. Pendiente: añadir un menú
hamburguesa que use el **menú principal de Drupal** (entradas reales del sitio) con un **toggle
propio mínimo** (sin frameworks externos, sofisticable más adelante). Es funcionalidad nueva, no
presente en la maqueta.

### 5.3. Pastillas interactivas de `ula_uni_card`

Las pastillas (`tags`) de las tarjetas de universidad están preparadas como `{label, info}` pero
hoy se renderizan estáticas (solo `label`). Pendiente: convertirlas en botones que abran un
popover/modal con el contenido de `info`, usando la **API nativa** del navegador
(`popover` / `<dialog>`), sin frameworks externos.

> **Dependencia de modelado.** El contenido de estas pastillas (qué semestres y el texto de su
> modal) depende de una **relación universidad↔semestre** que aún no está modelada: el texto del
> modal depende de la combinación universidad × semestre. Su diseño previsto (entidad "semestre" +
> entidad de relación con el texto del modal) está documentado en
> [`../../analysis/about-and-university-entity.md`](../../analysis/about-and-university-entity.md)
> §3.4. Por eso, en el piloto de colecciones editables (§5.1) las tarjetas de universidad se
> construyen **sin** pastillas; estas se completarán cuando se modele la relación. El componente
> `ula_uni_card` ya soporta `tags: {label, info}`, así que no requiere cambios.


### 5.4. Limpieza: eliminar la vista vieja `page_home`

Al cambiar la front page al nodo `landing` (`/node/55`), la vista `page_home` (antigua home, ruta
`/home2`) quedó **huérfana**. Pendiente eliminarla cuando se confirme que no se necesita.
(Reversible mientras exista; el dump previo la conserva.)

---

## 6. Ficheros del elemento home

```
components/lscm-master-page/        # El marco (ensambla la home)
├── lscm-master-page.component.yml  # ~44 props de texto editables
├── lscm-master-page.twig           # Defaults de fábrica + colecciones + ensamblaje
├── lscm-master-page.css            # CSS estructural
└── lscm-master-page.js             # Animaciones reveal + sombra del nav

templates/
├── layout/
│   └── page--front.html.twig       # Portada a pantalla completa (sin chrome del tema base)
└── content/
    └── node--landing.html.twig     # Mapea campos del nodo → props del marco
```

> Los scripts que crearon el tipo de contenido `landing` y sus 42 campos están en `scripts/`
> (raíz del proyecto), conservados como referencia reproducible (la configuración no está en git,
> ver [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §6.1):
> `crear-campos-landing.php`, `anadir-campos-formdisplay.php`, `ordenar-campos-landing.php`.

---

## 7. Registros de decisiones de arquitectura (ADRs)

> Esta sección recoge decisiones de arquitectura significativas de la home, en formato ADR
> (Architecture Decision Record), de forma **autocontenida** para poder extraerla en el futuro a
> `docs/decisions/` sin reescribirla. Cada ADR registra el contexto, la decisión, las alternativas
> consideradas y las consecuencias, para poder reconsiderarla con conocimiento de causa más adelante.

---

### ADR-001 — La home se sirve como nodo + plantilla Twig (no Layout Builder ni UI Patterns Blocks)

**Estado:** aceptada · **Fecha:** 2026-06 · **Ámbito:** home

**Contexto.** La home debía renderizarse con el componente-marco `lscm-master-page`, con sus textos
editables desde el admin, sin hardcodear contenido. Se buscaba el mecanismo de Drupal/UI Patterns
para "renderizar una entidad (nodo) completa con un componente, mapeando campos a props".

**Decisión.** Servir la home como un **nodo** del tipo `landing`, con una **plantilla Twig**
(`node--landing.html.twig`) que mapea los campos del nodo a las props del marco, más una plantilla
de portada (`page--front.html.twig`) que la sirve a pantalla completa sin el chrome del tema base.

**Alternativas consideradas y descartadas:**

- **Layout Builder.** Permite asignar un componente como layout de la entidad, pero: (a) es una capa
  pesada; (b) su configuración se guarda en la BD, y este sitio **no usa config/sync** (ver
  [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §6.1), por lo que esa config crítica no se
  versionaría; (c) su modelo de "componer un layout arrastrando bloques" no encaja con una landing
  que **ya trae su propio layout** en el componente. Al activarlo, la pantalla "editar el layout de
  todos los Landing" evidenció el choque conceptual: no queremos *componer* un layout, sino *delegar*
  en un componente que ya lo trae.
- **UI Patterns Blocks (`ui_patterns_blocks`).** Permite usar un componente como bloque colocable,
  pero los textos se editarían en la configuración del bloque (en BD), no como contenido; y UI
  Patterns 2.x **no ofrece** "renderizar la entidad completa con un componente" salvo vía Layout
  Builder. Se exploró y se descartó.

**Consecuencias.**
- (+) Mecanismo **ligero**, en **código** (va a git), sin meter configuración crítica en una BD sin
  config/sync. Bajo control total en el tema.
- (+) El mapeo campo→prop es explícito y versionado en `node--landing.html.twig`.
- (−) El mapeo se escribe en código (no por interfaz); ampliar campos implica editar el Twig.
- Nota: SDC no inyecta de forma fiable los `default` del `.component.yml` vía `include()` con props
  parciales; por eso los valores de fábrica se definen en el `.twig` del marco con `|default()`
  (ver [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §6.4).

---

### ADR-002 — Las colecciones de la home se alimentan por preprocess→prop (no por vistas)

**Estado:** aceptada · **Fecha:** 2026-06 · **Ámbito:** home (aplica a las 8 colecciones)

**Contexto.** Las 8 colecciones de la home (universidades, especializaciones, semestres, why-items,
timeline, requisitos, features, stats) están hoy como **arrays fijos** dentro del componente
monolítico `lscm-master-page`, cada una embebida en una `<section>` con su propio grid CSS
(`.uni-grid`, `.spec-grid`, etc.). Se quería hacerlas **editables desde el admin** sin perder
fidelidad visual ni independencia de Bootstrap. El nudo: la colección **no es una página autónoma**,
sino una sección embebida dentro de un componente que pinta toda la landing de una pieza.

El sitio, en general, usa el patrón **tipos de contenido + vistas** (ver
[`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §5; p. ej. About lista las universidades con una
vista `ui_patterns_views`). La pregunta era si replicar ese patrón en la home.

**Decisión.** Para la home, **cargar los nodos en una *preprocess* del tema y pasarlos como prop** al
marco `lscm-master-page` (que sigue pintando cada colección con su grid propio y sus componentes
`ula_*`). Los **datos siguen viviendo en los nodos** (editables en el admin, p. ej. el tipo
`ct_about_consortium_university`); lo único que cambia respecto al estado actual es que el array deja
de estar hardcodeado y se construye leyendo los nodos. Esta decisión aplica a **las 8 colecciones**,
no solo a universidades.

**Flujo de datos (mecanismo elegido):**

```
NODOS (datos editables)
   ↓   ← la Opción 3 decidió: una PREPROCESS lee los nodos (en vez de una vista)
array de datos
   ↓   ← se pasa como PROP al marco
lscm-master-page (el marco)
   ↓   ← el marco itera el array y, por cada ítem, llama a:
ula_uni_card   ← PINTA cada tarjeta   ◄── el componente de presentación, imprescindible
```

Solo cambia el **primer eslabón** (cómo se leen los datos: preprocess en vez de array hardcodeado o
vista). El **componente** (`ula_uni_card` y, para las demás colecciones, su `ula_*` correspondiente)
y el **marco** mantienen su papel: el marco orquesta e itera; el componente pinta cada ítem. La
*preprocess* se ocupa de los **datos**; el *componente* se ocupa de la **presentación** — separación
que permite cambiar la fuente de datos sin tocar el componente, y viceversa.

**Alternativas consideradas:**

1. **Vista embebida en el marco** (`drupal_view()` donde hoy está el array). Es el patrón de About.
2. **Sacar la sección fuera del marco** y mostrarla como vista independiente.
3. **Preprocess → prop** (la elegida).

**Tabla comparativa:**

| Criterio | Op.1 Vista embebida | Op.2 Sección fuera del marco | Op.3 Preprocess→prop (elegida) |
|---|---|---|---|
| Independencia de Bootstrap | Media (wrappers de Views se interponen) | Media | **Total** (markup idéntico al actual) |
| Mantenibilidad | Media-baja (acopla el SDC a una vista; config en BD) | Baja (rompe la unidad del marco) | Media-alta (marco intacto; carga de datos en el tema) |
| Editabilidad del contenido | Excelente | Excelente | Excelente |
| Fidelidad visual | Riesgo (wrappers rompen el `display:grid`) | Riesgo alto | **Garantizada** (mismo Twig) |
| Coherencia con el resto del sitio | Alta (patrón de About) | Media | Baja (mecanismo propio de la home) |
| Todo en git | No (config de vista en BD) | No (config en BD) | **Sí** (todo en código) |
| Escala a las 8 colecciones | 8 vistas en BD | romper el marco 8 veces | 1 preprocess uniforme |

**Razón de la elección.** La tensión de fondo es que **no se puede optimizar a la vez "todo en git"
y "coherencia con el patrón de vistas"**: las vistas son configuración y viven en la BD, que este
sitio no versiona. La home ya tomó conscientemente (ADR-001) el camino "todo en código, nada de
config pesada en BD". La Opción 3 es coherente con esa identidad: fidelidad garantizada (mismo
markup), independencia total (sin wrappers de Views ni rejillas Bootstrap), y todo versionado en
git. Además **escala mejor**: las 8 colecciones se resuelven con un patrón uniforme en código (una
preprocess), en vez de 8 vistas que vivirían en la BD.

**Consecuencias.**
- (+) Fidelidad visual garantizada: el marco pinta igual que hoy; solo cambia el origen de los datos.
- (+) Independencia total de Bootstrap; sin wrappers de Views.
- (+) Todo en git: la home es reconstruible desde el repo (salvo el contenido, que son los nodos).
- (+) Patrón uniforme y de bajo coste para las 8 colecciones.
- (−) **Diverge del patrón de vistas** del resto del sitio (la home es una excepción justificada por
  su naturaleza monolítica y pixel-perfect; no es incoherencia, es adecuación).
- (−) Requiere una *preprocess* en PHP (un hook en un `.theme`) o equivalente: introduce una pizca de
  lógica de datos en el tema.
- (−) El **mapeo y el orden** de las colecciones viven en código (no configurables por interfaz). El
  **contenido** (los nodos) sí es editable desde el admin. Si en el futuro se necesitara configurar
  la *presentación* (orden, filtros) desde la interfaz, habría que reconsiderar hacia vistas (Op.1).

**Reconsideración.** Si cambiara la prioridad —p. ej. que un editor no técnico deba configurar la
presentación de las colecciones desde la interfaz, o que se quiera homogeneizar con el patrón de
vistas del resto del sitio aceptando config en BD— esta decisión debería revisarse hacia la Opción 1.

**Estrategia de implementación (regla de tres).** Las 8 colecciones comparten el mismo patrón
(leer nodos de un tipo → mapear campos a un array → pasarlo como prop), pero **no son idénticas**
(universidades tiene `tags`/relación pendiente; especializaciones tiene `modules[]`; semestres tiene
`subjects[]` y variantes; etc.). Para no caer en sobre-ingeniería prematura (generalizar con un solo
caso, imaginando los otros siete) ni en copy-paste (8 bloques de carga casi iguales), la
implementación sigue la **regla de tres**:

1. **Piloto (universidades) — HECHO (v1.1.0).** La carga se escribió en una **función propia y
   separada** del `.theme` (`_bootstrap_ula_lscm_get_universities()`), invocada desde la preprocess —
   limpia, pero **sin generalizar todavía**. Validó el patrón con un caso real.
2. **Segunda colección (hero stats + why items, vía `ct_programme_facts`) — HECHO (v1.1.1).** Con
   **dos casos reales** delante, se extrajo la parte común a la **función genérica**
   `_bootstrap_ula_lscm_get_collection(string $bundle, array $map, ?string $bool_filter)`:
   - `$bundle`: el tipo de contenido a leer.
   - `$map`: mapa `clave_de_salida => callback($node)`, que resuelve cada clave del array de salida
     a partir del nodo (permite mapeos arbitrarios: un campo, el `label()`, un valor fijo…).
   - `$bool_filter`: campo booleano opcional para filtrar (p. ej. `field_show_in_hero`).

   `_bootstrap_ula_lscm_get_universities()` se reescribió para usar el genérico (el caso 1 quedó
   también sobre la infraestructura común). `ct_programme_facts` aportó además el caso de **una
   entidad con dos representaciones**: los mismos nodos alimentan el hero (mapeo `number`/`label`,
   filtro `field_show_in_hero`) y la sección why (mapeo `number`/`title`/`description`, filtro
   `field_show_in_why`) — dos llamadas al genérico con distinto mapa y filtro.
3. **Colecciones restantes — en curso.** Triviales: una llamada al genérico con su `$bundle`,
   `$map` y, si aplica, `$bool_filter`. El genérico queda como **infraestructura del tema**,
   reutilizable también fuera de la home. Migradas así: why items, hero stats, timeline, features,
   requisitos y especializaciones.

   El mapa `$map` admite **resolvers arbitrarios** (callbacks), lo que permitió cubrir campos que no
   son texto plano sin tocar el genérico. Para las especializaciones (v1.1.5) se añadieron dos
   funciones auxiliares **reutilizables** usadas como resolvers:
   - `_bootstrap_ula_lscm_text_value($node, $field)` — renderiza un campo **rich text** (aplica
     `check_markup`, devuelve HTML saneado para imprimir con `|raw`).
   - `_bootstrap_ula_lscm_media_image_url($node, $field)` — resuelve la **URL** de una imagen
     referenciada de la biblioteca de **Media** (campo → media → archivo → URL).

   Demuestra que el diseño del genérico (mapa de callbacks) escala a tipos de campo nuevos sin
   reescribirlo: basta añadir un resolver.

El refactor de extraer el genérico (paso 2) se hizo con dos casos reales en la mano, como estaba
previsto: bajo riesgo y con conocimiento real en lugar de adivinando.
