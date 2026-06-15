# Plan de desarrollo — Sistema de páginas de contenido (marco compartido + independencia de BI)

> Planifica la construcción de un **sistema de páginas de contenido** del sitio del máster: páginas
> servidas por **vistas de Drupal** que comparten un **header y un footer** comunes y, entre ellos,
> "pintan" el contenido propio de cada página. El objetivo transversal es avanzar en la
> **independencia de Bootstrap Italia** (BI): las páginas nuevas no introducen dependencias de BI y su
> presentación se hace con el design system propio `ula_*` / `lscm_*`.
>
> Sigue el método del proyecto: construir de lo simple a lo complejo, **analizar antes de decidir**,
> validar cada paso en el Drupal real antes de consolidar, y consolidar en git por hito. La
> documentación se mantiene al día como parte de cada hito.

---

## Contexto y punto de partida

El sitio se retomó de un desarrollo previo. Las páginas heredadas (About, Contents, Admission,
Eligibility) comparten un **patrón estructural uniforme**: cada página es un **bloque de contenido**
de un tipo `lscm_*` servido por una **vista** de Drupal, presentado con **UI Patterns** apuntando a
**componentes de Bootstrap Italia** (grid_row, card…), con clases de Bootstrap y, en algún caso,
contenido hardcodeado en la propia vista. El análisis técnico del piloto está en
[`../../analysis/about-page-heredada.md`](../../analysis/about-page-heredada.md).

**Decisión de partida (confirmada con el usuario).** A diferencia de la home —que es una portada a
medida y por eso se sirve como **nodo + plantilla Twig**, descartando vistas y UI Patterns
(ADR-001)—, las **páginas de contenido se seguirán sirviendo con vistas de Drupal**. Razón: el
contenido de estas páginas puede requerir herramientas de visualización muy diversas (listados
filtrados, agrupaciones, tablas, subvistas como el consorcio…), y Views es la herramienta adecuada de
Drupal para ello. **No se desmonta el mecanismo de vistas**; lo que se elimina es la **dependencia de
Bootstrap Italia en su capa de presentación**, sustituyéndola por componentes `ula_*` propios.

> Son **dos mecanismos distintos para dos necesidades distintas**, de forma deliberada: la home
> (portada a medida) → nodo + Twig; las páginas de contenido (contenido estructurado y variado) →
> vistas con presentación propia. No es una incoherencia, es una decisión razonada que quedará
> registrada como ADR al cerrar la fase de investigación (Fase 2).

---

## Objetivo

Disponer de un **sistema de páginas de contenido** en el que:

1. Exista un **marco compartido** (header + footer) que **todas** las páginas internas cargan, con la
   estética de la home pero con la navegación y el comportamiento propios de páginas internas (no el
   header híbrido de la home).
2. Cada página de contenido se sirva con una **vista de Drupal** cuya **presentación no dependa de
   Bootstrap Italia**, sino del design system `ula_*` / `lscm_*`.
3. Exista un **patrón reutilizable** y documentado para construir las siguientes páginas de contenido
   (Contents, Admission, Eligibility…) con el mismo método.

La página **About** es el **piloto**: sencilla pero representativa del patrón estructural del sitio
heredado (ver análisis).

---

## Principios base

- **No introducir dependencias nuevas de Bootstrap Italia** en nada de lo que se construya (regla
  general del proyecto). El estilado lo aporta `ula_*`.
- **Nomenclatura con prefijos propios** `ula_*` (design system) o `lscm_*` (piezas de marca / más
  amplias), huyendo de nombres genéricos tipo `card`, `card1`, `card2`.
- **Header y footer son transversales:** se construyen una vez como marco/componente **compartido**,
  no se reimplementan página a página.
- **El footer es provisional** hasta que se defina su contenido y diseño final; cuando se consolide,
  habrá que rehacer/unificar el footer de la home para que use el mismo (deuda futura explícita).
- **Cautela con la configuración:** las vistas y los bloques viven en la **BD** (no en git); su red de
  seguridad es el **dump**. Cualquier operación que toque configuración (incluida la eliminación de lo
  viejo) lleva dump previo y análisis de qué se pierde.

---

## Orden de construcción

### Fase 1 — Marco compartido (header + footer)

Construir el "esqueleto" que envuelve a todas las páginas internas: header (estética de la home,
**navegación de sitio estándar** — no el híbrido de anclas + hamburguesa de la home; ver ADR-003) y
footer (**provisional**, inspirado en el de la home, informado en lo posible por el contenido de las
páginas a rehacer). Entre header y footer queda el "hueco" donde cada página inyecta su contenido.

- **Prerrequisito** de todo lo demás: cualquier página de contenido necesita este marco.
- Decisiones a tomar en esta fase (se detallan al arrancarla, no se prejuzgan aquí): cómo se modela el
  marco en Drupal de modo que una vista pueda renderizarse "dentro" de él (región de página,
  plantilla `page--*`, bloque de header/footer, etc.); nomenclatura del/los componente(s)
  (`lscm_*` / `ula_*`); cómo se relaciona con el header de la home (comparten estética, difieren en
  navegación: ¿base común + navegación distinta, o piezas separadas que comparten estilos?).
- **Documentación del elemento** en `docs/elements/layout/` (decisión ya acordada: header y footer,
  aunque transversales, se documentan como un elemento propio; referenciado desde `ARCHITECTURE.md`).

### Fase 2 — Estrategia de presentación sin BI para páginas servidas por vistas

El corazón del plan. Mantener el mecanismo de **Views**, pero sustituir su capa de presentación
dependiente de BI por presentación propia `ula_*`.

