# Entidad — `ct_faculty_member` (Faculty member)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** hito *Faculty & Research* (Fase 1 — contenido). **No supone cambio de versión del
> tema:** es **configuración + contenido** y vive en la base de datos, no en el repositorio (ver
> `../ARCHITECTURE.md`, separación de fuentes de verdad). · **Naturaleza:** **tipo de contenido**
> (nodo). · **Mecanismo de consumo (visualización):** **pendiente de la Fase 2** del hito (vista +
> componente de tarjeta + carrusel en `/about`); este documento describe el **modelo de datos** ya
> construido y validado, no su presentación, que aún no existe.

---

## 1. Qué es y por qué existe

`ct_faculty_member` modela a un **miembro del profesorado** del máster LSCM: su identidad académica
(nombre, título académico, posición, roles en el programa), su adscripción institucional, sus áreas de
aplicación y competencias (taxonomías), sus enlaces (web personal, LinkedIn, perfiles de investigación)
y datos de contacto, más un peso de orden y un indicador de actividad docente. Cada nodo es **un
profesor**.

Alimenta la sección **Faculty & Research** de la página `/about` (en la maqueta, la rejilla `.faculty-grid`
de tarjetas «foto + nombre + rol»). El criterio de validación del hito es mostrar a los miembros del
faculty como **carrusel de tarjetas** en `/about`; esa presentación es trabajo de la Fase 2.

Se nombró `ct_faculty_member` siguiendo la convención `ct_*` del sitio. Los campos llevan el prefijo
`field_ct_fcltmb_*` (contracción de «faculty member»), coherente con el patrón observado en otras
entidades (p. ej. `ct_contents_subject` usa `field_ct_ctssbj_*`). El prefijo está condicionado por el
**límite de 32 caracteres** del machine name de campo en Drupal: por eso algunos nombres van abreviados
(`app_areas` en vez de `application_areas`, `research_prof` en vez de `research_profiles`).

**Relación con entidades heredadas.** Dos campos referencian entidades que **no** diseñamos nosotros y
que, si se documentan, pertenecen a `analysis/`:
- `courses` → nodos `ct_contents_subject` (ver `../analysis/contents-subject-entity.md`).
- `affil_internal` → nodos `ct_about_consortium_university` (ver `../analysis/about-and-university-entity.md`).

---

## 2. Campos (tipo de contenido `ct_faculty_member`)

| Campo | Tipo | Card. | Requerido | Para qué |
|---|---|---|---|---|
| `title` (base, relabelado a **«Full name»**) | string | 1 | **sí** | Nombre completo del profesor. Reutiliza el título nativo del nodo. |
| `field_ct_fcltmb_academic_title` | string | 1 | no | Título académico («Prof. Dr.-Ing.», «PhD», «Dr.»). |
| `field_ct_fcltmb_positions` | list (text) | N | **sí** | Rango de empleo. Valores permitidos cerrados (ver §2.1). |
| `field_ct_fcltmb_roles` | list (text) | N | **sí** | Funciones en el programa. Valores permitidos cerrados (ver §2.1). |
| `field_ct_fcltmb_affil_type` | boolean | 1 | **sí** | Tipo de adscripción: **Internal** (1) / **External** (0). Widget de **radios** (ver §2.2). |
| `field_ct_fcltmb_affil_internal` | entity ref → node `ct_about_consortium_university` | 1 | no | Institución del consorcio (solo si interna). |
| `field_ct_fcltmb_affil_external` | string | 1 | no | Nombre de institución en texto libre (solo si externa). |
| `field_ct_fcltmb_department` | string | 1 | no | Departamento / facultad. Texto libre. |
| `field_ct_fcltmb_photo` | entity ref → media (imagen) | 1 | no | Retrato. Opcional. |
| `field_ct_fcltmb_bio` | text (formatted, long) | 1 | no | Biografía breve. Formato **Basic HTML** (sin clases de Bootstrap Italia). |
| `field_ct_fcltmb_app_areas` | entity ref → taxonomy `tx_application_area` | N | no | Áreas de aplicación / dominios. (Vocabulario, ver §3.) |
| `field_ct_fcltmb_expertise` | entity ref → taxonomy `tx_expertise` | N | no | Competencias / métodos / disciplinas. (Vocabulario, ver §3.) |
| `field_ct_fcltmb_courses` | entity ref → node `ct_contents_subject` | N | no | Asignaturas/módulos que imparte. Reutiliza entidad heredada. |
| `field_ct_fcltmb_linkedin` | link | 1 | no | Perfil de LinkedIn. Sin título de enlace. |
| `field_ct_fcltmb_email` | email | 1 | no | Correo de contacto (tipo Email con validación). |
| `field_ct_fcltmb_website` | link | 1 | no | Web personal/institucional. Sin título de enlace. |
| `field_ct_fcltmb_location` | string | 1 | no | Ciudad / país. |
| `field_ct_fcltmb_research_prof` | link | N | no | Perfiles de investigación. El **nombre del proveedor va en el título del enlace** (ORCID / Google Scholar / Scopus). (Ver §2.3.) |
| `field_ct_fcltmb_priority` | integer | 1 | no | Peso de orden manual (mayor = más prominente). (Ver §2.4.) |
| `field_ct_fcltmb_active` | boolean | 1 | no | ¿Imparte actualmente? **Por defecto: true**. Semántica distinta de «Publicado» (ver §2.5). |

