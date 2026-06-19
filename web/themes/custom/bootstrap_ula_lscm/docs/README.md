# Documentación — Tema Bootstrap ULA LSCM

Documentación del tema Drupal del máster europeo conjunto **LSCM** (Logistics & Supply Chain
Management). Organizada en **dos niveles**:

## Nivel tema (transversal)

- **[`ARCHITECTURE.md`](ARCHITECTURE.md)** — Arquitectura global del tema: versionado, identidad
  y estado de independencia, el design system propio (componentes `ula_*` y CSS en tres capas),
  notas técnicas y restricciones del entorno, y la estructura de ficheros.
- **[`CONCEPTOS-DRUPAL.md`](CONCEPTOS-DRUPAL.md)** — Manual de conceptos clave de Drupal (temas,
  librerías, regiones, sugerencias de plantilla, SDC, Views + UI Patterns…) **ilustrados y aplicados a
  este tema**. Material de referencia para desarrolladores y editores. Se amplía conforme avanza el
  desarrollo.
- **[`COMPONENTS.md`](COMPONENTS.md)** — Catálogo de los **componentes SDC propios** del tema (design
  system `ula_*` y marco `lscm_*`/`lscm-*`): función y atributos principales (slots y props) de cada uno.
  Describe los componentes en sí; su uso para componer páginas se documenta en `CONTENT-LAYOUT.md`.
- **[`../TODO.md`](../TODO.md)** — Pendientes transversales del tema.

## Nivel elemento (específico de cada parte)

- **[`elements/home/HOME-ARCHITECTURE.md`](elements/home/HOME-ARCHITECTURE.md)** — El elemento
  **home**: el marco `lscm-master-page`, cómo se sirve (nodo `landing` + plantillas), la guía de
  edición de contenido, y los pendientes de la home.
- El elemento **layout** (transversal a las páginas de contenido) se documenta en dos ficheros, uno
  por cada elemento del layout:
  - **[`elements/layout/SHARED-FRAME-LAYOUT.md`](elements/layout/SHARED-FRAME-LAYOUT.md)** — El **marco
    compartido**: header (`lscm_page_header`) + footer provisional (`lscm_page_footer`) de las páginas
    de contenido, cómo se monta (plantillas `page--<ruta>` / `page.html.twig` propio) y sus ADRs
    (ADR-LAYOUT-001, -002, -003).
  - **[`elements/layout/CONTENT-LAYOUT.md`](elements/layout/CONTENT-LAYOUT.md)** — El **diseño del
    contenido** de las páginas no-home basado en **Drupal Layout Builder**: modelo de composición de
    páginas con secciones + bloques (vistas que pintan entidades con componentes vía UI Patterns) y su
    ADR (ADR-LAYOUT-004).

> A medida que se desarrollen otras secciones del sitio, cada una tendrá su documentación en
> `docs/elements/<elemento>/`, referenciando a `ARCHITECTURE.md` para lo común.

## Análisis e investigación

Antes de rehacer una sección existente del sitio, se documenta su **estado actual** (cómo está hecha
hoy, heredada de Bootstrap Italia) en `docs/analysis/`. Son hallazgos de investigación que sirven de
base para el rediseño.

- **[`analysis/about-and-university-entity.md`](analysis/about-and-university-entity.md)** — estado
  de la página About y de la entidad "Universidad del consorcio" (`ct_about_consortium_university`);
  cómo se muestra hoy y opciones de diseño para reutilizarla.
- **[`analysis/inventario-bi.md`](analysis/inventario-bi.md)** — **inventario de elementos propios vs heredados** de Bootstrap Italia (componentes SDC, plantillas, librerías, regiones): qué está en uso, qué hay que adaptar/rehacer como propio y qué es herencia muerta a eliminar. Mapa maestro de la independencia de BI (Fase 0). Artefacto vivo.
- **[`analysis/about-page-heredada.md`](analysis/about-page-heredada.md)** — análisis **técnico** de la
  página «About» heredada (vista `page_about` + bloque `lscm_about_page` + UI Patterns): flujo
  contenido → visualización, dependencias de Bootstrap Italia y qué es reutilizable. Piloto de la fase
  de independencia de BI.
- **[`analysis/contents-subject-entity.md`](analysis/contents-subject-entity.md)** — entidad
  preexistente `ct_contents_subject` (las 15 asignaturas reales del máster) y su relación estructurada
  con los semestres; documentada de cara a la fase futura de adaptación del sitio.

## Diseño de entidades propias

Las **entidades propias** del tema (tipos de contenido diseñados en este proyecto, no heredados) se
documentan en `docs/entities/`. Recogen su modelo de campos y las decisiones de diseño.

