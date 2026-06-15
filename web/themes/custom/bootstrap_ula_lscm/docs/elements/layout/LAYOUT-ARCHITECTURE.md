# Elemento: Layout (marco compartido de páginas) — Arquitectura

> **Nivel:** elemento (específico de una parte del sitio). Documenta el **marco compartido** —header y
> footer— que envuelve las **páginas de contenido** del sitio (no la home). Es un elemento
> **transversal**: aunque lo comparten todas las páginas de contenido, tiene entidad propia y se
> documenta aquí, referenciado desde `../../ARCHITECTURE.md`.
>
> **Relación con la home.** La home tiene su propio marco (`lscm-master-page`, documentado en
> `../home/HOME-ARCHITECTURE.md`) por ser una portada autónoma a medida. El marco de las páginas de
> contenido es **distinto** (otro header, otra navegación), aunque comparte la **estética**. La
> unificación de ambos footers está prevista como hito futuro (ver §4 y el plan de páginas de
> contenido, Fase 6).

---

## 1. Qué es y para qué sirve

El **marco** es el "esqueleto" visual común de las páginas de contenido: una **cabecera (header)**
arriba, el **contenido** de la página en medio, y un **pie (footer)** abajo. Su objetivo es que todas
las páginas de contenido compartan header y footer **sin reimplementarlos página a página**, evitando
duplicación y divergencias, y con una estética **independiente de Bootstrap Italia** (la del design
system propio `ula_*`).

El marco se introdujo en la **Fase 1** del plan de páginas de contenido
(`../../plans/paginas-contenido/plan-sistema-paginas-contenido.md`), como prerrequisito de la
migración de páginas hacia la independencia de Bootstrap Italia. La primera página que lo adopta es
**About** (`/about`).

---

## 2. Piezas del marco

El marco se compone de dos **componentes SDC propios** (prefijo `lscm_`, por ser piezas de
**estructura de página**, no del design system de componentes de contenido `ula_*`), más una
**plantilla de página** que los ensambla y una función de **preprocess** que les inyecta los datos.

### 2.1. Componente `lscm_page_header`

Cabecera de las páginas de contenido. Estética del header de la home (barra azul fija con borde
inferior amarillo, logo + marca), pero con **navegación de sitio estándar**: una barra de enlaces a
las páginas del sitio, alimentada por el menú de Drupal **`main`**. **No** incluye el menú híbrido de
anclas + hamburguesa de la home (ver ADR-LAYOUT-002 y, en la home, ADR-003).

- Ubicación: `components/lscm_page_header/` (`.component.yml`, `.twig`, `.css`).
- Props: `logo_url`, `brand_top`, `brand_sub`, `menu_links` (array de `{title, url}`), `active_url`
  (para marcar el enlace de la página actual).
- El CSS reutiliza los tokens globales `ula_tokens` y se autocarga por convención SDC.

### 2.2. Componente `lscm_page_footer`

Pie de página **provisional** de las páginas de contenido. Replica la **estructura** del footer de la
home (marca con descripción + tres columnas de enlaces —Programme, Resources, Partners— + zona
inferior con copyright y badge de la UE), pero con **contenido hardcodeado** por defecto en el propio
componente. Hacerlo **editable desde la interfaz** y **unificarlo** con el footer de la home es un
hito futuro (Fase 6 del plan; ver §4).

- Ubicación: `components/lscm_page_footer/` (`.component.yml`, `.twig`, `.css`).
- Props: `brand_top`, `contact_email` (permiten sobrescribir la marca y el correo; el resto del
  contenido es por defecto).

### 2.3. Plantilla de página `page--about.html.twig`

Plantilla que **monta el marco** para la página About: incluye `lscm_page_header`, luego el contenido
(`{{ page.content }}` —servido por la vista de la página— más `page.highlighted` para los mensajes del
sistema), y luego `lscm_page_footer`. Captura **solo** `/about` (ver ADR-LAYOUT-001).

- Ubicación: `templates/layout/page--about.html.twig`.
- Incluye los componentes con `include('bootstrap_ula_lscm:<componente>', {...}, with_context = false)`.

### 2.4. Inyección de datos: `bootstrap_ula_lscm_preprocess_page()`