### 2.1. Valores permitidos de `positions` y `roles`

Ambos son **List (text)** (`list_string`): conjuntos cerrados cuyos valores viven en la config del campo.
La **clave** (estable) se guarda en BD; la **etiqueta** se muestra al editor. Son listas canónicas
construidas y validadas durante el hito (su fuente de verdad es la propia BD).

**Positions** (rango de empleo):

| value | label |
|---|---|
| professor | Professor |
| associate_professor | Associate Professor |
| assistant_professor | Assistant Professor |
| lecturer | Lecturer |
| research_fellow | Research Fellow |
| visiting_professor | Visiting Professor |
| industry_expert | Industry Expert |

**Roles** (función en el programa):

| value | label |
|---|---|
| programme_director | Programme Director |
| steering_committee_member | Steering Committee Member |
| academic_coordinator | Academic Coordinator |
| researcher | Researcher |
| course_instructor | Course Instructor |
| thesis_supervisor | Thesis Supervisor |
| teaching_assistant | Teaching Assistant |

### 2.2. `affil_type` como booleano con widget de radios (decisión)

La adscripción se modela en **tres campos** (`affil_type` + `affil_internal` + `affil_external`) porque un
solo campo no captura «interno con referencia a entidad / externo con texto libre». El tipo es un
**booleano** (Internal = on/1, External = off/0), pero se presenta con el **widget de radios**
(`options_buttons`), no con la casilla única. El motivo es real: un booleano **obligatorio** con casilla
única obligaría a marcarla siempre (= siempre Internal); con radios, «obligatorio» fuerza a **elegir uno
de los dos**. Que el editor rellene «solo el campo que corresponde» según el tipo es **disciplina de
edición**, no algo que el esquema fuerce por sí solo.

### 2.3. `research_prof` como Link multivalor (decisión)

Los perfiles de investigación se modelan como **un único campo Link multivalor**, no como tres campos
discretos. Cada *delta* es un enlace y el **nombre del proveedor se lleva en el título del enlace**
(«ORCID», «Google Scholar», «Scopus»). Es el mismo patrón homogéneo que las CTAs del hero (un campo Link
repetido), frente a un objeto anidado —que Drupal no soporta dentro del nodo—. Contrapartida asumida: la
identidad del proveedor es **dato** (título del enlace), no esquema; la presentación (icono por proveedor)
deberá deducirla en la Fase 2 a partir del título o del dominio.

### 2.4. `priority` (peso de orden manual)

Entero que se fija a mano por nodo (mayor = más prominente). En la descripción del campo se recogen, **como
pauta no vinculante** (sin equivalencia a ninguna unidad): 100 Programme Director · 95 (co)directores de
universidades socias · 90 núcleo · 80 afiliados · 70 visitantes.

### 2.5. `active` vs «Publicado»

`active` indica si el profesor **imparte actualmente** en el programa; es **independiente** del estado
publicado/no publicado del nodo. Un profesor puede estar publicado (visible) y a la vez `active = false`
(ha impartido en el pasado). Por eso son dos campos distintos.

---

## 3. Vocabularios asociados (entidades propias)

La entidad se apoya en **dos vocabularios de taxonomía propios**, creados en este hito. Se documentan aquí
por nacer ligados a `ct_faculty_member` (sus listas canónicas son su contenido). Son **planos** (sin
jerarquía) y **disjuntos** entre sí (ningún término se repite entre los dos), distinción decidida durante
la curación.

| Vocabulario | Machine name | Términos | Campo que lo usa | Concepto |
|---|---|---|---|---|
| Application areas | `tx_application_area` | 50 | `field_ct_fcltmb_app_areas` | **Dominios de aplicación / investigación** (p. ej. «Unmanned Traffic Management», «Logistics»). |
| Expertise | `tx_expertise` | 22 | `field_ct_fcltmb_expertise` | **Métodos, disciplinas y competencias científicas** (p. ej. «Optimization», «Machine Learning»). |

