# Plan de desarrollo — Sistema de páginas de contenido e independencia de Bootstrap Italia

> Planifica el camino hacia la **independencia completa de Bootstrap Italia** (BI) en el sitio del
> máster, articulado alrededor del **sistema de páginas de contenido**: páginas que comparten un
> **header y un footer** propios y, entre ellos, "pintan" el contenido propio de cada página, todo con
> el design system propio `ula_*` / `lscm_*` y **sin dependencias de Bootstrap Italia**.
>
> El objetivo final es **desligar el tema `bootstrap_ula_lscm` de su tema padre Bootstrap Italia** —a
> nivel de marco (`page.html.twig` y sus dependencias), de componentes SDC, de librerías CSS y de
> regiones— hasta poder declararlo autónomo (un cambio MAYOR de versión cuando se complete).
>
> Sigue el método del proyecto: construir de lo simple a lo complejo, **analizar antes de decidir**,
> validar cada paso en el Drupal real antes de consolidar, y consolidar en git por hito. La
> documentación se mantiene al día como parte de cada hito.

---

## Contexto y punto de partida

El sitio se retomó de un desarrollo previo. El tema `bootstrap_ula_lscm` es **hijo de
`bootstrap_italia`** (`base theme: bootstrap_italia`) y depende de él en varios planos, identificados
durante la investigación:

- **Marco de página:** el tema **no tiene `page.html.twig` propio**; usa el de Bootstrap Italia
  (`themes/contrib/bootstrap_italia/templates/layout/page.html.twig`), que aporta el header y el footer
  de BI a todas las páginas no-home.
- **Regiones:** el `.info.yml` del tema **redeclara explícitamente** el esquema completo de ~56
  regiones de Bootstrap Italia (slim header, before/after content, filas de home, footer múltiple…),
  muchas de ellas previsiblemente sin uso real.
- **Librerías CSS:** el `.info.yml` **carga globalmente** `bootstrap_italia/base` (el CSS estructural
  de BI) además de las librerías propias. Es uno de los enganches de fondo con BI a nivel de assets.
- **Páginas heredadas:** About, Contents, Admission y Eligibility comparten un **patrón estructural
  uniforme**: cada página es un **bloque de contenido** de un tipo `lscm_*` servido por una **vista**
  de Drupal, presentada con **UI Patterns** apuntando a **componentes de Bootstrap Italia** (grid_row,
  card…), con clases de Bootstrap y, en algún caso, contenido hardcodeado en la propia vista. El
  análisis técnico del piloto está en
  [`../../analysis/about-page-heredada.md`](../../analysis/about-page-heredada.md).

**Decisión de partida sobre cómo se sirven las páginas (confirmada con el usuario).** A diferencia de
la home —que es una portada a medida y por eso se sirve como **nodo + plantilla Twig**, descartando
vistas y UI Patterns (ADR-001)—, las **páginas de contenido se seguirán sirviendo con vistas de
Drupal**. Razón: el contenido de estas páginas puede requerir herramientas de visualización muy
diversas (listados filtrados, agrupaciones, tablas, subvistas como el consorcio…), y Views es la
herramienta adecuada de Drupal para ello. **No se desmonta el mecanismo de vistas**; lo que se elimina
es la **dependencia de Bootstrap Italia en su capa de presentación**, sustituyéndola por componentes
`ula_*` propios.

> Son **dos mecanismos distintos para dos necesidades distintas**, de forma deliberada: la home
> (portada a medida) → nodo + Twig; las páginas de contenido (contenido estructurado y variado) →
> vistas con presentación propia. No es una incoherencia, es una decisión razonada.

---

## Objetivo

Lograr que el tema `bootstrap_ula_lscm` sea **autónomo de Bootstrap Italia**, de modo que:

1. Exista un **marco propio** (`page.html.twig` del tema + header + footer) que sirva a las páginas
   no-home, independiente del marco de BI, con la estética propia y la navegación de páginas internas.
2. Cada página de contenido se sirva con una **vista de Drupal** cuya **presentación no dependa de
   Bootstrap Italia**, sino del design system `ula_*` / `lscm_*`.
