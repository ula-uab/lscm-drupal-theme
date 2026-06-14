# Bootstrap ULA LSCM — Arquitectura del tema

> Tema Drupal 11 para el **máster europeo conjunto LSCM** (Logistics & Supply Chain Management).
> Repositorio: https://github.com/ula-uab/lscm-drupal-theme (rama `main`).
> Machine name: `bootstrap_ula_lscm`.

Este documento describe la **arquitectura global del tema**: su design system, sus
convenciones y las restricciones del entorno. La documentación de cada elemento concreto del
tema (p.ej. la home) vive en `docs/elements/<elemento>/` y referencia a este documento para
todo lo que es común a varios elementos.

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
- **Conviene evitar meter configuración pesada en BD.** Por eso se descartó Layout Builder
  (ver el documento de la home): habría añadido configuración compleja a una BD que no se
  versiona, haciendo el sitio más frágil de reproducir. Se prefieren mecanismos que vivan en
  código (plantillas Twig en el tema).
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
├── TODO.md                              # Pendientes transversales del tema
├── css/
│   ├── ula-tokens.css                   # Capa 1: variables globales
│   └── ula-landing-base.css             # Capa 2: base de estilos
├── components/
│   ├── ula_hero_stat/  ula_why_item/  ula_feature_item/  ula_req_card/
│   ├── ula_spec_card/  ula_sem_card/  ula_timeline_item/  ula_uni_card/   # Design system (§3)
│   ├── lscm-master-page/                # Marco de la home (ver doc del elemento home)
│   └── lscm-master-static/              # Maqueta original de referencia (no en producción)
├── templates/                           # Plantillas Twig, organizadas en subcarpetas por tipo
│   ├── layout/                          # Plantillas de página/región (page--*, html, region--*)
│   │   └── page--front.html.twig        # Portada (elemento home)
│   └── content/                         # Plantillas de entidad (node--*, etc.)
│       └── node--landing.html.twig      # Render del nodo landing (elemento home)
└── docs/
    ├── README.md                        # Índice de la documentación
    ├── ARCHITECTURE.md                  # Este documento (nivel tema)
    ├── analysis/                        # Hallazgos de investigación (secciones existentes a rehacer)
    │   └── about-and-university-entity.md
    ├── entities/                        # Diseño de entidades propias del tema (no heredadas)
    │   └── programme-facts.md
    ├── elements/                        # Documentación de referencia por elemento
    │   └── home/
    │       └── HOME-ARCHITECTURE.md     # Documentación del elemento "home"
    └── plans/                           # Planes de desarrollo por fases, por elemento
        └── home/
            ├── plan-colecciones-editables-e-interactividad.md   # Plan activo de la home
            └── archive/
                └── plan-landing-parametrizada.md                # Plan histórico (completado)
```

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

> Los **scripts de configuración** están en `scripts/` (raíz del proyecto, no del tema):
> `crear-campos-landing.php`, `anadir-campos-formdisplay.php`, `ordenar-campos-landing.php`.
> Crean y ordenan los campos del tipo `landing`; se conservan como referencia reproducible, ya
> que la configuración no está en git (§6.1).

> La documentación de cada **elemento** del tema (la home, y las secciones que se desarrollen en
> el futuro) vive en `docs/elements/<elemento>/`. Este documento (nivel tema) cubre lo común a
> todos ellos.
