# Plan de desarrollo — Librería de artefactos y componentes para el body de páginas (inline blocks)

> **Sub-plan** del plan maestro [`plan-sistema-paginas-contenido.md`](plan-sistema-paginas-contenido.md).
> Corresponde a las **Fases 3 y 4 entrelazadas** de ese plan (adopción/creación de componentes SDC
> propios + presentación del contenido sin Bootstrap Italia): desarrolla la **librería de artefactos de
> inline block** (`inline_lb_*`) y los **componentes SDC** que esos artefactos necesiten, para cubrir el
> **body** de las páginas de contenido **complementando** el flujo Views → UI Patterns.
>
> **Base de diseño:** el catálogo de especificación
> [`../../elements/layout/INLINE-BLOCKS-CATALOG.md`](../../elements/layout/INLINE-BLOCKS-CATALOG.md)
> (qué artefactos construir y con qué specs mínimas) y la guía/ADR del mecanismo en
> [`../../elements/layout/CONTENT-LAYOUT.md`](../../elements/layout/CONTENT-LAYOUT.md) §11 (guía A/B/C) y
> §12 (ADR-LAYOUT-005).
>
> **Punto de partida técnico:** la **librería `pilot`** (prueba de concepto del mecanismo A/B/C,
> versionada como caso de uso documental sobre el banco `/about-lb`). No es la librería de producción;
> es el patrón de referencia del que parten estos artefactos.

---

## 1. Premisas (alcance y cautelas)

- **El catálogo no es exhaustivo.** Los artefactos aquí desglosados son los **hoy conocidos** para el
  body de la maqueta de About (más unos candidatos diferidos derivados de la landing). **No** constituyen
  el inventario definitivo del sistema de páginas de contenido: pueden faltar artefactos que solo se
  detectarán al completar las páginas reales del sitio, y las specs de los descritos **pueden ajustarse**.
  Por eso cada artefacto lleva un paso explícito de **validación/ajuste de su especificación** antes de
  implementarlo.
- **Complementario, no sustituto.** Estos artefactos cubren el **body editorial** que **no es una entidad
  del sitio** (prosa, listas, cifras, pastillas, tarjetas sueltas). Las colecciones de entidades y las
  instancias únicas emparejadas por argumento (el hero) se siguen resolviendo con **Views → UI Patterns**
  (§5 de `CONTENT-LAYOUT.md`). Los dos mecanismos **coexisten por sección**.
- **Quedan fuera de este plan** (resueltos por otros mecanismos ya documentados): el **hero** de página
  (vista + `ula_hero`), **Faculty & Research** (vista + `ula_faculty_card` + `ula_carousel`), la **CTA
  band** (bloque `cta_band` + `ula_cta_band`) y el **footer** (marco compartido, Fase 7 del maestro).
- **Independencia de BI (regla general del proyecto).** Ningún artefacto introduce markup ni clases de
  Bootstrap Italia. El texto enriquecido se imprime por **valor procesado** (`…processed|raw`, sin pasar
  por `field.html.twig`, que en este subtema sirve BI). El aspecto lo aportan el design system `ula_*` y
  el CSS propio.

---

## 2. Punto de partida: qué cubre (y qué no) la librería `pilot`

La librería `pilot` implementa los tres mecanismos como prueba de concepto y deja registradas las
lecciones de implementación. Lo que **sí** aporta como patrón reutilizable:

- **A (texto enriquecido):** plantilla de bloque que imprime `campo.0.processed|raw` con guard
  `is not empty`; CSS propio; sin SDC.
- **B (campos → composición de SDC):** composición de `ula_grid_row` (Nivel 1) con N `ula_hero_stat`,
  pasando **valores crudos `.value`** a las **props** del componente, y el slot `content` del grid como
  **secuencia (array) de includes ya renderizados**.
- **C (stack de paragraphs):** bloque con campo Paragraphs renderizado como **campo completo**
  (`{{ content.field_… }}`), con piezas heterogéneas (texto + pastillas), cada una con su plantilla propia.
