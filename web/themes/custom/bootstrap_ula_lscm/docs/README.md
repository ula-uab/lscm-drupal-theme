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
  `ARCHITECTURE.md` §5 (restricciones del entorno: config/sync, dumps, crear campos por código).