3. Los **componentes SDC** que el sitio use sean **propios** (nativos o heredados adoptados y
   adaptados), sin componentes de Bootstrap Italia en las páginas vivas.
4. Las **regiones y librerías CSS** heredadas de Bootstrap Italia que no se usen queden **eliminadas**,
   y no quede dependencia de `bootstrap_italia/base` ni del `base theme` en las páginas vivas.
5. Exista un **inventario vivo** que distinga en todo momento los **elementos propios** de los
   **heredados**, y un **patrón reutilizable** documentado para construir páginas de contenido.

La página **About** es el **piloto**: sencilla pero representativa del patrón estructural del sitio
heredado (ver análisis).

---

## Principios base

- **No introducir dependencias nuevas de Bootstrap Italia** en nada de lo que se construya (regla
  general del proyecto). El estilado lo aporta `ula_*`.
- **Nomenclatura con prefijos propios.** En adelante, **`ula_*` se usa SOLO para desarrollos nuevos**
  (design system y piezas propias nuevas). Los nombres con prefijo `lscm_*` son, por convención,
  **heredados** —salvo las piezas `lscm_page_*` creadas en la Fase 1 (`lscm_page_header`,
  `lscm_page_footer`), que son propias y nacieron antes de fijar esta convención—. Se huye de nombres
  genéricos tipo `card`, `card1`, `card2`.
- **Adopción de elementos heredados con renombrado.** Cuando se tome un elemento heredado (una
  plantilla, un componente SDC, etc.) y se incorpore —con adaptación o directamente— como elemento
  necesario del tema, se le **cambia el nombre con prefijo propio** (`ula_*` por ser desarrollo que
  adoptamos) y **pasa al inventario de elementos propios**. La estética se adapta a la del tema.
- **Inventario propio vs heredado como artefacto vital.** Se elabora al inicio del proceso (Fase 0) y
  se mantiene vivo: cada vez que un elemento cambia de estado (heredado → adoptado/propio), se
  actualiza. Registra, por elemento: nombre, tipo, **origen** (propio nativo / heredado) y **estado**
  (heredado intacto / adoptado-adaptado / propio).
- **Tolerancia gestionada a roturas.** Adoptar un `page.html.twig` propio (genérico) afecta a todas las
  páginas no-home a la vez; algunas páginas heredadas **podrían romperse**. Las roturas **no son un
  bloqueo**: se detectan, se analiza la causa, y se decide **caso a caso** cómo proseguir. Es una
  postura deliberada (acordada con el usuario), distinta de la Fase 1, donde el riesgo se aislaba por
  página.
- **Header y footer son transversales:** se construyen una vez como marco/componente **compartido**, no
  se reimplementan página a página.
- **El footer es provisional** hasta que se defina su contenido y diseño final. La Fase 1 lo construyó
  con la **estructura** del footer de la home pero contenido hardcodeado; hacerlo **editable desde la
  interfaz** y **unificarlo con el footer de la home** es un hito propio (Fase 7).
- **Cautela con la configuración:** las vistas y los bloques viven en la **BD** (no en git); su red de
  seguridad es el **dump**. Cualquier operación que toque configuración (incluida la eliminación de lo
  viejo) lleva dump previo y análisis de qué se pierde.

---

## Orden de construcción

### Fase 0 — Inventario de elementos (propios vs heredados)

**Primera tarea y bloqueante. Es análisis/documentación: riesgo cero, no modifica nada.** Catalogar el
estado actual del tema para tener el mapa que guía toda la independencia. El inventario cubre:

- **Marco de página:** `page.html.twig` (hoy heredado de BI) y la **cadena de dependencias** que
  arrastra (includes, sub-plantillas de región/header/footer, variables y funciones de BI que use).
- **Plantillas** del tema: propias (`page--front`, `page--about`, `node--landing`…) vs heredadas.
- **Componentes SDC:** propios (`ula_*`, `lscm_page_*`, `lscm-master-page`…) vs heredados
  (`bootstrap_ula_lscm:grid_row`, `:card` y demás SDC de BI que usan las páginas viejas).