- **Invariantes:** armazón estándar de bloque (`<div{{ attributes }}>` + `title_prefix` +
  `{% if label %}…{% endif %}` + `title_suffix`) imprescindible para conservar la edición en Layout
  Builder; CSS vía **librería registrada + `attach_library` en plantilla**; en C, el campo Paragraphs debe
  estar en el **view display** del block type.

Lo que el piloto **NO** ejercita y este plan debe resolver:

- **El paso por _slots_** (contenido renderizable a huecos de un SDC). El piloto solo ejercitó composición
  **por props** (B con `ula_hero_stat`). El paso por slots con contenido rico —necesario para
  `inline_lb_cardgrid` sobre `ula_card_simple`— está **sin validar en este contexto** (es la decisión D3).
- **Cualquier SDC de pastilla** (el piloto las pintó con CSS propio, no con un componente).

---

## 3. Método de trabajo por artefacto

Cada artefacto es **código (git)** + **configuración (BD, no versionada)**:

- **Código (se entrega como ficheros enteros, a git):** plantilla(s) de bloque
  `block--block-content--type--inline-lb-*.html.twig`, plantillas de paragraph (en los tipo C), CSS,
  entrada de librería en `bootstrap_ula_lscm.libraries.yml`, y los SDC `ula_*` nuevos/modificados que
  procedan.
- **Configuración (BD, red de seguridad = dump):** tipo de bloque `inline_lb_*`, paragraph types
  `inline_lb_p_*` (tipo C), y campos (storage + field config + form display, **y view display** en los
  tipo C). Se crea con **script de un solo uso** (no versionado, según convención) o por UI.

**Ciclo repetible por artefacto:**

1. **(a) Especificación.** Se presenta la spec concreta del artefacto (estructura, campos, opciones,
   composición, CSS) → el usuario **valida o ajusta** (las specs del catálogo son mínimas y pueden
   cambiar).
2. **(b) Implementación.** Se entregan los ficheros de código completos y el script/pasos de
   configuración. **Antes de tocar configuración: dump de BD** y recordatorio de commit + push.
3. **(c) Validación real.** El usuario aplica y valida en su Drupal real (creación/edición del bloque,
   render sin BI, contraste sobre el fondo previsto).
4. **(d) Documentación al cerrar.** Ficha del tipo de bloque en `docs/entities/`, fichas de SDC nuevos en
   [`../../COMPONENTS.md`](../../COMPONENTS.md), y actualización del catálogo y de `CONTENT-LAYOUT.md` con
   lo realmente construido. Consolidación en git (commit + push). **La subida de versión del tema solo con
   permiso explícito del usuario.**

---

## 4. Decisiones transversales a resolver ANTES de codificar

Bloquean varios artefactos; se resuelven primero. Las marcadas como **estructurales** se registran como
**ADR** al decidirlas (las primeras tres modifican o crean componentes compartidos).

| ID | Decisión | Opciones | Afecta a | ADR |
|---|---|---|---|---|
| **D1** | **Cifra sobre fondo claro.** `ula_hero_stat` es de fondo oscuro (número dorado, etiqueta blanca) → ilegible sobre claro. | (1) prop `tone: light\|dark` en `ula_hero_stat`; (2) clase envolvente del artefacto que sobreescriba el color; (3) componente de cifra claro propio (`ula_stat`). | `inline_lb_statgrid` | Sí |
| **D2** | **Pastilla.** No existe SDC de pastilla. | CSS propio del artefacto (como el piloto) **vs.** crear SDC `ula_pill` / `ula_pill_group` reutilizable. | `inline_lb_pills`, pieza pastilla de `inline_lb_stack` | Sí |
| **D3** | **Paso por slots a `ula_card_simple`.** El piloto solo validó composición por props; el paso por slots con contenido rico no está ejercitado en este contexto. | Validar slots; **plan B** si falla: plantilla de tarjeta propia sin reutilizar el SDC. | `inline_lb_cardgrid` | Sí |
| **D4** | **Texto en panel azul (`panel_blue`).** Forzar color claro de todo el texto y viñetas dentro del panel; no heredar oscuros del tema. | CSS del artefacto que fije el color dentro del panel. | `inline_lb_richtext` | No |
| **D5** | **Modelado de variantes/opciones.** Cómo elige el editor (`plain`/`panel_blue`; `pill`/`tag_card`; nº de columnas/cifras). | Campo de opción (`list_string`) en el bloque, variantes del SDC, o tipos de bloque separados. | richtext, pills, statgrid | No |
| **D6** | **Convención de nombres, campos y librería.** | `inline_lb_*` (block type), `inline_lb_p_*` (paragraph), `field_inline_lb_*` (campos), `.inline-lb-*` (CSS); **una** librería `inline_lb` vs. una por artefacto. | Todos | No |

