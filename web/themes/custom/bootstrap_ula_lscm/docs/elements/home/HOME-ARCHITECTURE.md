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

> **Esta es la sección de referencia para el mantenimiento diario de la home.** Describe, para cada
> tipo de contenido editable, **qué es, dónde aparece en la página, dónde se edita en el admin de
> Drupal, y qué campos participan**. Todo lo que aquí se describe se edita **sin tocar código**.

El contenido editable de la home se agrupa en cuatro bloques, según **dónde y cómo** se edita:

- **A. Textos de la página** — los textos de cada sección (tags, títulos, descripciones, botones).
  Se editan en el nodo de la home.
- **B. Colecciones de tarjetas e ítems** — los conjuntos de tarjetas repetidas (universidades,
  especializaciones, etc.). Cada ítem es un nodo propio.
- **C. Menú de navegación del header** — los enlaces de la hamburguesa. Se editan en el gestor de
  menús.
- **D. Pastillas de las universidades** — las etiquetas de semestre y "Lead Partner" de cada
  universidad. Se editan en nodos de relación + un atributo de la universidad.

---

### A. Textos de la página → se editan en el nodo de la home

**Dónde se edita:** el nodo de la home → *Content → "Home Master LSCM" → Edit* (ruta `/node/55/edit`).

**Cómo funciona el valor por defecto:** cada campo de texto tiene un **valor "de fábrica"** (el de la
maqueta). Si el campo se deja **vacío**, la página muestra ese valor de fábrica; si se **rellena**,
muestra lo que se haya escrito. Por eso **solo hace falta rellenar los campos que se quieran cambiar**
respecto a la maqueta — los vacíos no salen en blanco, salen con su texto de fábrica.

> En las tablas siguientes, la columna **"Valor de fábrica"** es, precisamente, lo que se ve hoy en la
> home (ya que los campos del nodo están vacíos y actúa el valor por defecto). Sirve de ejemplo de qué
> controla cada campo y dónde aparece.

Las tablas siguen el **orden en que las secciones aparecen al recorrer la página** de arriba a abajo.

#### Header (barra superior fija)

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Logo URL | `field_logo_url` | `/sites/default/files/2026-06/logo-MASTER-LSCM.png` |
| Brand top | `field_brand_top` | LSCM Master |
| Brand sub | `field_brand_sub` | European Joint Programme |

#### Hero (cabecera grande de bienvenida)

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Hero badge | `field_hero_badge_text` | Erasmus+ Joint Master's Programme |
| Hero · title | `field_hero_title` | Shape the Future of |
| Hero title highlight | `field_hero_title_highlight` | European Logistics |
| Hero description | `field_hero_description` | A 120 ECTS joint master's degree taught across three European universities… |
| Hero CTA1 text | `field_hero_cta1_text` | Apply Now |
| Hero CTA1 URL | `field_hero_cta1_url` | /admission |
| Hero CTA2 text | `field_hero_cta2_text` | Explore Programme |
| Hero CTA2 URL | `field_hero_cta2_url` | /programme |

#### About (sección "qué es el programa")

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| About tag | `field_about_tag` | Master in Logistics & Supply Chain Management |
| About title | `field_about_title` | Integrated. International. Industry-Ready. |
| About description | `field_about_desc` | A programme designed to train professionals capable of making decisions… |
| About CTA text | `field_about_cta_text` | Learn more about the programme |
| About CTA URL | `field_about_cta_url` | /about |

#### Journey (sección "Four Semesters Across Europe")

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Journey tag | `field_journey_tag` | Your academic path |
| Journey title | `field_journey_title` | Four Semesters Across Europe |
| Journey description | `field_journey_desc` | A carefully structured curriculum that builds from core foundations… |
| Journey CTA text | `field_journey_cta_text` | See full curriculum |
| Journey CTA URL | `field_journey_cta_url` | /programme |

#### Universities / Partners (sección de universidades socias)

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Uni tag | `field_uni_tag` | Our partner institutions |
| Uni title | `field_uni_title` | Three Countries. One Programme. |
| Uni description | `field_uni_desc` | A consortium of established European universities… |
| Uni CTA text | `field_uni_cta_text` | Meet the partner universities |
| Uni CTA URL | `field_uni_cta_url` | /partners |