- **Librerías CSS/JS:** propias vs heredadas (en particular la dependencia global de
  `bootstrap_italia/base`).
- **Regiones:** las ~56 declaradas; cuáles usan realmente las páginas vivas y cuáles son herencia
  muerta candidata a eliminación.

**Salida:** un documento de inventario (ubicación a decidir: `docs/` —probablemente un
`docs/analysis/inventario-bi.md` o similar) con, por elemento: nombre, tipo, origen y estado. Es el
**artefacto vivo** que se actualizará en cada fase posterior.

> El usuario colabora en clasificar los `lscm_*` ambiguos (qué es heredado y qué no), aprovechando que
> en adelante solo los desarrollos nuevos usarán `ula_*`.

### Fase 1 — Marco de páginas: header + footer propios  ✅ COMPLETADA (v1.4.0)

Construido el marco compartido de las páginas de contenido, independiente de BI: componentes
`lscm_page_header` (estética home, navegación de sitio desde el menú `main`) y `lscm_page_footer`
(provisional, con la estructura del footer de la home), montados por la plantilla específica
`page--about.html.twig`, que captura **solo** `/about` sin afectar a las demás páginas (Opción B,
página a página). Documentado en `docs/elements/layout/` con ADR-LAYOUT-001 (marco vía `page--<ruta>`
como transición, con consolidación futura en un `page.html.twig` propio) y ADR-LAYOUT-002 (navegación
desde `main`). Ver `../../elements/layout/LAYOUT-ARCHITECTURE.md`.

### Fase 2 — `page.html.twig` propio (desligado de BI, dependencia a dependencia)

El corazón de la independencia del marco. Copiar el `page.html.twig` de Bootstrap Italia a la
estructura del tema (`templates/layout/page.html.twig`); como el tema hijo gana sobre el padre, Drupal
pasará a usar el nuestro para todas las páginas no-home sin sugerencia específica. A partir de esa
réplica, **desligarla de BI de forma incremental**:

1. **Identificar, una a una, las dependencias de BI** que arrastra ese `page.html.twig`: includes y
   sub-plantillas (header, footer, regiones), variables y funciones propias de BI, markup y clases de
   Bootstrap. (Apoyado en el inventario de la Fase 0.)
2. **Reimplementar cada dependencia en el tema propio**, con equivalentes `ula_*` / `lscm_*`, sin
   markup ni clases de BI.
3. **Identificar qué regiones usan realmente las páginas vivas** (no-home), con vistas a **eliminar las
   no usadas** del `.info.yml` (en la Fase 6).
4. **Gestionar las roturas caso a caso**: como el `page.html.twig` propio afecta a todas las no-home,
   validar tras cada cambio qué páginas se ven afectadas; analizar y decidir. Dump previo, cambios
   pequeños, validación en el Drupal real.

> Relación con la Fase 1: las plantillas específicas `page--<ruta>` (como `page--about`) y el
> `page.html.twig` propio coexisten durante la transición; el genérico es el destino al que se
> consolidarán cuando no queden páginas dependientes del marco de BI (ADR-LAYOUT-001).

### Fase 3 — Adopción de componentes SDC heredados útiles

Los **componentes SDC heredados** que usan las páginas viejas y se consideren **útiles** (p. ej.
variantes de `card`, `grid_row` si encajan): adoptarlos, **adaptándolos a la estética propia** y
**renombrándolos con prefijo propio** (`ula_*`), e incorporarlos al inventario de elementos propios.
Los que no se consideren útiles se descartan (se sustituyen por diseño propio en la fase de
presentación). Cada adopción: análisis del componente, reimplementación/adaptación sin BI, validación.

### Fase 4 — Presentación del contenido de las páginas sin BI

Sustituir la capa de presentación dependiente de BI de las vistas por presentación propia `ula_*`,
**conservando el mecanismo de Views**.