### 4.bis. Estado de resolución (actualizado al implementar el primer artefacto)

Las decisiones transversales se han ido resolviendo. Resumen vivo (la tabla de arriba es el enunciado
original; esto es el resultado):

- **D1 — Cifra sobre fondo claro: RESUELTA (opción 1).** Prop `tone: light|dark` en `ula_hero_stat`
  (`dark` base = hero intacto; `light` override aditivo). Implementada en `inline_lb_statgrid`. Registrada
  en `COMPONENTS.md` §3.3 y `entities/inline-lb-statgrid.md` §4.
- **D2 — Pastilla: RESUELTA.** Se crea un **SDC reutilizable `ula_pill` / `ula_pill_group`** (no CSS propio
  del artefacto). **Referencia de estilo:** chips/pastillas de `ula_faculty_detail` (no el botón «View
  profile»). Pendiente de implementar (lo necesita `inline_lb_pills`); ADR estructural al implementarlo.
- **D3 — Slots en `ula_card_simple`: RECONVERTIDA en validación diferida.** El mecanismo de paso por slots
  desde la plantilla de un bloque está **confirmado en producción** (`section_header`/`cta_band`), pero con
  **string plano**. Queda validar **solo** el slot `body` con **HTML rico** al construir
  `inline_lb_cardgrid`; **plan B** (plantilla de tarjeta propia) si fallara. No bloquea nada hasta `cardgrid`.
- **D4 — Texto en `panel_blue`: pendiente de implementación (no es decisión).** El CSS del artefacto fuerza
  el color claro dentro del panel; se confirma al implementar `inline_lb_richtext`.
- **D5 — Modelado de opciones: RESUELTO (mecanismo).** Las opciones del editor se modelan como **campo
  `list_string` en el bloque** (fijado por precedente de `statgrid`: `tone`, `cols`). Queda aplicar el
  mecanismo a cada artefacto (qué opciones expone cada uno), no el mecanismo en sí.
- **D6 — Nomenclatura: RESUELTA.** `inline_lb_*` / `inline_lb_p_*` / `field_inline_lb_*` / `.inline-lb-*`.

**Decisiones nuevas del hito (no estaban en la tabla original):**

- **Ritmo vertical del body: RESUELTO → ADR-LAYOUT-006** (`SHARED-FRAME-LAYOUT.md` §9). El marco aporta el
  ritmo (tokens `--lb-section-gap` 2,5rem / `--lb-block-gap` 1,5rem); se retira el `padding-top` de
  `ula_section_header`. Implementado y validado.
- **«Application Roadmap» (richtext): RESUELTA.** No es lista numerada en Basic HTML, sino un **artefacto de
  pasos dedicado** con `ula_timeline_item` (más impactante). A catalogar/planificar como artefacto propio.
- **`inline_lb_pills` — variante: RESUELTA (mecanismo).** `pill` vs `tag_card` mediante **prop `variant`** en
  `ula_pill_group`. Pendiente menor (al implementar): si se contempla ya variante clara para panel oscuro.