> Las **tarjetas** de cada universidad (no estos textos de cabecera) son una colección editable
> aparte: ver **B. Colecciones**. Las **pastillas** de cada tarjeta: ver **D. Pastillas**.

#### Specialisations (sección "Two Specialisations, One Qualification")

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Spec tag | `field_spec_tag` | Choose your track |
| Spec title | `field_spec_title` | Two Specialisations, One Qualification |
| Spec description | `field_spec_desc` | Your choice of specialisation in year two shapes your career direction… |
| Spec CTA text | `field_spec_cta_text` | Explore specialisations |
| Spec CTA URL | `field_spec_cta_url` | /specialisations |

#### Admission (sección "Ready to Apply?")

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Adm tag | `field_adm_tag` | Admissions |
| Adm title | `field_adm_title` | Ready to Apply? |
| Adm description | `field_adm_desc` | Applications are reviewed on a rolling basis… |
| Adm CTA text | `field_adm_cta_text` | See full admission details |
| Adm CTA URL | `field_adm_cta_url` | /admission |

#### Contact / Get in touch (sección final de contacto)

| Etiqueta en Drupal | Campo | Valor de fábrica (ejemplo) |
|---|---|---|
| Contact tag | `field_contact_tag` | Get in touch |
| Contact title | `field_contact_title` | Still have questions? |
| Contact description | `field_contact_desc` | Our programme coordinators are happy to help… |
| Contact email | `field_contact_email` | info@master-lscm.eu |
| Contact FAQ text | `field_contact_faq_text` | Read FAQs |
| Contact FAQ URL | `field_contact_faq_url` | https://master-lscm.eu/faq |

> **Nota sobre las URLs de los CTA.** Algunos enlaces de botón apuntan a páginas internas del sitio
> (`/about`, `/programme`…) y otros pueden ser **externos** (la FAQ, por ejemplo). Son los campos más
> susceptibles de cambiar; se editan aquí, en el nodo de la home, sin tocar código.

---

### B. Colecciones de tarjetas e ítems → se editan como contenido (nodos)

**Qué son:** los conjuntos de elementos repetidos de la home — las tarjetas de universidades, las de
especializaciones, los semestres del journey, los why-items, los pasos de la timeline de admisión,
los requisitos, las features del about y las stats del hero. **Cada ítem de una colección es un nodo
propio**, de un tipo de contenido específico.

**Dónde se editan:** en *Content* (`/admin/content`), filtrando por el tipo de contenido
correspondiente. Añadir un ítem = crear un nodo de ese tipo; reordenar = el campo *Order* de cada
nodo; quitar = despublicar o borrar el nodo. **Los cambios aparecen en la home automáticamente, sin
tocar código.**

Cada colección, su tipo de contenido y dónde aparece en la página:

| Colección (dónde aparece) | Tipo de contenido a editar | Componente |
|---|---|---|
| **Stats del hero** (cifras bajo la cabecera) | `ct_programme_facts` (con *show in hero*) | `ula_hero_stat` |
| **Why-items** (motivos, en el About) | `ct_programme_facts` (con *show in why*) | `ula_why_item` |
| **Features del About** (lista de rasgos) | `ct_programme_feature` | `ula_feature_item` |
| **Tarjetas de universidad** (Partners) | `ct_about_consortium_university` | `ula_uni_card` |
| **Semestres del Journey** | `ct_programme_semester` | `ula_sem_card` |
| **Tarjetas de especialización** | `ct_programme_specialisation` | `ula_spec_card` |
| **Pasos de la timeline** (Admission) | `ct_admission_journey_step` | `ula_timeline_item` |
| **Requisitos** (Admission) | `ct_admission_requirement` | `ula_req_card` |

> **Detalle de cada tipo de contenido** (sus campos, decisiones de diseño y cómo se consume): ver las
> fichas en [`../../entities/`](../../entities/). Cada documento describe el modelo de campos de una
> entidad. El **mecanismo** por el que estos nodos llegan a la página (preprocess → prop) está en
> [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) §5 y en el ADR-002 (§7).