1. **Investigación previa de vías técnicas (primera tarea, obligatoria — no se decide a priori).**
   Identificar y evaluar los **caminos viables** para que una vista presente su contenido con
   componentes propios `ula_*` en lugar de los de Bootstrap Italia. Candidatos a analizar (lista
   abierta, a confirmar/descartar con investigación en el Drupal real):
   - **UI Patterns apuntando a componentes `ula_*`**: mantener el plugin de fila/estilo UI Patterns
     (UI Patterns 2.0.15, SDC-nativo, ya confirmado instalado con `ui_patterns_views`) pero
     seleccionando componentes SDC propios en vez de `bootstrap_ula_lscm:card` / `:grid_row`.
   - **Plantillas de vista propias** (`views-view--*.html.twig`, `views-view-fields--*`, etc.) que
     rendericen el contenido con markup y clases `ula_*`.
   - **Un estilo/formato de vista custom**, *view modes* con plantillas propias, u otras vías.
   Para cada vía: viabilidad técnica, encaje con el objetivo de independencia (cero BI), **dónde vive
   la definición** (config en BD vs código en git), complejidad, y relación con los problemas conocidos
   (errores de UI Patterns en la galería, TODO #3). **Salida:** recomendación razonada, registrada como
   **ADR**.
2. **Requisito de diseño a satisfacer (aportado por el usuario).** La página debe poder componerse de
   **secciones heterogéneas apiladas** en la región de contenido, donde **algunas secciones son
   listados de contenido filtrado mapeados a un componente SDC** (patrón "contenedor + filtro + mapeo
   campo→componente", p. ej. un grid que inserta nodos que cumplen un filtro, presentados como cards).
   La vía elegida debe permitir este modelo. *Sub-cuestión a aclarar:* las secciones dinámicas listan
   **nodos** o **bloques de contenido** (la home usa nodos; la About heredada, bloques).
3. **Decisión y validación con el piloto (About).** Aplicar la vía elegida a About: reconstruir su
   presentación sin BI, conservando el flujo de vista y el contenido aprovechable, bajo el marco propio.
   Validar en el Drupal real.
4. **Componentes `ula_*` necesarios.** Diseñar/implementar los componentes propios que la nueva About
   requiera (según la maqueta de exploración y el contenido real que se decida).

> **Dependencia identificada — subvista del consorcio.** La About heredada embebe la vista
> `page_about_consortium` (consorcio de universidades). Su tratamiento (mantener embebida y migrarla,
> enlazar a una futura página Consortium, u omitir) se decide dentro de esta fase, y puede requerir su
> propio análisis (ligado a la futura página Consortium; ver ADR-004 en
> `../../elements/home/HOME-ARCHITECTURE.md`).

### Fase 5 — Replicar a todas las páginas no-home y consolidar el marco

Con el patrón validado en About, aplicar el mismo método a **Contents, Admission y Eligibility** (cada
una con su análisis previo, ya que pueden tener particularidades). Cuando **todas** las páginas no-home
tengan su versión sin BI:

- **Consolidar** las plantillas específicas `page--<ruta>` en el **único `page.html.twig` propio** del
  tema, eliminando las específicas que ya no aporten diferencia (disparador de ADR-LAYOUT-001:
  "cuando no queden páginas no-home dependientes de BI"), siempre que todas compartan efectivamente el
  mismo marco.
- Dejar el marco propio como mecanismo único de las páginas no-home.

### Fase 6 — Eliminar lo heredado de Bootstrap Italia

Cuando las páginas vivas ya no dependan de BI, **retirar la herencia muerta**, con cautela (toca código
y configuración):

- **Configuración (BD):** vistas y bloques heredados sustituidos (la vista `page_about` y análogas).
  **Dump previo**, analizar qué se pierde (incluida la subvista del consorcio si aún se referencia),
  método quirúrgico. Misma cautela aplicada a `page_home` (TO-DO transversal).
- **Código del tema:** eliminar del `.info.yml` las **regiones** de BI no usadas (identificadas en la
  Fase 2.3) y la carga de la librería **`bootstrap_italia/base`**; revisar la relación `base theme`
  con Bootstrap Italia. Cada eliminación, validada.
- **Culminación:** cuando no quede dependencia de Bootstrap Italia en las páginas vivas ni en los
  assets, el tema puede declararse autónomo → **cambio MAYOR de versión**.

### Fase 7 — Footer definitivo (hito transversal propio)

Hito **independiente de la migración de páginas** (afecta al marco compartido). El footer de la Fase 1
es **provisional** (estructura del de la home, contenido hardcodeado). Este hito aborda el footer
**definitivo**:

1. **Diseño del layout definitivo** del footer, partiendo de la estructura provisional existente.
2. **Editable desde la interfaz**: decidir **con qué mecanismo** se hace editable y **dónde vive** el
   contenido (candidatos a evaluar: menú(s) de Drupal para los enlaces, bloque de contenido para los
   textos, configuración del tema, o el patrón colección→preprocess→prop ya usado en la home). Es el
   mismo tipo de problema que se resolvió para las colecciones editables de la home; se decidirá con su
   propio análisis y, si procede, su ADR.
3. **Unificación con la home**: rehacer el footer de la home para que **comparta** el mismo componente
   y contenido editable que las páginas de contenido (un único footer en todo el sitio), eliminando la
   duplicación entre el footer de `lscm-master-page` (home) y `lscm_page_footer` (páginas).

**Por qué se difiere:** invertir en hacer editable un footer aún provisional arriesga retrabajo cuando
se defina el definitivo. No tiene disparador temporal fijo: se acomete cuando el footer definitivo esté
definido.

---

## Método de trabajo (el mismo del proyecto)

- Antes de cada operación que toque configuración o BD: **dump** + recordatorio de **commit + push**.
- **Analizar antes de decidir**: ninguna fase asume una solución sin investigarla (especialmente la
  investigación de vías técnicas de la Fase 4).
- Claude trabaja en su clon y entrega ficheros; el usuario valida en su Drupal real antes de
  consolidar; inspecciones siempre de solo lectura.
- Documentar **al cerrar** cada hito (implementar y validar primero, documentar después), reflejando lo
  realmente construido. **Mantener el inventario (Fase 0) actualizado** en cada cambio de estado de un
  elemento.
- Consolidar en git por hito y verificar integridad de lo subido.

---

## Cuestiones abiertas a decidir (al arrancar cada fase)

- **Fase 0:** ubicación y formato exacto del documento de inventario; criterio para clasificar los
  `lscm_*` ambiguos.
- **Fase 2:** alcance real de la cadena de dependencias del `page.html.twig` de BI (solo se conoce al
  tirar del hilo); orden de desligado de cada dependencia.
- **Fase 4:** la vía técnica de presentación sin BI (resultado de la investigación); si las secciones
  dinámicas listan nodos o bloques; qué hacer con la subvista del consorcio; qué contenido de la
  maqueta "ideal" de About aplica realmente y, por tanto, qué componentes `ula_*` construir.
- **Fase 6:** qué regiones concretas se eliminan; cómo se retira la dependencia `base theme` /
  `bootstrap_italia/base` sin romper lo vivo.

---

## Resumen

El plan lleva el tema, de forma incremental y validada, hasta la **independencia completa de Bootstrap
Italia**. Empieza por el **inventario** de elementos propios vs heredados (Fase 0), parte del **marco
de páginas ya construido** (Fase 1, hecha), adopta un **`page.html.twig` propio** desligándolo de BI
dependencia a dependencia (Fase 2), **adopta los componentes SDC heredados útiles** renombrados y
adaptados (Fase 3), sustituye la **presentación del contenido** de las vistas por componentes `ula_*`
—con investigación previa de vías técnicas y validada con el piloto About— (Fase 4), **replica a todas
las páginas no-home y consolida** el marco en un único `page.html.twig` (Fase 5), **elimina la herencia
muerta** de BI —regiones, librerías, vistas/bloques viejos— hasta poder declarar el tema autónomo
(Fase 6, cambio MAYOR), y aborda el **footer definitivo** editable y unificado con la home (Fase 7,
hito transversal). El **inventario** es el artefacto vivo que guía todo el proceso; la **tolerancia
gestionada a roturas** y la **adopción con renombrado** son las directrices operativas nuevas.