En `bootstrap_ula_lscm.theme`. Inyecta las variables que la plantilla pasa a los componentes
(`header_logo_url`, `header_brand_top`, `header_brand_sub`, `header_menu_links`, `header_active_url`,
`footer_brand_top`, `footer_contact_email`), **solo** en las rutas de las páginas que adoptan el marco
(de momento `view.page_about.page_1`). La navegación se obtiene del menú `main` con la función
reutilizable `_bootstrap_ula_lscm_get_menu_links('main')` (la misma que usa la hamburguesa de la
home). La marca usa los mismos valores de fábrica que la home, por coherencia estética.

> **Mecanismo:** preprocess → prop, el mismo patrón que la home (ver ADR-002 en
> `../home/HOME-ARCHITECTURE.md`): el `.theme` carga los datos y la plantilla los pasa como props a los
> componentes, que los pintan.

---

## 3. Cómo se adhiere una página al marco (mientras dure la transición)

Mientras conviven páginas nuevas (sin BI) y heredadas (con BI), cada página de contenido adopta el
marco **individualmente** (Opción B, página a página; ver ADR-LAYOUT-001). Para una página servida por
una vista en la ruta `/<path>`:

1. Crear `templates/layout/page--<path>.html.twig` montando el marco (como `page--about.html.twig`).
2. Añadir la ruta de esa página al array `$framed_routes` de
   `bootstrap_ula_lscm_preprocess_page()`, para que reciba las variables del marco.
3. `ddev drush cr` y validar en el Drupal real.

Las páginas heredadas que aún no se han migrado **no se tocan**: siguen usando el `page.html.twig` de
Bootstrap Italia, intactas.

---

## 4. Footer: estado provisional y deuda futura

El footer actual es **provisional**: tiene la **estructura** del de la home pero el **contenido
hardcodeado**. Quedan pendientes, como hito propio (Fase 6 del plan de páginas de contenido):

- **Diseño del layout definitivo** del footer.
- **Editable desde la interfaz**: decidir el mecanismo y dónde vive el contenido (menús de Drupal,
  bloque de contenido, configuración del tema, o el patrón colección→preprocess→prop de la home).
- **Unificación con la home**: que home y páginas de contenido compartan **un único footer**,
  eliminando la duplicación entre el footer de `lscm-master-page` y `lscm_page_footer`.

No tiene disparador temporal fijo: se acomete cuando el footer definitivo esté definido.

---

## 5. Pendientes específicos del elemento

- **5.1. Footer definitivo (editable + unificado con la home).** Ver §4 y Fase 6 del plan. Pendiente.
- **5.2. Tabs de administración / título de página.** El marco es deliberadamente minimalista y **no**
  renderiza las regiones `local_tasks` (pestañas "Editar"), `title`, `breadcrumb`, `help`, etc., que sí
  maneja el `page.html.twig` de Bootstrap Italia. Es una decisión de diseño (marco limpio). Si en
  algún momento se necesita el enlace de "Editar" sobre la propia página, habría que añadir
  `{{ page.local_tasks }}` (u otras regiones) a las plantillas del marco. Pendiente de necesidad real.
- **5.3. Navegación en móvil.** El header resuelve el móvil con *wrap* de los enlaces (sin hamburguesa
  propia). Si el menú `main` crece, valorar un toggle hamburguesa propio de páginas internas. Pendiente
  de necesidad real.

---

## 6. ADRs del elemento

### ADR-LAYOUT-001 — Marco propio mediante plantillas específicas `page--<ruta>` (transición), con consolidación futura en un `page.html.twig` propio

**Contexto.** Las páginas de contenido del sitio (no la home) se renderizan hoy con el
`page.html.twig` del tema padre **Bootstrap Italia** (verificado: el tema no tiene `page.html.twig`
propio, hereda el de BI). Ese `page.html.twig` aporta el header y el footer de BI. Para avanzar en la
independencia de Bootstrap Italia se quiere que las páginas tengan un **marco propio** (header + footer
`ula_*`), pero **sin romper** las páginas heredadas que todavía dependen del marco de BI, y de forma
**incremental** (página a página; Opción B).

Se verificó (con el volcado de sugerencias de plantilla de Twig sobre `/about`) que Drupal genera,
para una página en `/<path>`, la sugerencia de plantilla **`page--<path>.html.twig`** (basada en el
**path**), más específica que `page.html.twig` y que, por tanto, **gana** sobre ella si el fichero
existe. Para `/about` la sugerencia confirmada es `page--about.html.twig`.

**Decisión.** Crear, **por cada página de contenido que se migra**, una plantilla específica
`page--<path>.html.twig` que monte el marco propio (header + contenido + footer). Esta plantilla solo
captura su propia página; las heredadas siguen con el `page.html.twig` de BI, intactas. La primera es
`page--about.html.twig`.