> **Dos detalles útiles para el editor:**
> - `ct_programme_facts` alimenta **dos** colecciones distintas (stats del hero y why-items); cada
>   nodo elige en cuál aparece mediante sendas casillas (*show in hero* / *show in why*).
> - Las tarjetas de **especialización** y de **semestre** admiten **texto enriquecido** (rich text) e
>   **imágenes/logos** de la biblioteca de Media, no solo texto plano.

---

### C. Menú de navegación del header (hamburguesa) → se edita en el gestor de menús

**Qué incluye:** los enlaces del **menú desplegable (hamburguesa)** del header de la home, que dan
acceso directo a las secciones/páginas reales del sitio (About, Contents, Elegibility, Admission,
Student Hub… y las que se añadan).

**Dónde:** en el gestor de menús de Drupal → `/admin/structure/menu/manage/home_header`
(menú "Home header menu", machine name `home_header`).

**Cómo funciona:**
- El header de la home lee el menú `home_header` y pinta sus enlaces (título + URL, en orden) en el
  panel de la hamburguesa. La carga la hace una función del tema
  (`_bootstrap_ula_lscm_get_menu_links()` en el `.theme`), que pasa los enlaces como prop
  `header_menu` al marco; el marco los pinta y un JS nativo gestiona el toggle (abrir/cerrar,
  accesible). Ver ADR correspondiente en §7.
- **Añadir, quitar o reordenar enlaces NO requiere tocar código:** se hace desde el admin, y la
  hamburguesa los refleja automáticamente. Este es el mecanismo de mantenimiento del menú a medida
  que se vayan implementando las páginas del sitio: cada página nueva → se añade su enlace a
  `home_header` en el admin → aparece en la hamburguesa.

**Convivencia con las anclas.** La hamburguesa **convive** con la barra de anclas internas del nav
(About→`#about`, Programme→`#journey`…), que son navegación *dentro* de la landing y siguen
hardcodeadas en el marco. Son dos navegaciones con propósitos distintos: las anclas saltan a las
secciones-resumen de la home; la hamburguesa lleva a las páginas reales del sitio.

> **Fuente de verdad.** El menú `home_header` es **configuración**, vive en la **BD** (no en git); su
> red de seguridad es el **dump**, como el resto de la configuración del sitio. El *código* que lo
> renderiza (la función del `.theme`, el marco, el CSS y el JS) sí vive en git.

> **Independencia respecto al header de las páginas internas.** `home_header` es un menú **propio** de
> la home, distinto del menú `main` del sitio. Decisión deliberada: el header de la home (anclas +
> hamburguesa) y el de las futuras páginas internas (navegación híbrida estándar) serán
> funcionalmente distintos, y no deben compartir menú para no acoplarse. Ver §5.2 y el ADR
> correspondiente.

---

### D. Pastillas de las tarjetas de universidad → se editan en nodos + atributo de la universidad

**Qué incluye:** las **pastillas** que aparecen en cada tarjeta de universidad (sección Partners):
las de **semestre** ("Semester 1", "Semester 2"…) y la de **"Lead Partner"** (solo en la universidad
líder). Al pulsarlas mostrarán un modal con información (interactividad: ver §5.3).

**Dónde y cómo se editan** (hay **dos** orígenes distintos, importante entenderlo):

1. **Pastillas de semestre** → contenido de tipo **"University–Semester"**
   (`/admin/content?type=ct_university_semester`). Cada nodo es **una pastilla de una universidad en
   un semestre**. Para añadir/editar una pastilla de semestre:
   - *University:* se elige la universidad (de las del consorcio).
   - *Semester:* se elige el semestre (de la taxonomía de semestres del sitio).
   - *Pill label:* el texto que se ve en la pastilla (p. ej. "Semester 3"). Puede no coincidir con el
     nombre largo del semestre.
   - *Modal text:* el texto que se mostrará al pulsar la pastilla (admite párrafos y listas; formato
     Basic HTML). Aquí se explica, por ejemplo, que el 3º/4º semestre es opcional según la universidad.
   - *Order:* el orden de esa pastilla dentro de la universidad.
   - **Añadir una pastilla de semestre a una universidad = crear un nodo de este tipo.** Aparece
     automáticamente en la tarjeta, sin tocar código.