**Distinción entre ambos** (criterio que guió la separación): la *expertise* describe el **conocimiento**
del profesor (p. ej. optimización matemática); el *application area* describe el **dominio donde lo
aplica** (p. ej. aviación no tripulada). Por eso son dos ejes distintos y disjuntos.

**Procedencia de las listas canónicas.** Los términos no son una copia literal de lo declarado en los
datos de origen: se obtuvieron **depurando** los valores brutos (eliminación de duplicados, fusión de
variantes singular/plural, homogeneización de estilo «&» vs «and», desarrollo de siglas, y exclusión de
entradas espurias como nombres de instituciones). El resultado es la lista canónica que se cargó en la BD.

**Mapeo de los datos de origen a los términos canónicos.** Al poblar los nodos, los valores brutos de cada
profesor se reclasificaron contra estas listas mediante un **conjunto cerrado de transformaciones**
(siglas↔desarrollado, «and»↔«&», mayúsculas/espacios, singular/plural); lo que no casaba por esas reglas
quedó sin asignar. El mismo enfoque cerrado se aplicó a `positions`/`roles` (coincidencia exacta por
`label`, insensible a mayúsculas y con *trim*).

---

## 4. Cómo se consume (lógica en el tema)

La entidad tiene **dos presentaciones**, ambas **construidas y validadas**. La **página de detalle** (todos
los campos) se documenta en §4.1. La **tarjeta** para el carrusel de la sección Faculty & Research de
`/about` (un subconjunto de campos, vía Views → UI Patterns) se documenta en §4.2.

### 4.1. Página de detalle (construida)

**Mecanismo elegido: plantilla de nodo + componente SDC** (frente a Layout Builder por *bundle* o a una
vista). Es lo nativo para «mostrar un nodo», da control total anti-BI y reaprovecha la disciplina ya
validada en `cta_band`/`section_header` (plantilla que compone un SDC con **valor crudo**). La página
canónica del nodo (view mode `full`) se renderiza así, sin atravesar `field.html.twig` (que en este subtema
sirve Bootstrap Italia).

Piezas:
- **Componente** `ula_faculty_detail` (SDC **bespoke**, por **props**; ver `../COMPONENTS.md` §5.1): pinta
  todo el bloque main content de la ficha. A diferencia de los SDC genéricos por slots, recibe datos
  **estructurados** (arrays de etiquetas, chips, `{title,url}`, `{label,url}`, objeto de afiliación), porque
  lo alimenta una plantilla + preprocess dedicados (no Views → UI Patterns).
- **Plantilla** `templates/content/node--ct-faculty-member--full.html.twig`: fina; solo compone el SDC con la
  variable `faculty` (`with_context = false`). Acotada al view mode `full` para no interferir con otras
  presentaciones (p. ej. la futura tarjeta).
- **Preprocess** `bootstrap_ula_lscm_preprocess_node__ct_faculty_member` (en el `.theme`): prepara `faculty`
  con **valores crudos**, reutilizando/añadiendo helpers: `_text_value` (bio, HTML saneado por
  `check_markup`), `_media_image_url` (foto), `_list_labels` (clave→etiqueta de positions/roles),
  `_term_names` (taxonomías), `_node_refs` (courses → `{title,url}`), `_link_uri` (website/linkedin) y
  `_link_list` (research profiles → `{label,url}`). **Guards `isEmpty`** en todos los campos opcionales (la
  lección de `section_header`: acceder a `.value` de un campo vacío rompe el render).
- **Afiliación ramificada**: si hay referencia interna (`affil_internal`) se usa (nombre + URL del nodo de
  universidad del consorcio); si no, el texto externo (`affil_external`), sin enlace.
- **Sin foto**: cuando `photo` está vacío (estado actual de los 10 nodos), el componente pinta un retrato de
  **iniciales** (calculadas en `_initials`).

URL y navegación:
- **URL legible** vía **Pathauto**: patrón `/faculty/[node:title]` acotado a `ct_faculty_member` (módulos
  `pathauto` + `ctools`, instalados en este hito; `token` ya estaba). El patrón y los alias son
  **configuración en BD** (no git).
- **Fuera del menú**: la página existe por su URL pero no se añade a ningún menú; se alcanzará desde los
  enlaces de las tarjetas (§4.2).