- **[`entities/programme-facts.md`](entities/programme-facts.md)** — `ct_programme_facts`: los hechos
  /cifras del programa (ECTS, universidades, idioma…). Una entidad, varias representaciones (alimenta
  hero stats y why items de la home).
- **[`entities/admission-journey-step.md`](entities/admission-journey-step.md)** —
  `ct_admission_journey_step`: las fases del proceso de admisión (resumen para el timeline de la
  home). Distinta del detalle paso-a-paso de la sección Admission.
- **[`entities/programme-feature.md`](entities/programme-feature.md)** — `ct_programme_feature`: las
  características/ventajas del programa (acreditación, cohorte internacional…); alimenta la sección
  About de la home.
- **[`entities/admission-requirement.md`](entities/admission-requirement.md)** —
  `ct_admission_requirement`: los requisitos de admisión (resumen visual de la home). Distinto del
  detalle normativo de la sección Eligibility.
- **[`entities/programme-specialisation.md`](entities/programme-specialisation.md)** —
  `ct_programme_specialisation`: las especializaciones del máster (descripción rich text + imagen de
  Media). Conllevó el rediseño del componente `ula_spec_card`.
- **[`entities/programme-semester.md`](entities/programme-semester.md)** — `ct_programme_semester`:
  los semestres del journey (rich text + logos multivalor de Media). Conllevó el rediseño de
  `ula_sem_card` (logos + cajas de igual altura). Última de las 8 colecciones de la home.
- **[`entities/university-semester.md`](entities/university-semester.md)** — `ct_university_semester`:
  **entidad de relación** universidad × semestre (alimenta las pastillas de `ula_uni_card` y, a
  futuro, la página Consortium). Primer cruce entre dos entidades del tema.
- **[`entities/hero.md`](entities/hero.md)** — `hero` (+ paragraph `hero_stat`): la **cabecera/hero de
  una página de contenido** (eyebrow, título con resaltado, subtítulo, CTAs, estadísticas). Primera
  entidad del modelo de páginas no-home: se consume por una **vista con filtro contextual** (por el nodo
  de la página) que alimenta el componente `ula_hero` (no por preprocess → prop como la home).
- **[`entities/cta_band.md`](entities/cta_band.md)** — bloque de contenido `cta_band`: la **franja/tarjeta
  de cierre (CTA)** antes del footer. Es un **tipo de bloque** (no un nodo); se consume colocándolo en
  Layout Builder y componiéndolo con el componente `ula_cta_band` vía una plantilla del bloque. Incluye el
  ADR que distingue `ula_hero` (cabecera) de `ula_cta_band` (cierre).

## Planes de desarrollo

Los planes de trabajo (hojas de ruta por fases) viven en `docs/plans/<elemento>/`, separados de la
documentación de referencia. Cada elemento del tema tiene su carpeta de planes; los planes ya
completados se archivan en el subdirectorio `archive/` de cada elemento.

- **[`plans/paginas-contenido/`](plans/paginas-contenido/)** — plan maestro de **páginas de contenido e independencia de Bootstrap Italia**: el camino para desligar el tema de BI (marco `page.html.twig`, componentes SDC, librerías y regiones), articulado sobre las páginas de contenido (servidas por vistas, con header/footer propios). Piloto: About.
  - [`plan-sistema-paginas-contenido.md`](plans/paginas-contenido/plan-sistema-paginas-contenido.md) — **activo** (8 fases, 0–7; Fase 1 completada en v1.4.0).
- **[`plans/home/`](plans/home/)** — planes de la home:
  - [`archive/plan-colecciones-editables-e-interactividad.md`](plans/home/archive/plan-colecciones-editables-e-interactividad.md) — **completado** (v1.1.0 → v1.3.1): migración de las 8 colecciones a editables, interactividad (hamburguesa, pastillas con modal) y relación universidad↔semestre. La Fase 0 (limpieza de `page_home`) se reconvirtió en TO-DO transversal.
  - [`archive/plan-landing-parametrizada.md`](plans/home/archive/plan-landing-parametrizada.md) — **histórico**: plan inicial de la landing parametrizada (completado).

## Por dónde empezar

- **¿Mantener o editar el contenido de la home?** → `elements/home/HOME-ARCHITECTURE.md` §4.
- **¿Entender el design system / crear o tocar componentes?** → `ARCHITECTURE.md` §3 y §4.
- **¿Componer una página no-home (secciones, grids de tarjetas con Layout Builder)?** →
  `elements/layout/CONTENT-LAYOUT.md`. El marco (header/footer) que la envuelve, en
  `elements/layout/SHARED-FRAME-LAYOUT.md`.
- **¿Hacer cambios de configuración (campos, tipos de contenido, vistas)?** → leer antes
  `ARCHITECTURE.md` §6 (restricciones del entorno: config/sync, dumps, crear campos por código).
