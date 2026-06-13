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

## Por dónde empezar

- **¿Mantener o editar el contenido de la home?** → `elements/home/HOME-ARCHITECTURE.md` §4.
- **¿Entender el design system / crear o tocar componentes?** → `ARCHITECTURE.md` §3 y §4.
- **¿Hacer cambios de configuración (campos, tipos de contenido, vistas)?** → leer antes
  `ARCHITECTURE.md` §5 (restricciones del entorno: config/sync, dumps, crear campos por código).