2. **Pastilla "Lead Partner"** → es un **atributo de la universidad**, no un semestre. Se edita en el
   propio nodo de la universidad (`ct_about_consortium_university`):
   - *Is lead partner* (casilla): márcala en la universidad líder (solo una).
   - *Lead partner modal text:* el texto del modal de esa pastilla (Basic HTML).
   - La etiqueta "Lead Partner" es **fija**: no se edita; solo se controla si aparece (la casilla) y
     qué dice su modal.

**Cómo se construye la tarjeta:** el tema reúne, para cada universidad, sus pastillas de semestre (los
nodos University–Semester que la referencian, por orden) y, si está marcada como líder, añade al final
la pastilla "Lead Partner". El detalle del mecanismo está en `../../ARCHITECTURE.md` §5.6 y en el
ADR-004 (§7).

> **Fuente de verdad.** Tanto los nodos University–Semester como los campos de la universidad son
> **contenido/configuración** que vive en la **BD**; su red de seguridad es el **dump**. El código que
> los combina y los pinta vive en git.

> **Por qué dos orígenes.** Las pastillas de semestre dependen del cruce universidad × semestre (y esa
> relación se reutilizará en la futura página Consortium), por eso son una entidad propia. "Lead
> Partner" no es un semestre, sino un rol de la universidad, por eso vive en la universidad. Ver
> ADR-004.

---

## 5. Pendientes de la home

Pendientes específicos de la home. (Los pendientes transversales del tema están en `TODO.md` en
la raíz del tema.)

### 5.1. Colecciones editables (preprocess → prop) — ✅ RESUELTO (v1.1.0 → v1.1.6)

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
- ✅ **semestres** (`ula_sem_card`) — migrada en v1.1.6. Entidad: `ct_programme_semester`
  (rich text + **logos multivalor** de Media; rediseño del componente con cajas de igual altura). Ver
  [`../../entities/programme-semester.md`](../../entities/programme-semester.md). El antiguo
  `subjects[]` se redacta ahora dentro de la descripción enriquecida.

> **✅ Las 8 colecciones de la home están migradas a editables (v1.1.0 → v1.1.6).** Todo el contenido
> de la home se gestiona desde nodos editables, vía el cargador genérico y el mecanismo
> preprocess → prop (ADR-002). El array de fábrica de cada colección permanece como respaldo
> (`|default`) si no hay nodos.

**Método:** se validó el patrón con un piloto (**universidades**, v1.1.0); con la segunda y tercera
colección (hero stats y why items, ambas vía `ct_programme_facts`, v1.1.1) se extrajo el **cargador
genérico** `_bootstrap_ula_lscm_get_collection()` (regla de tres, ver ADR-002). Las restantes
reutilizan ese genérico, ampliado con resolvers para rich text e imágenes de Media (singular y
multivalor). Dos colecciones (especializaciones y semestres) conllevaron además **rediseñar su
componente** (`ula_spec_card`, `ula_sem_card`).


### 5.2. Menú hamburguesa (móvil) — ✅ RESUELTO (v1.2.0)

La maqueta ocultaba los enlaces de navegación en móvil sin sustituirlos. **Resuelto en v1.2.0**:
se añadió al header una **hamburguesa** que despliega los enlaces de un menú de Drupal propio,
`home_header` (editable en el admin), dando acceso directo a las páginas reales del sitio. Convive
con las anclas internas de la landing. Toggle con **API nativa** (sin frameworks), accesible
(`aria-expanded`, cierre con Escape / clic fuera / al navegar). El detalle de gestión y la decisión
del menú propio están en §4.C y en el ADR-003 (§7).

La hamburguesa es visible en escritorio y móvil; en móvil (<600px), donde las anclas se ocultan, es
la navegación principal.

### 5.3. Pastillas interactivas de `ula_uni_card` — ✅ RESUELTO (Fase 4 completa: 4a v1.3.0, 4b v1.3.1)