**Esta decisión es PROVISIONAL / de transición.** Las plantillas específicas son el **andamiaje**
mientras conviven páginas nuevas (sin BI) y heredadas (con BI). El **estado objetivo** es: cuando
**todas** las páginas no-home tengan su gemela nueva (independencia de Bootstrap Italia completa, ya
sin páginas que dependan del `page.html.twig` de BI), **consolidar** las plantillas específicas en un
**único `page.html.twig` propio** del tema, que aporte el marco a todas las páginas de contenido y
permita eliminar las plantillas `page--<path>` una a una.

> **Cautela (condición explícita).** La consolidación en un `page.html.twig` único asume que **todas**
> las páginas no-home comparten **efectivamente el mismo marco** (mismo diseño de regiones, mismo
> header, mismo footer). Es lo esperado, dado que el marco es transversal por diseño; pero **si alguna
> página requiriese un marco distinto**, conservaría su plantilla específica `page--<path>`. La
> consolidación es la meta, no una promesa incondicional.

**Disparador de la revisión.** "Cuando no queden páginas no-home dependientes de Bootstrap Italia."
Enlaza con la Fase 5 del plan de páginas de contenido (eliminación de lo heredado) y con el TO-DO
transversal de eliminar la vista heredada `page_home`.

**Alternativas consideradas.**
- *Crear ya un `page.html.twig` propio (genérico).* Descartada **ahora**: capturaría **todas** las
  páginas no-home, incluidas las heredadas, que pasarían de golpe a un marco sin sus regiones de BI y
  **se romperían** (sus bloques quedarían sin región donde renderizarse). Es, sin embargo, el estado
  **objetivo** una vez no queden heredadas.
- *Discriminar dentro de un único `page.html.twig`* (un `if` que monte marco propio o estructura de BI
  según el tipo de página). Descartada por complejidad y por requerir un criterio de discriminación
  fiable; las plantillas específicas logran lo mismo de forma más simple y localizada.
- *Header/footer como bloques en las regiones de BI.* Descartada: ataría el marco al sistema de
  regiones heredado de Bootstrap Italia, justo lo que se quiere abandonar.

**Consecuencias.**
- Avance **incremental** real: cada página adopta el marco al migrarse, sin afectar a las demás.
- **Coste de transición:** una plantilla `page--<path>` por página migrada, más el alta de su ruta en
  `$framed_routes` del preprocess. Es andamiaje temporal, a consolidar al final.
- Las plantillas del marco son **código** (viven en git). Los menús y vistas que consumen son
  **configuración** (viven en BD; red de seguridad: dump).

### ADR-LAYOUT-002 — Navegación del header de páginas: menú `main`, no híbrido

**Contexto.** El header de las páginas de contenido debía tener una navegación. La home usa un header
**híbrido** (barra de anclas internas hardcodeadas + hamburguesa del menú `home_header`), adecuado a
una landing de una sola página. Las páginas de contenido son páginas normales del sitio: necesitan
**navegar entre páginas**, no saltar a secciones internas.

**Decisión.** El header de las páginas de contenido usa una **navegación de sitio estándar** (una sola
barra de enlaces), alimentada por el menú de Drupal **`main`** (Main navigation: About, Contents,
Elegibility, Admission, Student Hub). **No** es híbrido: no tiene anclas internas ni hamburguesa. De
momento **no** incluye un botón "Apply Now" (solo los enlaces de navegación entre páginas).

**Alternativas consideradas.**
- *Reutilizar el menú `home_header` de la home.* Descartada: `home_header` es "propiedad" de la home
  (su hamburguesa); usarlo aquí acoplaría ambos headers. El menú `main` es el de navegación de sitio
  estándar de Drupal, que es justo lo que estas páginas necesitan.
- *Replicar el header híbrido de la home.* Descartada: las anclas internas no tienen sentido en una
  página de contenido (no es una landing de una sección); la navegación de sitio es lo apropiado.

**Consecuencias.**
- Añadir/quitar/reordenar enlaces del header de páginas se hace **desde el admin**, editando el menú
  `main` (no toca código).
- **Coste asumido (ya anticipado en ADR-003 de la home):** conviven dos menús con enlaces solapados,
  `home_header` (home) y `main` (páginas); mantener ambos es el precio de desacoplar los dos headers.
- El header se nutre de `main` con `_bootstrap_ula_lscm_get_menu_links('main')` (función reutilizada de
  la home). El enlace de la página actual se marca como activo vía `active_url`.