- **Cabecera de sección como inline block: AÑADIDA al catálogo** como `inline_lb_section_header` (Opción 1:
  tipo nuevo, reutilizable `section_header` intacto). Ver `INLINE-BLOCKS-CATALOG.md` §3.1. Pendiente de
  implementar; incluye ajustar el selector de ritmo (interacción con ADR-LAYOUT-006).
- **`inline_lb_stack` — composición:** se decide **al implementar** `stack` (qué piezas admite, reutilizar o
  duplicar plantillas).

---

## 5. Desglose de artefactos — alcance inmediato (body de About)

Orden de desarrollo propuesto: **de lo simple a lo complejo**. Cada sección de la maqueta abre con el
bloque `section_header` ya en producción (no es un artefacto nuevo); estos artefactos cubren el body de
debajo.

| # | Artefacto | Tipo | Cubre (maqueta About) | Estructura propuesta (a validar) | SDC | Bloqueado por |
|---|---|---|---|---|---|---|
| 1 | `inline_lb_richtext` | A | «Engineering Edge» (§1), «Application Roadmap» (§5), prosa/listas | 1 campo texto largo (Basic HTML) + opción de tono `plain`/`panel_blue` | — | D4, D5 |
| 2 | `inline_lb_statgrid` | B | `highlight-grid` (§1, 4 cifras), `stat-row` (§3, 3 cifras) | paragraph multivalor {número, etiqueta} + columnas | `ula_grid_row` + `ula_hero_stat` (props) | ✅ **implementado** — ver `entities/inline-lb-statgrid.md` |
| 3 | `inline_lb_pills` | B | `tools` (§2), `role-grid` (§3) como variante | 1 campo string multivalor + opción `pill`/`tag_card` | según D2 | **D2**, D5 |
| 4 | `inline_lb_cardgrid` | C | `card-grid` (§2, 3 tarjetas), `adm-cols` (§5, 2 col.) | stack de paragraph «tarjeta» (título + cuerpo rich) + columnas | `ula_grid_row` + `ula_card_simple` (slots) | **D3** |
| 5 | `inline_lb_stack` | C | secciones que mezclen piezas en un único bloque | campo Paragraphs multivalor: pieza texto + pieza pastilla (ampliable) | reusa piezas de 1 y 3 | requiere 1 y 3 |

**Puntos abiertos por artefacto, a validar en el paso (a) antes de codificar:**

- **richtext (1):** modelado del tono (D5); si la «Application Roadmap» (lista numerada `<ol>`) se cubre
  con Basic HTML dentro de `panel_blue` o se valora un artefacto de pasos dedicado (el catálogo apunta a
  `ula_timeline_item` como alternativa, §6 del catálogo).
- **statgrid (2):** resolución de D1; y si los pares {número, etiqueta} son **fijos** (como el piloto, 4)
  o **multivalor** (nº variable de cifras).
- **pills (3):** resolución de D2; cómo se modela la variante `tag_card` (roles) frente a `pill` (D5);
  previsión de variante clara si fueran a ir sobre panel oscuro.
- **cardgrid (4):** resolución de D3 (validar slots con contenido rico antes de comprometer el diseño);
  viñetas ✓ doradas de `adm-cols` como estilo de lista en el CSS.
- **stack (5):** qué piezas admite de inicio (texto + pastilla, el piloto generalizado) y si se reutilizan
  las **mismas plantillas/partials** que los artefactos 1 y 3 o se duplican (decidir el solape
  bloque-suelto vs. pieza-en-stack).

---

## 6. Tranche diferido — candidatos de la landing

**Fuera del alcance inmediato.** Se anotan para no perderlos, no para hacerlos ahora. Todos tipo B
prop-based, reutilizando SDC existentes (composición ya validada por el piloto); coste marginal bajo una
vez hecho `statgrid`, pero con sus avisos de contraste propios (§6 del catálogo):

