# Bootstrap ULA LSCM — Arquitectura del tema

> Tema Drupal 11 para el **máster europeo conjunto LSCM** (Logistics & Supply Chain Management).
> Repositorio: https://github.com/ula-uab/lscm-drupal-theme (rama `main`).
> Machine name: `bootstrap_ula_lscm`.

Este documento describe la **arquitectura global del tema**: su design system, sus
convenciones y las restricciones del entorno. La documentación de cada elemento concreto del
tema (p.ej. la home) vive en `docs/elements/<elemento>/` y referencia a este documento para
todo lo que es común a varios elementos.

---

## Índice

- [1. Control de versiones del tema](#1-control-de-versiones-del-tema)
- [2. Identidad y estado de independencia](#2-identidad-y-estado-de-independencia)
- [3. Design system: componentes SDC `ula_*`](#3-design-system-componentes-sdc-ula_)
- [4. Sistema de CSS en tres capas](#4-sistema-de-css-en-tres-capas)
- [5. Patrón de contenido editable: tipos de contenido + vistas + componentes](#5-patrón-de-contenido-editable-tipos-de-contenido--vistas--componentes)
  - [5.1. Los tres conceptos de Drupal implicados](#51-los-tres-conceptos-de-drupal-implicados)
  - [5.2. La pieza que conecta vista y componente: `ui_patterns_views`](#52-la-pieza-que-conecta-vista-y-componente-ui_patterns_views)
  - [5.3. Una misma entidad, varias representaciones](#53-una-misma-entidad-varias-representaciones)
  - [5.4. Resumen del patrón](#54-resumen-del-patrón)
  - [5.5. Implementación en Views: el patrón de dos niveles](#55-implementación-en-views-el-patrón-de-dos-niveles)
  - [5.6. Entidades de relación (cruces entre dos entidades)](#56-entidades-de-relación-cruces-entre-dos-entidades)
- [6. Notas técnicas y restricciones del entorno](#6-notas-técnicas-y-restricciones-del-entorno)
- [7. Pendientes transversales del tema](#7-pendientes-transversales-del-tema)
- [8. Estructura de ficheros del tema](#8-estructura-de-ficheros-del-tema)

> Cómo se compone el **contenido** de las páginas no-home (Layout Builder) y el modelo de página se
> documentan en el elemento layout: `docs/elements/layout/CONTENT-LAYOUT.md` (con ADR-LAYOUT-004). El
> **marco compartido** (header/footer/`page.html.twig`), en `docs/elements/layout/SHARED-FRAME-LAYOUT.md`.

---

## 1. Control de versiones del tema

El tema `bootstrap_ula_lscm` usa **versionado semántico propio** (`MAYOR.MENOR.PARCHE`),
declarado en `bootstrap_ula_lscm.info.yml`:

- **MAYOR**: cambios grandes de arquitectura (p.ej. completar la independencia del tema base → `2.0.0`).
- **MENOR**: nuevas funcionalidades o nuevos elementos del tema (p.ej. una nueva sección). Una misma funcionalidad aplicada de forma incremental puede agruparse bajo un MENOR y sus refinamientos como PARCHE (p.ej. las 8 colecciones editables de la home: el mecanismo entró en `1.1.0` con el piloto de universidades, y las colecciones siguientes son refinamientos `1.1.x`).
- **PARCHE**: correcciones y ajustes menores.

**Cualquier cambio en cualquier elemento del tema** (la home u otros que se desarrollen) se
registra aquí, subiendo la versión del tema según el criterio de arriba. Esta es la **única
tabla de versionado** del proyecto; los documentos de elemento no llevan versionado propio,
sino que referencian la versión del tema en la que se introdujo o modificó cada cosa.

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-11 | Primera versión con identidad y versionado propios. Design system `ula_*` (8 componentes + tokens + base CSS en tres capas). Elemento **home**: marco `lscm-master-page`, servido como nodo `landing` con plantillas dedicadas (`page--front`, `node--landing`) y textos editables desde el admin. Documentación reorganizada en dos niveles (tema / elementos). |
| 1.1.0 | 2026-06-13 | Home: **colecciones editables** (mecanismo preprocess → prop, ADR-002). Piloto **universidades**: el tipo `ct_about_consortium_university` se amplía con campos para la tarjeta de la home y se alimenta la sección vía preprocess que lee los nodos. Las siguientes colecciones de la home, al usar el mismo mecanismo, se versionarán como refinamientos (`1.1.x`). |
| 1.1.1 | 2026-06-14 | Home: 2ª y 3ª colecciones editables — **hero stats** y **why items**, ambas alimentadas por una entidad nueva **`ct_programme_facts`** (hechos del programa; una entidad, dos representaciones). Se extrae el **cargador genérico** `_bootstrap_ula_lscm_get_collection()` (regla de tres). Se eliminan los stats hardcodeados del hero. |
| 1.1.2 | 2026-06-14 | Home: 4ª colección editable — **timeline** del proceso de admisión, alimentada por la entidad nueva **`ct_admission_journey_step`** (una fase por nodo; resumen, distinto del detalle de la sección Admission). Sin numeración en los títulos. |
| 1.1.3 | 2026-06-14 | Home: 5ª colección editable — **features** del programa (sección About), alimentada por la entidad nueva **`ct_programme_feature`** (icono emoji + título + descripción). |
| 1.1.4 | 2026-06-14 | Home: 6ª colección editable — **requisitos** de admisión, alimentada por la entidad nueva **`ct_admission_requirement`** (resumen visual; distinto del detalle de la sección Eligibility). |
| 1.1.5 | 2026-06-14 | Home: 7ª colección editable — **especializaciones**, entidad nueva **`ct_programme_specialisation`** con descripción **rich text** (Basic HTML) e **imagen de Media**. Se **rediseña el componente `ula_spec_card`** (cabecera con imagen + overlay). Se añaden auxiliares reutilizables en el tema: render de rich text y resolución de URL de imagen de Media. |
| 1.1.6 | 2026-06-15 | Home: 8ª y última colección editable — **semestres** del journey, entidad nueva **`ct_programme_semester`** (rich text + **logos multivalor** de Media, 1-2). Se **rediseña `ula_sem_card`** (logos normalizados en vez de icono; cajas de igual altura vía `align-items: stretch`). Auxiliar nuevo: resolución de URLs de imágenes de Media multivalor. **Las 8 colecciones de la home quedan editables.** Doc extra: análisis de la entidad preexistente `ct_contents_subject`. |
| 1.2.0 | 2026-06-15 | Home: **interactividad** — menú **hamburguesa** en el header (Fase 3 del plan). Despliega un menú de Drupal propio **`home_header`** (editable en el admin), con acceso directo a las páginas del sitio; convive con las anclas internas. Toggle con **API nativa** (accesible). Incremento MENOR: funcionalidad nueva. Ver ADR-003. |
| 1.3.0 | 2026-06-15 | Home: **relación universidad↔semestre** (Fase 4, Sub-hito 4a). Entidad de relación nueva **`ct_university_semester`** (universidad × semestre + texto de modal) + campos de **Lead Partner** en la universidad. Las **pastillas** de `ula_uni_card` se alimentan de datos reales (estáticas; el modal es 4b). Mecanismo de entidad de relación en §5.6; ver ADR-004. |
| 1.3.1 | 2026-06-15 | Home: **interactividad de las pastillas** (Fase 4, Sub-hito 4b). Las pastillas con contenido se vuelven botones que abren un **modal** (`<dialog>` nativo único, accesible) con el texto del cruce universidad×semestre / Lead Partner. **Fase 4 completa.** Ver ADR-004. |
| 1.3.2 | 2026-06-15 | Cierre del **plan de colecciones editables e interactividad** (Fase 5). Documentación: §4 de HOME-ARCHITECTURE reescrita como **guía de edición** (textos por sección, colecciones, menú, pastillas); §5.x marcados resueltos; plan archivado; Fase 0 (`page_home`) reconvertida en TO-DO transversal. Solo documentación. |
| 1.4.0 | 2026-06-15 | **Marco compartido de páginas de contenido** (Fase 1 del plan de páginas de contenido). Header (`lscm_page_header`) y footer provisional (`lscm_page_footer`) propios, independientes de BI, con estética de la home; navegación de sitio desde el menú `main`. Plantilla `page--about.html.twig` que monta el marco solo para `/about` (Opción B, página a página), sin tocar las páginas heredadas. Nuevo elemento documentado en `docs/elements/layout/` (ADR-LAYOUT-001 y -002). |
| 1.5.0 | 2026-06-17 | **`page.html.twig` propio** (Fase 2 del plan de independencia de BI). Marco genérico propio para todas las páginas no-home: sustituye al `page.html.twig` heredado de Bootstrap Italia. Header/footer propios (`lscm_page_*`), regiones funcionales activas (breadcrumb, title, local_tasks, help, notification) y rejilla propia para contenido + sidebars (librería `lscm_page`, `css/lscm-page.css`), sin clases `container/row/col/it-*` de BI. El marco se aplica a todas las páginas no-home (Camino 1); su contenido interno sigue heredado hasta migrarse. ADR-LAYOUT-003. |
| 1.5.1 | 2026-06-18 | **Documentación: adopción de Layout Builder** como mecanismo de composición del contenido de las páginas no-home. Validado el flujo Views → UI Patterns (la vista pinta entidades con tarjetas) dentro de una página compuesta con LB, mediante prueba piloto multi-sección en `/about-lb`. Nuevo elemento documental `elements/layout/CONTENT-LAYOUT.md` (con ADR-LAYOUT-004) y renombrado del documento del marco a `SHARED-FRAME-LAYOUT.md` (antes `LAYOUT-ARCHITECTURE.md`). Se matizan §5.2 y §6.1 (el descarte de LB era específico de la home) y se amplía §5.5 con las lecciones del flujo (`view_field` vs `entity_field`, formatter de imagen en el campo, variante del componente). Solo documentación; la migración de las páginas a clave propia es trabajo posterior. |
| 1.6.0 | 2026-06-19 | **Hero de página** (componente `ula_hero` + tipo de contenido `hero`). Nuevo componente SDC `ula_hero` (autónomo, por slots; dos presentaciones vía prop `size` *page*/*home*), que reutiliza `ula_hero_stat` por composición para las estadísticas mediante la plantilla `paragraph--hero-stat.html.twig`. Se alimenta de una **vista filtrada por taxonomía** (`page_id`) que inyecta los campos del tipo de contenido `hero` en sus slots, insertada en el Layout Builder de la página (patrón de instancia única, `elements/layout/CONTENT-LAYOUT.md` §5.7). Header de páginas (`lscm_page_header`): logo +50% y marca alineada con la home. `preprocess_page` oculta título **y** breadcrumb en las páginas de contenido (LB). También se construyeron antes `ula_card_simple` y `ula_grid_row` (catálogo en `COMPONENTS.md`). Documentación: `entities/hero.md`, ficha `ula_hero` en `COMPONENTS.md` §1.3, composición de SDC en `CONCEPTOS-DRUPAL.md`, y regla corregida de regiones heredadas en el plan (Fase 6). El tipo de contenido, el paragraph `hero_stat`, la vista y la composición en LB son **configuración (BD), no git**. |
| 1.6.1 | 2026-06-19 | **Documentación + configuración: el hero de página pasa a _filtro contextual_.** El emparejamiento hero ↔ página deja de hacerse por un **término de taxonomía fijo** (que obligaba a una vista por página) y pasa a un **filtro contextual** sobre `field_target_page` —referencia al **nodo** de la página— con valor por defecto «ID de contenido desde la URL». **Una sola `hero_view` sirve el hero de cualquier página.** La incógnita de cómo Layout Builder pasaba el argumento se disolvió: «ID de contenido desde la URL» lee el nodo de la **ruta**, no el contexto de LB (validado en `/about`). Cambio de modelo: se eliminó `field_hero_page` (término) y se creó `field_target_page` (nodo, acotado a `lb_contents`). **Sin cambios de código**: solo configuración (campo + vista, en BD) y documentación (`entities/hero.md`, `elements/layout/CONTENT-LAYOUT.md` §5.7). |
| 1.6.2 | 2026-06-20 | **Componente `ula_cta_band`** (franja/tarjeta de cierre, CTA). Nuevo componente SDC `ula_cta_band` (autónomo, por slots `title`/`text`/`actions`; borde azul marcado + fondo claro; **no** full-bleed, ocupa el ancho del contenedor) para el cierre de página antes del footer. Se alimenta de un **tipo de bloque de contenido** `cta_band` colocado en Layout Builder, compuesto por la plantilla `block--block-content--type--cta-band.html.twig` (nombre de sugerencia confirmado con el debug de Twig; pasa título y texto como valor crudo y el enlace como campo renderizado). Pieza **independiente del hero** (ADR hero=cabecera vs cta_band=cierre en `entities/cta_band.md`). Documentación: ficha en `COMPONENTS.md` §1.4 (y corrección del consumo del hero a filtro contextual), `entities/cta_band.md`, composición de bloque en `CONCEPTOS-DRUPAL.md`, conteos en `analysis/inventario-bi.md` (SDC 74→75, propios 15→16, plantillas 4→5), `README.md`. El tipo de bloque, sus campos y ejemplares son **configuración (BD), no git**. |

> **Mantenimiento:** al introducir cambios estructurales (nuevos componentes, cambios de
> arquitectura, nuevos elementos, colecciones editables), subir la versión del tema en
> `bootstrap_ula_lscm.info.yml` según el criterio semántico de arriba, añadir una fila a esta
> tabla, y actualizar el documento del elemento afectado en `docs/elements/`.

> **Nota histórica:** hasta la v1.0.0, el `version:` del tema heredaba el número del tema base
> (`2.17.6`), que no representaba el desarrollo propio. Desde la v1.0.0 se reinicia con
> versionado propio, como paso hacia la independencia del tema base.

---

## 2. Identidad y estado de independencia

`bootstrap_ula_lscm` es un tema propio cuyo objetivo a medio plazo es ser un **design system
autónomo** para el sitio del máster LSCM.

**Estado actual de independencia:**

- **Ya independiente:** el design system propio (componentes `ula_*`, tokens CSS, base de
  estilos — ver §3 y §4) no depende de ningún framework externo ni de las clases/CSS de ningún
  tema base. La home se construye íntegramente con él.
- **Dependencia técnica actual:** el tema declara todavía un `base theme` heredado (Bootstrap
  Italia) del que provienen el andamiaje de página, el sistema de regiones y las plantillas que
  aún no se han reescrito. Esta dependencia es un **estado de partida en proceso de retirada**,
  no un rasgo de identidad del tema.
- **Objetivo:** retirar progresivamente la dependencia del tema base, reescribiendo en clave
  propia las plantillas y estilos que aún se heredan. Cuando se complete, será un cambio de
  versión MAYOR.

> Por eso la documentación no describe el tema "como subtema de X", sino como un tema propio que
> aún se apoya, de forma transitoria, en una base heredada.

---

## 3. Design system: componentes SDC `ula_*`

El tema define un conjunto de **componentes SDC** (Single Directory Components) propios, con
prefijo `ula_`, autónomos e independientes de cualquier framework externo. Son **piezas
reutilizables** por cualquier elemento del tema: la home es su primer consumidor, pero no su
propietaria — cualquier sección futura del sitio puede componerlos.

Ubicación: `components/`. Cada componente es una carpeta con `.component.yml`, `.twig`, `.css`
y `.preview.story.yml`.

### Catálogo de componentes

| Componente | Rol | Props principales |
|---|---|---|
| `ula_hero_stat` | Estadística destacada | number, label |
| `ula_why_item` | Ítem de ventajas | number, title, description |
| `ula_feature_item` | Feature con icono | icon, title, description |
| `ula_req_card` | Tarjeta de requisito | icon, title, description |
| `ula_spec_card` | Tarjeta de especialización | icon, title, university, description, modules[], variant |
| `ula_sem_card` | Tarjeta de semestre | semester, icon, university, title, subjects[], variant |
| `ula_timeline_item` | Paso de cronología | title, description, show_line |
| `ula_uni_card` | Tarjeta de universidad | flag, country, name, abbr, description, tags[] |

> **Catálogo completo y al día.** La tabla anterior recoge los componentes de la **home**. El catálogo
> **autoritativo** de todos los componentes propios —incluidos los genéricos por slots `ula_card_simple`,
> `ula_grid_row` y `ula_hero` (este último con sus slots y la prop `size`)— está en
> [`COMPONENTS.md`](COMPONENTS.md), que es la referencia mantenida al día. Las entidades que los alimentan
> se documentan en `entities/` (p. ej. `entities/hero.md`).

### Convenciones y decisiones de diseño de los componentes

- **[DECISIÓN] Prefijo `ula_` solo en nombres** de ficheros, componentes y librerías (para
  coexistir con componentes similares del tema base, p.ej. `card` vs `ula_card`). **NO** se
  prefijan las variables CSS (`--eu-blue`) ni las clases CSS (`.uni-card`), que se mantienen tal
  cual provienen de la maqueta original.
- **[DECISIÓN] Separación contenedor/ítem.** Cada `ula_*` es solo el ítem individual. Los
  contenedores en rejilla (`.uni-grid`, `.why-grid`, `.journey-track`) y las animaciones
  (`.reveal`) los aporta la sección o el marco que compone los ítems, no el componente. Patrón
  análogo a `timeline2` (contenedor) vs `timeline_item2` (ítem) del propio sitio.
- **[DECISIÓN] Iconos = prop de texto con emoji** (solución simple). Iconos SVG o de librería
  serían una sofisticación futura.
- **[DECISIÓN] Listas (modules, subjects) = prop tipo array** de strings; el Twig del componente
  hace el bucle.
- **[DECISIÓN] Variantes de color = prop enum** (p.ej. `variant: primary|secondary` en
  `ula_spec_card`; `1|2|3|4` en `ula_sem_card`), que aplica las clases CSS correspondientes de
  la maqueta.
- **[DECISIÓN] `ula_journey_connector` DESCARTADO** como componente: es pura decoración del
  layout (una línea con gradiente) que depende del grid de la sección y se oculta en móvil. Vive
  como CSS/markup de la sección journey en el marco que lo use. (Por eso el design system tiene
  8 componentes, no 9.)
- **[DECISIÓN] Pastillas de `ula_uni_card` preparadas para interactividad futura:** `tags` es un
  array de objetos `{label, info}`. Hoy solo se renderiza `label` (estático, fiel a la maqueta);
  `info` está reservado para un popover/modal en una iteración posterior (con **API nativa** del
  navegador, sin frameworks externos). El Twig ya tolera tanto `{label, info}` como cadenas
  simples.

---

## 4. Sistema de CSS en tres capas

El CSS del tema se organiza en tres capas, de lo global a lo específico:

- **[DECISIÓN] Capa 1 — `ula_tokens`** (`css/ula-tokens.css`): variables CSS globales
  (`--eu-blue`, `--eu-yellow`, `--font-display`, etc.). Se carga **siempre** en todo el tema
  (declarada como global en `bootstrap_ula_lscm.info.yml`).
- **[DECISIÓN] Capa 2 — `ula_landing_base`** (`css/ula-landing-base.css`): reset, `.container`,
  `.section-*`, `.btn-*`, `.reveal`. Depende de `ula_tokens`. **NO** es global: se carga solo
  cuando el elemento que la necesita la declara como dependencia (p.ej. el marco de la home lo
  hace vía `libraryOverrides` — ver el documento de la home), para no cargar estilos con clases
  genéricas en todo el sitio y evitar colisiones.
- **[DECISIÓN] Capa 3 — CSS por componente:** cada `ula_*` y cada marco tienen su propio `.css`
  con sus estilos específicos. No duplican tokens ni base.

> **Mantenimiento CSS:** los nombres de variables y clases provienen de la maqueta y se mantienen
> sin prefijo. Al añadir estilos, respetar la capa correcta: tokens globales → capa 1; estilos
> base compartidos por una página entera → capa 2; estilos de un componente concreto → su propio
> `.css`.

---

## 5. Patrón de contenido editable: tipos de contenido + vistas + componentes

Este es el patrón con el que el tema convierte **contenido editable desde el admin** en
**presentación con los componentes `ula_*`**. Es transversal: se usará en cualquier elemento del
tema que necesite mostrar colecciones de ítems editables (la home es el primer caso, con sus
universidades, especializaciones, etc.).

### 5.1. Los tres conceptos de Drupal implicados

**Tipo de contenido (content type).** Es la *plantilla* que define qué campos tiene una clase de
entidad. Por ejemplo, un tipo de contenido "Universidad" se define por sus campos: nombre,
acrónimo, país, descripción, URL, galería de imágenes, etc. El tipo de contenido es el **molde**,
no el dato concreto.

**Nodo (node).** Es una *instancia* concreta de un tipo de contenido, con sus campos rellenos. Si
"Universidad" es el tipo (el molde), entonces "UAB" es un nodo (una pieza hecha con ese molde),
con su nombre, su acrónimo, su descripción, etc. Cada universidad real es un nodo. El contenido
editable desde el admin **son los nodos**: crear, editar o borrar una universidad es crear, editar
o borrar un nodo de tipo Universidad.

**Vista (view).** Es un elemento de Drupal que hace **dos cosas** a la vez:

1. **Selecciona** qué entidades mostrar (el *qué*): p. ej. "todos los nodos de tipo Universidad,
   publicados, ordenados por peso". Esto incluye filtrado y ordenación.
2. **Define cómo se renderiza** cada una (el *cómo*): p. ej. "pinta cada universidad con el
   componente `ula_uni_card`".

Es importante retener que la vista no solo decide la apariencia, sino también **qué subconjunto de
entidades entra y en qué orden**.

### 5.2. La pieza que conecta vista y componente: `ui_patterns_views`

El submódulo **`ui_patterns_views`** (de UI Patterns) es lo que permite que una vista, en lugar de
renderizar cada fila con el HTML por defecto de Drupal, la renderice con un **componente SDC**,
**mapeando los campos del nodo a las props del componente**.

Por ejemplo, para la colección de universidades:

- La vista selecciona los nodos de tipo Universidad.
- Para cada fila (cada universidad), `ui_patterns_views` pinta el componente `ula_uni_card`,
  mapeando: campo *nombre* → prop `name`, campo *acrónimo* → prop `abbr`, campo *país* → prop
  `country`, campo *descripción* → prop `description`, etc.
- El resultado es una rejilla de tarjetas `ula_uni_card`, una por universidad, alimentada por
  contenido editable.

Este es el **mismo patrón que el sitio ya usa** en la timeline de Admissions: nodos
`ct_admission_preenrolment_step` listados por una vista que los pinta con el componente
`timeline_item2` vía `ui_patterns_views`.

> **Distinción importante (lección aprendida).** Este mecanismo —"pinta **cada fila de una vista**
> con un componente"— es **distinto** de "renderiza **una entidad completa** (un nodo o un bloque)
> con un componente". Lo segundo es lo que UI Patterns 2.x **no** ofrece sin Layout Builder (ver el
> documento de la home, sobre por qué la home se sirve con una plantilla Twig y no con
> `ui_patterns_blocks` ni Layout Builder). `ui_patterns_views` opera a nivel de *fila de vista* y es
> el caso de uso para el que está diseñado; no comparte aquella limitación.
>
> **Actualización (v1.5.1):** la frase anterior "no ofrece sin Layout Builder" no implica que Layout
> Builder esté descartado en el proyecto. **Se descartó para la home** (portada a medida servida con
> plantilla Twig, ADR-001), pero **se adopta como mecanismo de composición del contenido de las
> páginas no-home** (ver `../elements/layout/CONTENT-LAYOUT.md`, ADR-LAYOUT-004). En ese modelo, una
> vista que pinta entidades con componentes (lo que sí ofrece `ui_patterns_views`) se inserta como
> **bloque** dentro de una sección de Layout Builder. Es decir: la composición de la página la da LB; el
> render de cada entidad como tarjeta lo da `ui_patterns_views`. Los dos contextos (home con Twig,
> no-home con LB) conviven deliberadamente.


### 5.3. Una misma entidad, varias representaciones

Como la vista decide *cómo* se renderiza cada entidad en *su* contexto, una misma entidad puede
mostrarse de formas distintas en sitios distintos. La misma universidad UAB puede aparecer:

- En la home → una vista la pinta como `ula_uni_card` (tarjeta compacta, pocos campos).
- En una página de detalle → mostrada con todos sus campos (galería incluida), con otro display.

Por eso, cuando una colección representa una **entidad con vida propia** en el sitio (no solo
decoración de una página), modelarla como tipo de contenido + nodos la hace **reutilizable** en
varios contextos, no solo en la página donde aparece primero.

### 5.4. Resumen del patrón

```
Tipo de contenido  →  define los campos      (el molde: "Universidad")
        ↓
Nodos              →  el contenido editable   (las piezas: "UAB", "RTU"…)
        ↓
Vista              →  selecciona + ordena los nodos
        ↓  (vía ui_patterns_views)
Componente ula_*   →  pinta cada nodo, mapeando campos → props
```

Crear o editar contenido = trabajar con los **nodos** (en el admin, sin tocar código). La **vista**
y el **mapeo campos→props** se definen una vez (configuración) y a partir de ahí el contenido fluye
solo.

### 5.5. Implementación en Views: el patrón de dos niveles

Esta subsección recoge el detalle **técnico real** de cómo se configura el patrón en una vista de
Drupal con `ui_patterns_views`, observado en una vista existente del sitio (la de las universidades
del consorcio). Sirve de referencia para construir vistas equivalentes en cualquier sección.

Una vista que pinta una colección con componentes usa **dos niveles**, cada uno con su propio
componente UI Patterns:

**Nivel 1 — el *Format / Style* de la vista (el contenedor).** En la configuración de la vista,
`Format → Show: Component (UI Patterns)` define un componente que envuelve **todas** las filas.
Típicamente es un componente de **rejilla** cuyo slot de contenido recibe la fuente especial
`view_rows` ("todas las filas de la vista"). Ahí se configuran las columnas responsive del grid.

**Nivel 2 — el *Row* (cada entidad individual).** En `Format → Show → Settings` (o el row del
display), se define el componente que pinta **cada fila**, mapeando los campos de la vista a sus
slots o props. Cada slot/prop se alimenta con una **fuente** (`source_id`), siendo las más
habituales:

- `view_field` → el valor de un campo de la vista (p. ej. el slot `card_title` ← campo `title`).
- `textfield` → un valor literal fijo escrito en la configuración (p. ej. la etiqueta `"+ info"`).
- `component` → **otro componente anidado** dentro del slot (permite componer; p. ej. un modal
  dentro del cuerpo de una tarjeta).
- `view_rows` → todas las filas (se usa en el slot de contenido del contenedor del nivel 1).

**Slots vs props en el mapeo.** Un componente puede exponer *slots* (reciben contenido renderizado,
HTML — p. ej. `card_title`, `card_text`) y *props* (reciben valores que el componente formatea —
p. ej. `name`, `country`). El mecanismo de mapeo (`view_field`, etc.) es el mismo; lo que cambia es
si el destino es un slot o una prop. Los componentes `ula_*` del design system se basan sobre todo
en **props** (valores), mientras que componentes heredados tipo `card` se basan en **slots**
(contenido).

**El enlace a la página de la entidad.** Para que un campo enlace a la página del propio nodo
(`/node/N`), **no se usa un campo de URL ni se almacena nada**: se marca, en la configuración de ese
campo dentro de la vista, la casilla **"Link this field to the original entity"**
(`link_to_entity: true`). Es una propiedad del campo **en la vista**, no del tipo de contenido ni del
nodo. Drupal genera la URL canónica del nodo automáticamente. (Si la entidad tiene página de detalle
propia, este es el mecanismo para enlazarla desde una tarjeta.)

**Esquema del patrón de dos niveles:**

```
Vista
├── Format/Style: Component (UI Patterns)  →  componente CONTENEDOR (rejilla)
│        slot "content" ← view_rows  (todas las filas)
│
└── Row: Component (UI Patterns)            →  componente ÍTEM (tarjeta), por cada fila
         slot/prop ← view_field (campo del nodo)
         slot/prop ← textfield  (valor literal)
         slot/prop ← component  (componente anidado, opcional)
         [campo con link_to_entity: true → enlaza a /node/N]
```

> **Nota de independencia.** Una vista heredada puede usar componentes del tema base (rejillas o
> tarjetas de Bootstrap). Al construir vistas para secciones reescritas en clave propia, se replica
> **el patrón** (dos niveles, mapeo de fuentes) pero con **componentes propios**: la rejilla y la
> tarjeta del design system `ula_*`, no las del tema base.

**Lecciones aprendidas al alimentar los slots (v1.5.1).** Al validar este patrón dentro de una página
compuesta con Layout Builder (ver `../elements/layout/CONTENT-LAYOUT.md` §5), se confirmaron tres puntos
que conviene tener presentes para que las tarjetas se rendericen completas:

- **`view_field` vs `entity_field` (decisivo para imágenes).** Hay dos vías para alimentar un slot desde
  una vista: `view_field` (referenciar un campo **añadido en la sección *Fields*** de la vista, ya
  renderizado por su formatter) y `entity_field` / `[Entity] ➜ [Field]` (tomar el campo directamente de
  la entidad de la fila). La segunda sirve para **texto**, pero **no permite configurar el formatter de
  imagen** en el contexto de fila de Views, por lo que las imágenes quedan en blanco. **Regla: alimentar
  todos los slots con `view_field`** (campos en *Fields*), que es lo que hace la vista heredada
  equivalente y lo validado como correcto.
- **El formatter de imagen va en el campo de la vista, no en el slot.** Para una imagen: añadir el campo
  a *Fields*, ponerle **Formatter = Image con un image style no vacío**, y apuntar el slot a ese campo
  vía `view_field`. Un image style **vacío** hace que la imagen no se vea aunque el mapeo sea correcto.
- **La variante del componente.** Si la tarjeta solo pinta el hueco de imagen en una **variante**
  concreta, hay que seleccionar esa variante en la configuración del componente (selector *Variant*,
  antes de los slots). Con la variante por defecto, el dato de imagen puede llegar al slot y **aun así no
  pintarse**.

> **Método (lección de proceso).** Estos puntos se resolvieron **comparando** la vista nueva con la vista
> heredada que ya renderizaba las tarjetas correctamente, no teorizando en abstracto. Ante un slot que no
> pinta, la primera pregunta es *"¿en qué se diferencia esto de lo que ya funciona?"*. El detalle completo
> de este flujo, con un checklist de diagnóstico, está en `../elements/layout/CONTENT-LAYOUT.md` §5.


### 5.6. Entidades de relación (cruces entre dos entidades)

Algunos datos no pertenecen a una entidad ni a otra, sino a la **combinación de dos**. Cuando la
información depende del cruce de dos entidades (y no es atributo de ninguna por separado), ese cruce
**es en sí mismo una entidad** — una *entidad de relación* o "through entity".

**Caso de referencia:** la relación **universidad × semestre** (`ct_university_semester`, v1.3.0). El
texto que se muestra al pulsar la pastilla de un semestre en la tarjeta de una universidad depende de
**qué universidad y qué semestre** se cruzan ("RTU en el Semestre 3" ≠ "TH Wildau en el Semestre 3").
Por eso se modela como una entidad cuyos nodos son cada uno un cruce, con **dos `entity_reference`**:
una al **nodo** universidad y otra al **término de taxonomía** semestre.

**Cómo funciona el mecanismo:**

1. **La entidad de relación** tiene una referencia a cada lado del cruce (`field_us_university` →
   nodo; `field_us_semester` → término de taxonomía) más los datos propios del cruce
   (`field_us_pill_label`, `field_us_modal_text`).
2. **Consulta "hacia atrás":** para construir las pastillas de una universidad, el tema consulta los
   nodos de relación que **referencian** esa universidad
   (`entityQuery` con `condition('field_us_university', $nid)`), ordenados por `field_order`. Cada
   nodo de relación aporta una pastilla `{label, info}`.
3. **Combinación con atributos propios:** a esas pastillas de relación se les puede **añadir** las que
   provienen de atributos de la entidad consultada (p. ej. la pastilla "Lead Partner", que es un campo
   booleano de la universidad, no un cruce con semestre). La función de carga combina ambas fuentes.

**Por qué una entidad de relación y no un campo:**
- Un dato que depende de la combinación de dos entidades, metido como campo en una de ellas, queda
  "atrapado" en ese lado y solo sirve para una dirección de consulta.
- La entidad de relación se consulta **desde cualquier ángulo**: "los semestres de esta universidad"
  (para las pastillas) o "las universidades de este semestre" (para una futura página comparativa).
  Esto la hace apta para **varios consumidores** (ver ADR-004 en HOME-ARCHITECTURE: la home ahora, la
  página Consortium en el futuro).
- Las referencias son por **ID**, no por texto: renombrar un término de semestre no rompe las
  relaciones que lo apuntan.

> **Independencia respecto a la taxonomía referenciada.** Referenciar un vocabulario existente (aquí,
> `semester`) **no lo altera**: la entidad de relación solo lo lee. La taxonomía mantiene su propio
> uso (agrupar las asignaturas, ver `analysis/contents-subject-entity.md`); la relación se apoya en
> ella sin interferir.

---

## 6. Notas técnicas y restricciones del entorno

Esta sección documenta restricciones del entorno y comportamientos no evidentes de Drupal /
UI Patterns que condicionan cómo se construye y mantiene este tema. No son anécdotas: cada una
afecta a decisiones concretas y a cómo deben hacerse las ampliaciones futuras. Aplican a
**todos** los elementos del tema.

### 6.1. Sitio sin gestión de configuración (config/sync)

Drupal separa **contenido** (nodos, textos — siempre en BD) de **configuración** (tipos de
contenido, campos, vistas, displays, ajustes). La configuración *puede* exportarse a ficheros
YAML versionables (`config/sync`) mediante la gestión de configuración, pero **este sitio no la
usa**: la configuración vive **solo en la base de datos**.

Implicaciones para el mantenimiento:

- **Git versiona el código** (tema, componentes, plantillas, esta documentación), **no la
  configuración**. El tipo de contenido `landing`, sus 42 campos, el nodo de la home, la front
  page y las visibilidades de bloques **no están en git**.
- **El respaldo de la configuración son los dumps de BD** (`ddev export-db`). Antes de cualquier
  cambio de configuración hay que hacer un dump; es la única forma de revertir.
- **Conviene evitar meter configuración pesada en BD.** Por este motivo, en su momento, se descartó
  Layout Builder **para la home** (ver el documento de la home): habría añadido configuración compleja a
  una BD que no se versiona, haciendo el sitio más frágil de reproducir, y para una portada a medida se
  prefirió un mecanismo que vive en código (plantilla Twig en el tema).
  **Matización (v1.5.1):** este criterio sigue vigente, pero **no implica un descarte global de Layout
  Builder**. Para las **páginas no-home** (muchas, heterogéneas, de estructura repetible) **sí se adopta
  Layout Builder** como mecanismo de composición (ver `../elements/layout/CONTENT-LAYOUT.md`,
  ADR-LAYOUT-004), **asumiendo conscientemente** el coste de añadir configuración no versionada a la BD a
  cambio de la flexibilidad de composición. Es decir: se evita meter configuración pesada en BD **salvo
  cuando el mecanismo lo justifica** (LB para páginas no-home); cuando se hace, la red de seguridad es la
  misma de siempre (dump antes de tocar) y refuerza el interés de adoptar gestión de configuración (§7).
- **Riesgo conocido de `config:import`:** en este proyecto, importar configuración global ha
  fallado por dependencias de módulos (p.ej. `ui_patterns_field_formatters`). Evitar
  `config:import` / `theme:uninstall` globales; preferir cambios quirúrgicos.

### 6.2. Crear campos por código requiere tres pasos, no uno

Cuando se crea un campo desde la **interfaz** de Drupal, este encadena automáticamente tres
operaciones. Al crearlo **por código** (scripts), hay que hacer las tres explícitamente, o el
campo "existe" pero no se ve:

1. **`FieldStorageConfig`** — define el almacenamiento del campo (tipo de dato, cardinalidad).
   A nivel de entidad.
2. **`FieldConfig`** — vincula el campo a un bundle concreto (aquí, el tipo `landing`) con su
   etiqueta.
3. **Registro en el form display** — añade el campo al **formulario de edición** con su widget.
   **Sin este paso, el campo existe en la entidad pero no aparece al editar el nodo** (fue
   exactamente lo que ocurrió al crear los 42 campos de la home por script).

Recomendación adicional: asignar el **`weight`** de cada campo por secciones desde el inicio, o
el formulario queda en orden de creación/alfabético (poco usable con decenas de campos). Ver los
scripts en `scripts/` como referencia.

### 6.3. Límite de longitud en props de texto (UI Patterns / campos string)

Los campos de tipo `string` (texto plano) tienen un límite por defecto de **128 caracteres**.
Los textos largos (p.ej. las descripciones de la home) superan ese límite, lo que provoca un
error al guardar ("cannot be longer than 128 characters").

- En el `.component.yml` del componente, las props de texto largo deben declarar `maxLength`
  amplio (en la home, las descripciones del marco usan `maxLength: 1000`).
- Los **campos** de texto largo se crean como `string_long` (texto largo), no `string`.
- Al añadir nuevas props/campos de texto extenso, aplicar el mismo criterio.

### 6.4. `default` de SDC no se inyecta de forma fiable en runtime

Los valores `default` declarados en el `.component.yml` se usan para validación y para la
galería, pero **no se inyectan de forma garantizada** cuando el componente se renderiza vía
`include()` con un objeto de props parcial: las props ausentes quedan vacías en lugar de tomar
su default.

- **Solución aplicada:** los valores de fábrica se definen en el **`.twig` del componente** con
  el filtro `|default()`. Así el componente se ve completo aunque no se le pase nada, y los
  valores que sí se pasan (p.ej. los campos de un nodo) sobreescriben esos defaults cuando tienen
  contenido. (Ver cómo lo aplica el marco de la home.)
- Al añadir props nuevas con valor por defecto, definir el default con `|default()` en el
  `.twig`, no confiar solo en el `.component.yml`.

### 6.5. `position: fixed` y entornos de previsualización

Un elemento `position: fixed` (p.ej. una barra de navegación fija) se ancla a la **ventana del
navegador**, no a su contenedor. Consecuencias observadas:

- En la **galería de UI Patterns** (`/admin/appearance/ui/components`), un nav fijo se solapa con
  la barra de administración → la galería **no sirve** para validar páginas completas con
  elementos fijos; sirve para componentes sueltos.
- Incrustado como bloque dentro de la plantilla del tema base, un nav fijo choca con el header
  heredado.
- **Por eso** los elementos que son páginas completas con navegación fija (como la home) se
  sirven con su propia plantilla de página, sin el chrome del tema base.

### 6.6. Método de trabajo recomendado

- **Validar la tubería completa con un caso mínimo** antes de replicar a escala (en la home se
  validó la editabilidad con un solo campo antes de crear los 42; se validará una colección
  piloto antes de migrar las 8).
- **Dump de BD antes de cada cambio de configuración.**
- **Consolidar en git por hito**, y verificar que el repositorio y el entorno de trabajo
  coinciden tras cada push.
- **Preferir el método menos invasivo primero**; evitar operaciones globales de configuración.

---

## 7. Pendientes transversales del tema

Los pendientes que afectan a todo el tema están en **`TODO.md`** (raíz del tema): avisos de
obsolescencia de Gutenberg en la salida de drush, actualización de seguridad de Drupal, errores
de renderizado en la galería de UI Patterns, y la valoración de adoptar gestión de configuración
(config/sync).

Los pendientes específicos de un elemento están en el documento de ese elemento (p.ej. los de la
home, en `docs/elements/home/HOME-ARCHITECTURE.md`).

---

## 8. Estructura de ficheros del tema

```
bootstrap_ula_lscm/
├── bootstrap_ula_lscm.info.yml          # Identidad, versión propia, carga ula_tokens global
├── bootstrap_ula_lscm.libraries.yml     # Define ula_tokens y ula_landing_base
├── bootstrap_ula_lscm.theme             # Lógica del tema: preprocess de la home (carga de las 8
│                                        # colecciones, menú de la hamburguesa, pastillas de
│                                        # universidad) y funciones auxiliares de carga
├── TODO.md                              # Pendientes transversales del tema
├── css/
│   ├── ula-tokens.css                   # Capa 1: variables globales
│   ├── ula-landing-base.css             # Capa 2: base de estilos
│   └── lscm-page.css                    # Marco de páginas: rejilla propia (librería lscm_page)
├── components/                          # (Solo se listan los componentes PROPIOS del tema. Conviven
│   │                                    #  en esta carpeta con componentes heredados de Bootstrap
│   │                                    #  Italia / anteriores a los ula_*, que NO se listan aquí.)
│   ├── ula_hero_stat/  ula_why_item/  ula_feature_item/  ula_req_card/
│   ├── ula_spec_card/  ula_sem_card/  ula_timeline_item/  ula_uni_card/   # Design system (§3)
│   ├── lscm-master-page/                # Marco de la home (ver doc del elemento home)
│   ├── lscm_page_header/                # Header del marco de páginas de contenido (elemento layout)
│   ├── lscm_page_footer/                # Footer provisional del marco de páginas (elemento layout)
│   └── lscm-master-static/              # Maqueta original de referencia (no en producción)
├── templates/                           # Plantillas Twig, organizadas en subcarpetas por tipo
│   ├── layout/                          # Plantillas de página/región (page--*, html, region--*)
│   │   ├── page.html.twig               # Marco genérico propio de páginas no-home (elemento layout)
│   │   └── page--front.html.twig        # Portada (elemento home)
│   └── content/                         # Plantillas de entidad (node--*, etc.)
│       └── node--landing.html.twig      # Render del nodo landing (elemento home)
└── docs/
    ├── README.md                        # Índice de la documentación
    ├── ARCHITECTURE.md                  # Este documento (nivel tema)
    ├── analysis/                        # Hallazgos de investigación (secciones existentes a rehacer)
    │   ├── about-and-university-entity.md
    │   ├── about-page-heredada.md
    │   ├── contents-subject-entity.md
    │   └── inventario-bi.md             # Inventario propios vs heredados (Fase 0, artefacto vivo)
    ├── entities/                        # Diseño de entidades propias del tema (no heredadas)
    │   ├── programme-facts.md
    │   ├── admission-journey-step.md
    │   ├── programme-feature.md
    │   ├── admission-requirement.md
    │   ├── programme-specialisation.md
    │   ├── programme-semester.md
    │   └── university-semester.md
    ├── elements/                        # Documentación de referencia por elemento
    │   ├── home/
    │   │   └── HOME-ARCHITECTURE.md     # Documentación del elemento "home"
    │   └── layout/                          # Elemento "layout", en dos ficheros (uno por elemento del layout)
    │       ├── SHARED-FRAME-LAYOUT.md       # Marco compartido de páginas (header + footer + page.html.twig)
    │       └── CONTENT-LAYOUT.md            # Diseño del contenido de páginas no-home con Layout Builder
    └── plans/                           # Planes de desarrollo por fases, por elemento
        ├── paginas-contenido/           # Plan de páginas de contenido e independencia de BI (plan maestro)
        │   └── plan-sistema-paginas-contenido.md                    # Plan activo (8 fases, 0–7)
        └── home/
            └── archive/                 # Planes completados (se conservan como referencia histórica)
                ├── plan-colecciones-editables-e-interactividad.md   # Plan de colecciones e interactividad (completado)
                └── plan-landing-parametrizada.md                    # Plan inicial de la landing (completado)
```

> **Nota sobre la carpeta del tema.** El árbol recoge **lo que construimos en el tema** (código y
> documentación propios). No se listan: los **componentes heredados** de Bootstrap Italia o anteriores
> a los `ula_*` (conviven en `components/` pero no son del design system propio); ni las carpetas de
> **andamiaje heredado o generado** —`config/` (configuración de instalación heredada de BI), `src/`
> (fuentes SCSS/fuentes de BI), `modules/` (submódulos heredados) y `dist/` (salida del build de
> Webpack, generada en local)—, que no forman parte de lo que diseñamos y se reconstruyen o vienen del
> tema base.

> **[CONVENCIÓN] Organización de `templates/` en subcarpetas por tipo.** Las plantillas Twig se
> organizan en subcarpetas según el tipo de elemento de Drupal que sobreescriben, para mantener
> el directorio navegable a medida que el tema crece:
>
> - `templates/layout/` — plantillas de página y región: `page--*.html.twig`, `html.html.twig`, `region--*.html.twig`.
> - `templates/content/` — plantillas de entidad: `node--*.html.twig`, etc.
> - `templates/block/`, `templates/field/`, `templates/views/`, `templates/navigation/` — se crean cuando se necesiten (bloques, campos, vistas, menús).
>
> Drupal localiza las plantillas por su **nombre**, no por su ubicación (busca de forma recursiva
> en `templates/` y subcarpetas), por lo que esta organización es puramente para claridad y no
> afecta a la funcionalidad. Tras mover una plantilla, ejecutar `ddev drush cr` para que Drupal
> reindexe el registro de plantillas.

> La documentación de cada **elemento** del tema (la home, y las secciones que se desarrollen en
> el futuro) vive en `docs/elements/<elemento>/`. Este documento (nivel tema) cubre lo común a
> todos ellos.