1. **Investigación previa de vías técnicas (primera tarea, obligatoria — no se decide a priori).**
   Identificar y evaluar los **caminos viables** para que una vista de Drupal presente su contenido
   con componentes propios `ula_*` en lugar de componentes de Bootstrap Italia. Candidatos a analizar
   (lista abierta, a confirmar/descartar con investigación en el Drupal real):
   - **UI Patterns apuntando a componentes `ula_*`**: mantener el plugin de fila/estilo UI Patterns
     pero seleccionando componentes SDC propios en vez de `bootstrap_ula_lscm:card` / `:grid_row`.
     (Verificar que UI Patterns puede consumir nuestros SDC y cómo se mapean campos → props/slots.)
   - **Plantillas de vista propias** (`views-view--*.html.twig`, `views-view-fields--*`, etc.) que
     rendericen el contenido con markup y clases `ula_*`.
   - **Un estilo/formato de vista custom** o el uso de *view modes* de los bloques con plantillas
     propias.
   - Cualquier otra vía que la investigación revele.
   Para cada vía: viabilidad técnica, encaje con el objetivo de independencia (cero BI), complejidad,
   y relación con los problemas ya conocidos (p. ej. los errores de UI Patterns en la galería,
   TODO #3). **Salida de esta tarea:** una recomendación razonada de la vía a seguir, registrada como
   **ADR**.
2. **Decisión y validación con el piloto (About).** Aplicar la vía elegida a la página About:
   reconstruir su presentación sin BI, conservando el flujo de vista y el contenido aprovechable
   (según el análisis), bajo el marco compartido de la Fase 1. Validar en el Drupal real.
3. **Componentes `ula_*` necesarios.** Diseñar/implementar los componentes propios que la nueva About
   requiera (según la maqueta de exploración y el contenido real que se decida), con la nomenclatura
   del proyecto.

> **Dependencia identificada — subvista del consorcio.** La About heredada embebe la vista
> `page_about_consortium` (consorcio de universidades). Su tratamiento (mantener embebida y migrarla,
> enlazar a una futura página Consortium, u omitir) se decide dentro de esta fase, y puede requerir su
> propio análisis (ligado a la futura página Consortium; ver ADR-004 en
> `../../elements/home/HOME-ARCHITECTURE.md`).

### Fase 3 — Documentar el patrón y los ADRs

Al cerrar la validación del piloto, documentar lo realmente construido:

- **ADR(s)**: la decisión "páginas de contenido = vistas con presentación propia `ula_*`" (frente a la
  home nodo+Twig); y la vía técnica elegida en la Fase 2.
- **Elemento `layout/`**: documentación del marco compartido (header + footer).
- **Patrón reutilizable**: cómo construir una nueva página de contenido siguiendo este sistema
  (guía para replicar en Contents, Admission, Eligibility).
- Actualizar `ARCHITECTURE.md` (estructura, versionado) y `README.md` (índice).

### Fase 4 — Replicar a las demás páginas de contenido (fuera del alcance inicial)

Con el patrón validado y documentado, aplicar el mismo método a Contents, Admission y Eligibility
(cada una con su análisis previo, ya que pueden tener particularidades). Se planificará en su momento;
aquí solo se anticipa.

### Fase 5 — Eliminar la página heredada sustituida

Cuando la nueva About esté validada y consolidada, eliminar la implementación heredada que dependía de
BI (la vista `page_about` y lo que proceda). Toca **configuración** (vive en BD): **dump previo**,
analizar qué se pierde (incluida la subvista del consorcio si aún se referencia), y método quirúrgico.
Misma cautela aplicada a `page_home` (TO-DO transversal). No se ejecuta hasta que la sustituta esté
en producción y validada.

---

## Método de trabajo (el mismo del proyecto)

- Antes de cada operación que toque configuración o BD: **dump** + recordatorio de **commit + push**.
- **Analizar antes de decidir**: ninguna fase asume una solución sin investigarla (especialmente la
  Fase 2.1).
- Claude trabaja en su clon y entrega ficheros; el usuario valida en su Drupal real antes de
  consolidar; inspecciones siempre de solo lectura.
- Documentar **al cerrar** cada hito (implementar y validar primero, documentar después), reflejando
  lo realmente construido.
- Consolidar en git por hito y verificar integridad de lo subido.

---

## Cuestiones abiertas a decidir (al arrancar cada fase)

- **Fase 1:** modelo del marco en Drupal (región/plantilla `page--*`/bloques); nomenclatura del
  componente del marco; relación exacta con el header de la home (base común vs. piezas separadas);
  alcance del footer provisional (qué incluye mientras no se define el definitivo).
- **Fase 2:** la vía técnica de presentación sin BI (resultado de la investigación 2.1); qué hacer con
  la subvista del consorcio; qué contenido de la maqueta "ideal" de About aplica realmente al máster
  y, por tanto, qué componentes `ula_*` hay que construir.
- **Transversal:** cómo se decide la navegación del header de páginas internas (qué enlaces, de qué
  menú de Drupal) — se relaciona con el menú `home_header` y el menú `main` ya existentes.

---

## Resumen

El plan construye, de forma incremental y validada, un **sistema de páginas de contenido** con
**header/footer compartidos** y presentación **independiente de Bootstrap Italia**, **conservando el
mecanismo de vistas de Drupal** (adecuado para contenido estructurado, a diferencia de la home).
Empieza por el **marco compartido** (Fase 1), sigue con la **investigación y elección de la vía de
presentación sin BI** validada con el piloto **About** (Fase 2), lo **documenta** como patrón
reutilizable y ADRs (Fase 3), y deja anticipadas la **replicación** a las demás páginas (Fase 4) y la
**eliminación** de lo heredado (Fase 5). La fase crítica y no prejuzgada es la **investigación de vías
técnicas (2.1)**, que precede a cualquier decisión de implementación.