| Artefacto candidato | Tipo | SDC reutilizable | Nota de contraste |
|---|---|---|---|
| `inline_lb_featuregrid` | B | `ula_feature_item` | verificar fondo de la sección destino |
| `inline_lb_whygrid` | B | `ula_why_item` | la sección origen (landing) es **oscura**; leer claro sobre oscuro |
| `inline_lb_timeline` | B/C | `ula_timeline_item` | candidato para «Application Roadmap» (§5) en vez de lista numerada |
| `inline_lb_reqgrid` | B | `ula_req_card` | candidato para «Academic Background»/«Technical Skills» (§5) si se quiere icono |

---

## 7. Inventario de componentes SDC implicado

Mayoritariamente **reutilización**; **0–2 SDC nuevos/modificados** según se resuelvan D1 y D2.

| Componente | Acción | Para |
|---|---|---|
| `ula_grid_row` | Reutilizar | Nivel 1 de statgrid y cardgrid |
| `ula_hero_stat` | Reutilizar **o modificar** (según D1) | statgrid |
| `ula_card_simple` | Reutilizar por **slots** (validar D3) | cardgrid |
| `ula_pill` / `ula_pill_group` | **Posible nuevo** (según D2) | pills, pieza pastilla del stack |
| `ula_stat` (claro) | **Posible nuevo** (alternativa de D1) | statgrid |
| `ula_section_header` | Reutilizar (ya en producción) | cabecera de cada sección |

---

## 8. Maquetas (cuándo se necesitan)

- **No** se necesitan para el trabajo de **mecanismo y estructura** (tipos de bloque, campos, plantillas,
  composición de SDC, view displays, armazón de inline block, anti-BI): bastan el catálogo, la librería
  `pilot` y los SDC existentes.
- **Sí** se necesitan para **fijar y ajustar la spec visual de cada artefacto y escribir su CSS con
  fidelidad**, porque el catálogo da specs **mínimas** de estilo y pueden ajustarse. En particular: el
  **panel azul** de `richtext` (Edge/Roadmap), la **tarjeta** de `cardgrid` (hover, viñetas ✓, layout 2/3
  columnas), el `tag_card` de roles en `pills`, y el layout/medidas del `statgrid`.
- **Cuándo:** al entrar en el paso (a) de cada artefacto. Fuente principal: la maqueta de **About**
  (alcance inmediato); la de la **landing** solo para el tranche diferido (§6). Formato preferido: HTML/CSS
  (permite leer medidas y colores exactos); también valen imágenes o PDF.

---

## 9. Estado y próximos pasos

- **Estado:** decisiones transversales **resueltas** (ver §4.bis). **Implementado y validado:**
  `inline_lb_statgrid` (primer artefacto, patrón B) y el **ritmo vertical del body** (ADR-LAYOUT-006).
  Documentado y consolidado.
- **Versión del tema — salto diferido (decisión).** El tema **no** sube de versión por artefactos sueltos:
  permanece en **v1.7.0** mientras la librería de inline blocks está en desarrollo. El salto
  (previsiblemente **v1.8.0**, MINOR) se hará **al completar la librería**, en un único hito de versión que
  recoja todos los artefactos. Por eso `.info.yml` y la tabla de versiones de `ARCHITECTURE.md` no se tocan
  en cada artefacto.
- **Próximo paso:** implementar el resto de la librería de lo simple a lo complejo —
  `inline_lb_section_header` (cabecera como inline block, §3.1 del catálogo; incluye ajustar el selector de
  ritmo), `inline_lb_richtext` (+ artefacto de pasos `ula_timeline_item`), `inline_lb_pills` (con el nuevo
  SDC `ula_pill`/`ula_pill_group`), `inline_lb_cardgrid` (validando el slot `body` rich, D3) y, al final,
  `inline_lb_stack`.

> **Recordatorios de método (del proyecto):** dump de BD antes de tocar configuración; commit + push por
> hito; documentar al cerrar (no antes); no subir versión del tema sin permiso explícito; trabajar de lo
> simple a lo complejo y validar cada artefacto en el Drupal real antes de consolidar.