- **Cabecera de Drupal oculta**: `bootstrap_ula_lscm_preprocess_page` oculta el bloque `page_title` y el
  breadcrumb para `ct_faculty_member` (el `<h1>` de la ficha hace de cabecera), igual que para las páginas de
  Layout Builder.

Fondo: la ficha va sobre **fondo blanco** del marco. Se evaluó un lienzo `--off-white` (full-bleed en el
componente) para resaltar las tarjetas, pero se **descartó** por la discontinuidad blanca con el footer;
recuperar ese efecto, si se quiere, debe hacerse a **nivel de marco** (pendiente transversal), no desde el
componente.

### 4.2. Tarjeta + carrusel en `/about` (construida)

**Mecanismo elegido: Views → UI Patterns** (el flujo transversal documentado en
`../elements/layout/CONTENT-LAYOUT.md` §5), a diferencia de la página de detalle (§4.1, plantilla + SDC por
props). Aquí el contenido lo selecciona una **vista** y lo pinta un **componente por slots**, porque es una
**colección** de profesores embebida en el Layout Builder de `/about`, no un nodo individual. La receta
genérica vive en `CONTENT-LAYOUT.md` §5; aquí se documenta la **instancia concreta** de Faculty y las
decisiones propias.

**La vista `faculty_cards`** (configuración en BD, no git). Lista los nodos `ct_faculty_member` y los pinta
como tarjetas en un carrusel:
- **Base**: Content (nodo). **Displays**: `default` + `block_1` (display de **bloque**, el que se embebe en
  Layout Builder).
- **Filtros**: `status = 1` (publicado) y `type = ct_faculty_member`.
- **Orden**: `field_ct_fcltmb_priority` en **DESC** — **intencional**: la prioridad es un **peso**, el de
  número más alto va primero (100, luego 99, 98…). No es un error a "corregir" a ASC.
- **Pager**: `none` (muestra **todos** los nodos; el carrusel los pagina visualmente, no la vista).
- **Relación** (`Advanced → Relationships`): sobre `field_ct_fcltmb_affil_internal` hacia el nodo de
  universidad, marcada **NO requerida** (`required: false`, *left join*). Es lo que permite traer el
  **acrónimo** desde el nodo universidad **sin perder** los profesores que no tienen afiliación interna (ver
  `CONTENT-LAYOUT.md` §5.11). Si fuese requerida, el preview se vaciaría (hoy los 10 son externos).

**Campos de la vista y su mapeo a los slots de la tarjeta** (todos con la etiqueta desactivada; todos
alimentan el slot vía `view_field`):

| Campo en la vista | Configuración relevante | Slot de `ula_faculty_card` |
|---|---|---|
| `title` | *Link to the original entity* (enlaza a la ficha) | `name` |
| `field_ct_fcltmb_academic_title` | — | `academic_title` |
| `field_ct_fcltmb_positions` | 1 valor desde el 0 (la posición principal) | `position` |
| `field_uni_abbr` | **vía la relación** (acrónimo del nodo universidad) | `affiliation` (fuente 1) |
| `field_ct_fcltmb_affil_external` | texto externo | `affiliation` (fuente 2) |
| `field_ct_fcltmb_expertise` | 3 valores desde el 0, sin separador, sin enlazar | `expertise` |
| `field_ct_fcltmb_photo` | **formatter `media_thumbnail`** + image style `medium`, *Link* = *Nothing* | `image` |
| **«Link to Content»** (`view_node`) | *Text to display* = «View profile» | `link` |

Dos decisiones que se salen del patrón base de `consortium_universities` y que conviene resaltar (ambas
documentadas como receta genérica en `CONTENT-LAYOUT.md`):
- **`affiliation` con dos fuentes** (acrónimo interno + texto externo, mutuamente excluyentes por nodo): UI
  Patterns las concatena por peso y, como en cada nodo solo una tiene valor, el slot pinta la correcta (ver
  `CONTENT-LAYOUT.md` §5.10).
- **El botón usa «Link to Content»**, no `title` con `link_to_entity` + texto reescrito: ese combinado pierde
  el `<a>` y deja texto plano. «Link to Content» emite el `<a href="/faculty/…">View profile</a>` ya hecho
  (ver `CONTENT-LAYOUT.md` §5.9). El slot `expertise_more` («+N») queda **sin alimentar** (no es directo en
  Views; pendiente).

**La foto, anti-BI.** El campo `field_ct_fcltmb_photo` es una **referencia a media**; se usa el formatter
**`media_thumbnail`** (con image style `medium` y sin enlace), que emite **solo la `<img>`**, en vez de
«Rendered entity», que renderizaría la entidad media con plantillas de **Bootstrap Italia**. El recorte
circular (84px) lo aporta el CSS del componente (ver `CONTENT-LAYOUT.md` §5.4).

