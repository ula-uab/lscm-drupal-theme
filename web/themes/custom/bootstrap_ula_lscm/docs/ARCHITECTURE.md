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
- **MENOR**: nuevas funcionalidades o nuevos elementos del tema (p.ej. una nueva sección, las colecciones editables → incremento menor).
- **PARCHE**: correcciones y ajustes menores.

**Cualquier cambio en cualquier elemento del tema** (la home u otros que se desarrollen) se
registra aquí, subiendo la versión del tema según el criterio de arriba. Esta es la **única
tabla de versionado** del proyecto; los documentos de elemento no llevan versionado propio,
sino que referencian la versión del tema en la que se introdujo o modificó cada cosa.

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0.0 | 2026-06-11 | Primera versión con identidad y versionado propios. Design system `ula_*` (8 componentes + tokens + base CSS en tres capas). Elemento **home**: marco `lscm-master-page`, servido como nodo `landing` con plantillas dedicadas (`page--front`, `node--landing`) y textos editables desde el admin. Documentación reorganizada en dos niveles (tema / elementos). |

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

## 5. Notas técnicas y restricciones del entorno

Esta sección documenta restricciones del entorno y comportamientos no evidentes de Drupal /
UI Patterns que condicionan cómo se construye y mantiene este tema. No son anécdotas: cada una
afecta a decisiones concretas y a cómo deben hacerse las ampliaciones futuras. Aplican a
**todos** los elementos del tema.

### 5.1. Sitio sin gestión de configuración (config/sync)

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

### 5.2. Crear campos por código requiere tres pasos, no uno

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

### 5.3. Límite de longitud en props de texto (UI Patterns / campos string)

Los campos de tipo `string` (texto plano) tienen un límite por defecto de **128 caracteres**.
Los textos largos (p.ej. las descripciones de la home) superan ese límite, lo que provoca un
error al guardar ("cannot be longer than 128 characters").

- En el `.component.yml` del componente, las props de texto largo deben declarar `maxLength`
  amplio (en la home, las descripciones del marco usan `maxLength: 1000`).
- Los **campos** de texto largo se crean como `string_long` (texto largo), no `string`.
- Al añadir nuevas props/campos de texto extenso, aplicar el mismo criterio.

### 5.4. `default` de SDC no se inyecta de forma fiable en runtime

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

### 5.5. `position: fixed` y entornos de previsualización

Un elemento `position: fixed` (p.ej. una barra de navegación fija) se ancla a la **ventana del
navegador**, no a su contenedor. Consecuencias observadas:

- En la **galería de UI Patterns** (`/admin/appearance/ui/components`), un nav fijo se solapa con
  la barra de administración → la galería **no sirve** para validar páginas completas con
  elementos fijos; sirve para componentes sueltos.
- Incrustado como bloque dentro de la plantilla del tema base, un nav fijo choca con el header
  heredado.
- **Por eso** los elementos que son páginas completas con navegación fija (como la home) se
  sirven con su propia plantilla de página, sin el chrome del tema base.

### 5.6. Método de trabajo recomendado

- **Validar la tubería completa con un caso mínimo** antes de replicar a escala (en la home se
  validó la editabilidad con un solo campo antes de crear los 42; se validará una colección
  piloto antes de migrar las 8).
- **Dump de BD antes de cada cambio de configuración.**
- **Consolidar en git por hito**, y verificar que el repositorio y el entorno de trabajo
  coinciden tras cada push.
- **Preferir el método menos invasivo primero**; evitar operaciones globales de configuración.

---

## 6. Pendientes transversales del tema

Los pendientes que afectan a todo el tema están en **`TODO.md`** (raíz del tema): avisos de
obsolescencia de Gutenberg en la salida de drush, actualización de seguridad de Drupal, errores
de renderizado en la galería de UI Patterns, y la valoración de adoptar gestión de configuración
(config/sync).

Los pendientes específicos de un elemento están en el documento de ese elemento (p.ej. los de la
home, en `docs/elements/home/HOME-ARCHITECTURE.md`).

---

## 7. Estructura de ficheros del tema

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
├── templates/
│   ├── layout/page--front.html.twig     # Portada (elemento home)
│   └── content/node--landing.html.twig  # Render del nodo landing (elemento home)
└── docs/
    ├── README.md                        # Índice de la documentación
    ├── ARCHITECTURE.md                  # Este documento (nivel tema)
    └── elements/
        └── home/
            └── HOME-ARCHITECTURE.md     # Documentación del elemento "home"
```

> Los **scripts de configuración** están en `scripts/` (raíz del proyecto, no del tema):
> `crear-campos-landing.php`, `anadir-campos-formdisplay.php`, `ordenar-campos-landing.php`.
> Crean y ordenan los campos del tipo `landing`; se conservan como referencia reproducible, ya
> que la configuración no está en git (§5.1).

> La documentación de cada **elemento** del tema (la home, y las secciones que se desarrollen en
> el futuro) vive en `docs/elements/<elemento>/`. Este documento (nivel tema) cubre lo común a
> todos ellos.
