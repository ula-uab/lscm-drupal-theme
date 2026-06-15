# Documentación — Tema Bootstrap ULA LSCM

Documentación del tema Drupal del máster europeo conjunto **LSCM** (Logistics & Supply Chain
Management). Organizada en **dos niveles**:

## Nivel tema (transversal)

- **[`ARCHITECTURE.md`](ARCHITECTURE.md)** — Arquitectura global del tema: versionado, identidad
  y estado de independencia, el design system propio (componentes `ula_*` y CSS en tres capas),
  notas técnicas y restricciones del entorno, y la estructura de ficheros.
- **[`../TODO.md`](../TODO.md)** — Pendientes transversales del tema.

## Nivel elemento (específico de cada parte)

- **[`elements/home/HOME-ARCHITECTURE.md`](elements/home/HOME-ARCHITECTURE.md)** — El elemento
  **home**: el marco `lscm-master-page`, cómo se sirve (nodo `landing` + plantillas), la guía de
  edición de contenido, y los pendientes de la home.

> A medida que se desarrollen otras secciones del sitio, cada una tendrá su documentación en
> `docs/elements/<elemento>/`, referenciando a `ARCHITECTURE.md` para lo común.

## Análisis e investigación

Antes de rehacer una sección existente del sitio, se documenta su **estado actual** (cómo está hecha
hoy, heredada de Bootstrap Italia) en `docs/analysis/`. Son hallazgos de investigación que sirven de
base para el rediseño.

- **[`analysis/about-and-university-entity.md`](analysis/about-and-university-entity.md)** — estado
  de la página About y de la entidad "Universidad del consorcio" (`ct_about_consortium_university`);
  cómo se muestra hoy y opciones de diseño para reutilizarla.
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

## Planes de desarrollo

Los planes de trabajo (hojas de ruta por fases) viven en `docs/plans/<elemento>/`, separados de la
documentación de referencia. Cada elemento del tema tiene su carpeta de planes; los planes ya
completados se archivan en el subdirectorio `archive/` de cada elemento.

- **[`plans/home/`](plans/home/)** — planes de la home:
  - [`plan-colecciones-editables-e-interactividad.md`](plans/home/plan-colecciones-editables-e-interactividad.md) — **activo**: migrar las colecciones a editables, interactividad (hamburguesa, pastillas) y limpieza.
  - [`archive/plan-landing-parametrizada.md`](plans/home/archive/plan-landing-parametrizada.md) — **histórico**: plan inicial de la landing parametrizada (completado).

## Por dónde empezar

- **¿Mantener o editar el contenido de la home?** → `elements/home/HOME-ARCHITECTURE.md` §4.
- **¿Entender el design system / crear o tocar componentes?** → `ARCHITECTURE.md` §3 y §4.
- **¿Hacer cambios de configuración (campos, tipos de contenido, vistas)?** → leer antes
  `ARCHITECTURE.md` §6 (restricciones del entorno: config/sync, dumps, crear campos por código).