**Los componentes** (código, versionado en el repo):
- **Nivel 1 — `ula_carousel`** (contenedor; ver `../COMPONENTS.md` §1.6): es el *Format/Style* de la vista,
  con el slot `content` ← `view_rows`, prop `visible = 3` y `label = «Faculty & Research»`. Pagina las
  tarjetas (flechas, puntos, swipe; sin autoplay).
- **Nivel 2 — `ula_faculty_card`** (tarjeta; ver `../COMPONENTS.md` §2.5): es el *Row* de la vista, con sus
  slots alimentados según la tabla de arriba. Slot-based, anti-BI; si no hay foto pinta un retrato de
  **iniciales** calculadas del nombre (con el guard de presencia de `CONTENT-LAYOUT.md` §5.8).

**Inserción en `/about`.** El display de bloque `faculty_cards:block_1` se añade a la sección **Faculty &
Research** del Layout Builder de `/about` (operación de **configuración en BD**, con **dump previo**). El
contenido heredado que dependía de Bootstrap Italia en esa sección, si lo hubiera, se sustituye/elimina como
operación aparte (su propio análisis de qué se pierde), no en el mismo paso que la inserción.

---

## 5. Contenido actual

Se crearon **10 nodos** (nid 95–104), todos **publicados**, mediante un **script de un solo uso** (no
versionado) que combinó los datos de origen con el mapeo curado de taxonomías y de positions/roles.

| nid | Full name | positions | roles |
|---|---|---|---|
| 95 | Juan José Ramos González | Associate Professor | Programme Director; Steering Committee Member; Course Instructor |
| 96 | Miquel Àngel Piera Eroles | Professor | Course Instructor |
| 97 | Jose Luis Muñoz Gamarra | Lecturer | Course Instructor |
| 98 | Laura Calvet Liñán | Associate Professor | Course Instructor |
| 99 | Ane Elixabete Ripoll Zarraga | Lecturer | Course Instructor |
| 100 | Gaby Neumann | Professor | Steering Committee Member; Academic Coordinator; Course Instructor |
| 101 | Jens Gerd Wollenweber | Professor | Course Instructor |
| 102 | Andrejs Romānovs | Associate Professor | Steering Committee Member; Academic Coordinator; Course Instructor |
| 103 | Yuri Merkuryev | Professor | Course Instructor |
| 104 | Jana Bikovska | Assistant Professor | Academic Coordinator; Course Instructor |

**Campos dejados vacíos a propósito en la carga inicial**, para corrección manual posterior sobre los 10
nodos (decisión del hito, por ser solo 10):
- `affil_type` se fijó a **External** en los 10 y `affil_internal` / `affil_external` quedaron **vacíos**.
- `field_ct_fcltmb_photo` quedó **vacío** en la carga inicial (los datos de origen no traían imágenes
  utilizables). **Posteriormente** se cargó la foto del nodo **95** (Juan José Ramos González); el resto sigue
  sin foto y se pinta con el retrato de **iniciales** de la tarjeta/ficha. Sirve además de caso real para
  validar las dos ramas del retrato (foto vs iniciales) en la tarjeta de `/about`.
- `field_ct_fcltmb_courses` quedó **vacío** (requiere resolver cada asignatura a un nodo existente).

El resto de campos (academic title, department, email, location, priority, active, bio, enlaces, perfiles
de investigación, áreas de aplicación y expertise) se cargaron desde los datos de origen.

---

## 6. Notas de fuentes de verdad

> **Configuración y contenido en BD, no en git.** El tipo de contenido `ct_faculty_member`, sus 20 campos,
> los dos vocabularios y los 10 nodos son **configuración/contenido**: viven en la base de datos, no en el
> repositorio (ver `../ARCHITECTURE.md`). El **código** de ambas presentaciones **sí** se versiona en el repo:
> la **página de detalle** (componente `ula_faculty_detail`, plantilla `node--ct-faculty-member--full` y el
> preprocess del `.theme`) y la **tarjeta/carrusel** de `/about` (componentes `ula_faculty_card` y
> `ula_carousel`). En cambio, la **vista `faculty_cards`** y su **inserción** en el Layout Builder de `/about`
> son **configuración** (BD), no git: viajan por el **dump**. Los scripts de creación (content type, términos
> y nodos) son **de un solo uso** y **no se versionan**. Cualquier operación sobre esta configuración exige
> **dump previo** de la BD.