Las pastillas (`tags`) de las tarjetas de universidad son `{label, info}`, alimentadas por la relación
universidad↔semestre. Fase 4 completa:

- ✅ **Sub-hito 4a — relación y pastillas visibles (v1.3.0).** Entidad de relación
  `ct_university_semester` (universidad × semestre + texto del modal) + campos de "Lead Partner" en la
  universidad. La carga del tema combina ambas fuentes y alimenta los `tags`. Ver ADR-004 (§7),
  `../../entities/university-semester.md`, `../../ARCHITECTURE.md` §5.6, guía de edición en §4
  §4.D.
- ✅ **Sub-hito 4b — interactividad (v1.3.1).** Las pastillas con `info` se renderizan como **botones**
  que abren un **modal** (`<dialog>` nativo, único y compartido, en el marco) con el contenido de
  `info`. API nativa, sin frameworks: `showModal()` (foco atrapado, Escape), más cierre por botón × y
  por clic en el backdrop. El contenido (rich text de Basic HTML) viaja en `data-modal-html` y el JS
  del marco lo vuelca en el `<dialog>`. Las pastillas sin `info` siguen siendo etiquetas estáticas.

> **Decisión modal vs popover.** Se eligió **modal** (`<dialog>`) y no popover porque el contenido de
> cada pastilla es de varios párrafos (más de una o dos frases); el modal aguanta bien texto extenso y
> centra la lectura, mientras que un popover se rompe con contenido largo. Ver ADR-004.


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
(universidades tiene `tags`/relación con semestre; especializaciones tiene `modules[]`; semestres tiene
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

### ADR-003 — Menú de la hamburguesa del header: menú de Drupal propio (`home_header`), no `main`

**Contexto.** Al cerrar el diseño de la home (v1.2.0) se añadió una **hamburguesa** en el header para
dar acceso directo a las páginas reales del sitio (no solo a las secciones-resumen de la landing, a
las que ya saltan las anclas internas hardcodeadas del nav). Los enlaces debían ser **configurables**
(las páginas del sitio existen y crecerán), no hardcodeados.

**Decisión.** La hamburguesa se alimenta de un **menú de Drupal propio**, `home_header` ("Home header
menu"), inicializado con los enlaces que entonces tenía el menú `main` (About, Contents, Elegibility,
Admission, Student Hub). El tema lee ese menú (`_bootstrap_ula_lscm_get_menu_links()`) y lo pasa como
prop `header_menu` al marco, que lo pinta; un JS nativo gestiona el toggle (accesible). Convive con
las anclas internas, que se mantienen.

**Alternativas consideradas.**
- *Reutilizar el menú `main` del sitio.* Descartada: el header de la home (anclas + hamburguesa) y el
  de las futuras páginas internas (navegación híbrida estándar) serán **funcionalmente distintos**;
  compartir el menú `main` los acoplaría, y un ajuste pensado para uno afectaría al otro. Un menú
  propio los desacopla.
- *Hardcodear los enlaces en el `.twig`.* Descartada: contradice el objetivo de contenido
  configurable; añadir una página obligaría a tocar código.
- *Integrar el menú principal de Drupal en todo el nav* (sustituyendo las anclas). Descartada: las
  anclas internas de la landing y la navegación de sitio tienen propósitos distintos y conviven mejor
  separadas.

**Consecuencias.**
- Añadir/quitar/reordenar enlaces de la hamburguesa se hace **desde el admin** (no toca código): cada
  página nueva → su enlace en `home_header` → aparece en la hamburguesa. Mecanismo de mantenimiento
  documentado en §4.C.
- `home_header` es **configuración** (vive en BD; red de seguridad: dump). El código que lo renderiza
  vive en git.
- **Coste asumido:** cuando se rehagan las páginas internas, si se quiere que home y páginas compartan
  enlaces habrá que mantener dos menús (`home_header` y `main`). Es el precio de la independencia
  buscada entre ambos headers.
- **Interactividad con API nativa**, sin frameworks (coherente con la independencia de Bootstrap
  Italia): toggle con `aria-expanded`, cierre con Escape / clic fuera / al navegar.

### ADR-004 — Relación universidad↔semestre: entidad de relación propia + "Lead Partner" como atributo

**Contexto.** Las tarjetas de universidad (`ula_uni_card`) muestran pastillas: semestres ("Semester
1", "Semester 2"…) y, en la universidad líder, "Lead Partner". Al pulsarlas mostrarán un modal cuyo
contenido, en el caso de los semestres, **depende de la combinación universidad × semestre** ("RTU en
el Semestre 3" dice algo distinto de "TH Wildau en el Semestre 3"). Había que modelar esa relación.

**Decisión.**
- Las **pastillas de semestre** se modelan con una **entidad de relación** propia,
  `ct_university_semester` (Sub-hito 4a, v1.3.0): cada nodo es un cruce universidad × semestre, con
  dos `entity_reference` (universidad → nodo; semestre → término de la taxonomía `semester`
  existente), una etiqueta de pastilla y el texto del modal. Ver `../../entities/university-semester.md`
  y el mecanismo en `../../ARCHITECTURE.md` §5.6.
- La pastilla **"Lead Partner"** NO es un semestre, sino un **atributo de la universidad**: se modela
  con `field_uni_is_lead` (boolean) + `field_uni_lead_modal_text` (Basic HTML) en
  `ct_about_consortium_university`. Etiqueta fija "Lead Partner". La tarjeta combina ambas fuentes.

**Alternativas consideradas.**
- *Campo de pastillas dentro de la universidad* (todas las pastillas como campo multivalor de la
  universidad). Descartada para los semestres: el dato quedaría atrapado en la universidad y solo
  serviría para una dirección de consulta. La relación universidad↔semestre tendrá **más de un
  consumidor** —las pastillas de la home ahora y la futura página **Consortium** ("qué hace cada
  universidad en cada semestre")—, y una entidad de relación se consulta desde cualquier ángulo.
- *Apoyar las pastillas en la taxonomía `semester`* (añadiéndole campos). Descartada: esa taxonomía
  tiene su propio propósito (agrupar las asignaturas) y no debe alterarse; el texto del modal no es un
  atributo del semestre, sino del cruce.
- *Meter "Lead Partner" en la entidad de relación* (con el semestre opcional). Descartada: "Lead
  Partner" no es un semestre; forzarlo ensuciaría la relación, que debe quedar **pura** (solo
  semestres) para que Consortium la consuma bien. Es un rol de la universidad → vive en la universidad.

**Granularidad de las pastillas 3º/4º.** La maqueta agrupaba "Semester 3 & 4 (option)". Se decidió
**una pastilla por semestre individual** (Semester 3, Semester 4 por separado), porque la página
Consortium tratará 3º y 4º como semestres distintos (con su propio contenido). La opcionalidad
(elección RTU vs TH Wildau) se explica en el texto del modal, no en la etiqueta.

**Consecuencias.**
- Añadir/editar pastillas de semestre = crear/editar nodos `ct_university_semester` en el admin (sin
  tocar código). La de "Lead Partner" = marcar el booleano en la universidad. Guía para editores en §4
  §4.D.
- La relación es **configuración/contenido** (BD; red de seguridad: dump). El código que la combina y
  pinta vive en git.
- La taxonomía `semester` se **referencia sin alterarse** (solo se lee); mantiene su uso por las
  asignaturas.
- **Unicidad del líder** ("solo una universidad"): la garantiza el editor (marcar el booleano en una
  sola), no se fuerza a nivel de datos — innecesario para 3 universidades.
- **Sub-hitos:** 4a (v1.3.0) creó la relación, los campos de lead y mostró las pastillas (estáticas).
  4b (v1.3.1) implementó la interactividad: las pastillas con `info` son botones que abren un **modal**
  (`<dialog>` nativo único en el marco), con cierre por ×, Escape y clic en backdrop. Se eligió modal
  (no popover) por la extensión del contenido. El contenido (HTML de Basic HTML) viaja en
  `data-modal-html` y el JS del marco lo vuelca con `innerHTML` (seguro: HTML ya saneado). **Fase 4
  completa.**
