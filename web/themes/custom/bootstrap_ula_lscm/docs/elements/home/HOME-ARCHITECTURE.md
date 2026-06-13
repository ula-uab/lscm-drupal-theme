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

> **IMPORTANTE:** este estado es **provisional**. La §5 describe el plan para hacer estas
> colecciones editables desde el admin mediante tipos de contenido + vistas.

---

## 5. Pendientes de la home

Pendientes específicos de la home. (Los pendientes transversales del tema están en `TODO.md` en
la raíz del tema.)

### 5.1. Colecciones editables (tipos de contenido + vistas) — EN CURSO

**Estado:** las 8 colecciones están hoy como datos fijos en el `.twig` del marco (decisión
**provisional** para desbloquear la home). Plan acordado: migrarlas a **tipos de contenido +
vistas**, reutilizando el patrón que el sitio ya usa (la timeline de Admissions: nodos
`ct_admission_preenrolment_step` listados por una vista y pintados con `timeline_item2` vía
`ui_patterns_views`).

**Mecanismo por colección:**
1. Un **tipo de contenido** con los campos del ítem.
2. **Nodos** (el contenido editable).
3. Una **vista** que los lista y los pinta con el componente `ula_*` correspondiente (vía
   `ui_patterns_views`, mapeando campos → props).
4. Integrar la vista en la home en lugar de la colección fija.

**Colecciones a migrar:** universidades (`ula_uni_card`), especializaciones (`ula_spec_card`),
semestres (`ula_sem_card`), why-items (`ula_why_item`), timeline (`ula_timeline_item`),
requisitos (`ula_req_card`), features (`ula_feature_item`), stats del hero (`ula_hero_stat`).

**Método previsto:** validar el patrón con una colección piloto (probablemente **universidades**)
antes de replicar a las demás. Decidir, por colección, si el contenido tendrá página de detalle
propia (reutilizable) — lo que refuerza el enfoque nodos+vistas.

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
