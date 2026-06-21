# TO-DOs — Tema Bootstrap ULA LSCM

> Pendientes **transversales** del tema (afectan a todo el proyecto, no a una página concreta).
> Los pendientes específicos de una parte viven junto a su documentación
> (p.ej. los de la home, en `docs/elements/home/HOME-ARCHITECTURE.md` §5).

## Abiertos

### 1. Avisos `Deprecated` de Gutenberg en la salida de drush
Cada comando `ddev drush ...` imprime avisos de obsolescencia del módulo `gutenberg`
(`_gutenberg_is_gutenberg_enabled()` línea 1405 de `gutenberg.module`, y otros en
`MappingFieldsHelper`, `BlockParser`…), que ensucian la salida. Es el patrón PHP 8.4
«Implicitly marking parameter $x as nullable is deprecated, the explicit nullable type
must be used instead» (parámetros con default `null` sin tipo nullable explícito `?Tipo`).

**Análisis (jun-2026, verificado en drupal.org):**
- Incidencia oficial: **#3536161** «[PHP 8.4] Deprecation warning at
  `_gutenberg_is_gutenberg_enabled()` and other places» — estado **Closed (fixed)**.
- El arreglo (marcar los parámetros como nullable explícitos) se **comiteó a la rama
  `3.0.x`** el **19-feb-2026** (commit `3d26a06d`, vía MR !243; también a `4.0.x`).
- PERO la última **release etiquetada** de la 3.x es **3.0.6 (23-ene-2025)**, anterior al
  fix. No existe 3.0.7. Por eso la 3.0.6 instalada **sigue** emitiendo el aviso: el fix
  vive solo en `3.0.x-dev`, sin publicar.

**Decisión: Vía D — esperar la release.** No se introduce infraestructura de parcheo solo
por un aviso cosmético. Cuando los mantenedores etiqueten una **3.0.7+** (o al migrar a
4.x) con el fix, resolver con un simple `ddev composer update drupal/gutenberg -W` y
validar el editor en un nodo que use Gutenberg.

**Alternativa descartada (por desproporcionada para algo cosmético):** aplicar el diff del
fix (MR !243 / commit `3d26a06d`) sobre 3.0.6 mediante `cweagans/composer-patches`. Solo
reconsiderar si el ruido llega a estorbar de verdad en el día a día; verificar entonces que
el parche aplica limpio sobre la versión instalada.

**Prioridad:** baja (es ruido, no afecta a funcionalidad).

### 2. Actualización de seguridad de Drupal
**Hecho (jun-2026):** core actualizado **11.3.8 → 11.3.12**, que cierra lo crítico de core
—SA-CORE-2026-004 (SQL injection, altamente crítica), 005 (PHP object injection), 006, 007,
008, 009— y arrastra twig y symfony/* a versiones parcheadas. `guzzlehttp/psr7` subido a
**2.12.1** mediante alias en línea (`2.12.1 as 2.10.4`), parcheado de verdad.

**Residuo aceptado a sabiendas:** quedan **dos advisories de severidad MEDIA en
`guzzlehttp/guzzle`** —`PKSA-93qv-9n9h-6k6p` (CVE-2026-55767, dot-only cookie domains) y
`PKSA-k22t-f949-t9g6` (CVE-2026-55568, downgrade silencioso de proxy HTTPS)— exceptuadas vía
`config.policy.advisories.ignore-id` en `composer.json` (con su motivo documentado). Causa: el
fix de guzzle (7.12.1) exige `promises ^2.5`, que choca con el `promises ~2.3.0` que clava
`drupal/core-recommended` 11.3.12 (rangos disjuntos, no resoluble con alias sin abandonar
core-recommended). Las dos son medias y de bajo impacto para este sitio.

**Condición de cierre:** al pasar a **11.4.0** (programada para la semana del 22-jun-2026) o a
un **11.3.x que reempaquete guzzle/promises**, (a) retirar las dos entradas de `ignore-id` de
`composer.json`, (b) subir guzzle a ≥7.12.1 (y quitar el alias de psr7 si core ya lo cubre), y
(c) verificar que `ddev exec composer audit` queda **limpio** (0 advisories, ni ignoradas).
Incidencias drupal.org de seguimiento: #3599842 (psr7), #3600889 (quitar restricciones de minor
de core-recommended).

**Antes de cualquier actualización futura:** commit + push del estado actual y dump de BD, como
red de seguridad.
**Prioridad:** media (revisar periódicamente; lo crítico ya está cerrado, queda el residuo de
guzzle).

### 3. Errores de renderizado en la galería UI Patterns
En `/admin/appearance/ui/components` la previsualización de algunos componentes muestra
errores `Array to string conversion` y volcados de objetos `Drupal\Core\Template\Attribute`.
**No es un problema de los SDC propios (`ula_*`)**: parece un comportamiento general de la
galería al previsualizar componentes que reciben/emiten objetos `Attribute`. No afecta al
render real en la página, solo a la previsualización en la galería.
**Prioridad:** baja.

### 4. Valorar adoptar gestión de configuración (config/sync)
El sitio no usa config/sync: la configuración vive solo en BD y se respalda con dumps
(ver `docs/elements/home/HOME-ARCHITECTURE.md` §7.1). Valorar si conviene adoptarla, dado
que ya se usa git para el código. Pros: versionar la config, despliegues reproducibles.
Contras: disciplina añadida, fricción conocida con `config:import` y dependencias de módulos.
Es la vía para cerrar la fragilidad estructural "código en git / config solo en BD".
**Reforzado (v1.5.1):** adoptar Layout Builder para las páginas no-home (ADR-LAYOUT-004) **aumenta** la
configuración no versionada en BD (composición de páginas, vistas, mapeos a componentes), lo que da más
peso a valorar esta vía.
**Prioridad:** media (decisión de arquitectura, no urgente).

### 5. Componentes residuales sin uso en `components/`
Quedan tres componentes que no forman parte del design system `ula_*` ni se usan en la
home: `avatar_fixed`, `modal_fixed`, `timeline_fixed`. Revisar si son restos de pruebas y,
si se confirma que no se usan en ninguna parte, eliminarlos para no dejar deuda.
**Prioridad:** baja (limpieza).

### 6. Eliminar la vista heredada `page_home`
Vista de Drupal heredada que servía la home antigua, hoy sustituida por la home como nodo +
plantilla Twig (ADR-001). Era la **Fase 0** del plan de colecciones editables (ya completado y
archivado); se reconvirtió en este TO-DO transversal. **Condición:** ejecutarla cuando se haya
**avanzado en la independencia de Bootstrap Italia**, ya que es una limpieza de configuración
heredada que encaja en ese trabajo de desvinculación. **Antes de tocarla:** dump de BD (la vista
es configuración, vive solo en BD) y verificar qué se pierde. Análisis original en
`docs/elements/home/HOME-ARCHITECTURE.md` §5.4.
**Prioridad:** baja (condicionada al avance de independencia de BI).

### 8. Limpiar el andamiaje del piloto Paragraphs-vs-Layout-Builder en BD
Durante la valoración del mecanismo de composición de las páginas no-home se crearon elementos de
prueba que conviene **purgar** para dejar la BD limpia (se seguirán haciendo pruebas, conviene higiene):
- Nodo `/about-lb` (nid 92, tipo `lb_test`) y los bloques de su Layout Builder.
- Tipo de contenido `lb_test`, **si** no se adopta como tipo definitivo de las páginas no-home
  (ver `docs/elements/layout/CONTENT-LAYOUT.md` §9.3).
- Tipo de contenido `content_page` (basado en Paragraphs, `field_sections`) y su nodo, creados para
  comparar Paragraphs frente a Layout Builder; descartada esa vía (ADR-LAYOUT-004), son andamiaje
  huérfano.

**No** purgar la vista `consortium_universities` sin decidir antes su continuidad (es la referencia que
funciona y posible base de la vista real). **Antes de tocar:** dump de BD (es configuración + contenido)
y confirmar qué se pierde.
**Prioridad:** baja (higiene; condicionada a decidir el tipo de contenido definitivo y a rehacer About).
**Detalle:** ver la tabla *Inventario de gadgets del piloto* más abajo (qué purgar y qué conservar).
**Actualización (v1.7.0):** ya existe una **vista real derivada en producción**, `faculty_cards` (sección
Faculty & Research de `/about`), construida tomando `consortium_universities` como referencia (flujo
Views → UI Patterns, ver `docs/elements/layout/CONTENT-LAYOUT.md` §5). Por tanto `consortium_universities`
**ya no es la única** referencia viva del patrón: la decisión de conservarla o purgarla puede tomarse con
menos riesgo. Sigue sin purgarse sin decisión explícita, pero la condición que la retenía se ha debilitado.

### 12. Fondo `--off-white` a nivel de marco para páginas de contenido
Las páginas de contenido (empezando por la ficha de faculty `/faculty/...` y la sección de tarjetas de
`/about`) ganan legibilidad si las **tarjetas blancas** resaltan sobre un fondo **`--off-white`** del marco,
de forma **continua hasta el footer**. Se probó aportar ese lienzo desde el **componente** (full-bleed) y se
**descartó**: producía una **discontinuidad blanca** entre el final del componente y el footer. La decisión es
implementarlo a **nivel de marco** (la región de contenido / `body` del marco de páginas, no el componente),
de modo que el off-white sea continuo bajo todo el contenido hasta el footer.
**Antes de hacerlo:** localizar el punto del marco (`lscm_page` / `page.html.twig` / región de contenido) y
verificar que no rompe páginas que hoy asumen fondo blanco.
**Prioridad:** media (afecta a la presentación de todas las páginas de contenido).

## Inventario de gadgets del piloto (Paragraphs vs Layout Builder)

Foto de los elementos creados durante el piloto de composición de páginas no-home, con su tipo y
disposición. Es el detalle del TO-DO #8 (purga). **Solo son configuración/contenido en BD, no están en
git.** Antes de purgar: **dump de BD**.

| Gadget | Tipo de elemento | Identificador | Disposición |
|---|---|---|---|
| `lb_test` | Tipo de contenido (Layout Builder por override) | bundle `lb_test` — 1 nodo | **Purgar** si no se adopta como tipo definitivo (ver `docs/elements/layout/CONTENT-LAYOUT.md` §9.3) |
| `/about-lb` | Nodo | nid 92, tipo `lb_test` | **Purgar** (banco de pruebas multi-sección) |
| Bloques del layout del nodo 92 | Bloques de Layout Builder | `carousel_item`, `views_block` (×2), `field_block:…:type` (×2), `extra_field_block:…:links` | **Purgar** (caen con el nodo 92) |
| `content_page` | Tipo de contenido (Paragraphs, vía `field_sections`) | bundle `content_page` — 1 nodo | **Purgar** — andamiaje de la valoración Paragraphs vs LB; vía descartada (ADR-LAYOUT-004) |
| Nodo de `content_page` | Nodo | 1 nodo (tipo `content_page`) | **Purgar** (con su tipo) |
| `consortium_universities` | Vista (display de bloque `block_1`, row UI Patterns) | `views.view.consortium_universities` | **Conservar / decidir** — referencia que funciona; ya **no es la única** (existe `faculty_cards` derivada en producción, v1.7.0); decidir continuidad antes de purgar |
| Universidades del consorcio | Contenido real (no andamiaje) | `ct_about_consortium_university` — 3 nodos | **Conservar** — contenido real del sitio |

## Resueltos

- **Componente propio `ula_section_header` (antiguo TO-DO #11).** Construido y validado: cabecera de sección
  (slots `tag`/`title`/`description`; tag con rayita dorada, título en cuerpo-negrita —no display—,
  descripción opcional). Se alimenta de un **tipo de bloque de contenido** `section_header` (campos
  `field_section_tag`/`field_section_title`/`field_section_description`) colocado en Layout Builder, compuesto
  vía `block--block-content--type--section-header.html.twig`. La plantilla **guarda los campos opcionales con
  `isEmpty`** (leer `.value` de un campo vacío rompía el render). Documentado en `COMPONENTS.md` §1.5,
  `entities/section-header.md`, `CONCEPTOS-DRUPAL.md` e inventario. Los ejemplares de About se crearon con un
  **script de un solo uso** (no versionado). **El block type y sus ejemplares son configuración (BD)**; el
  componente y la plantilla son código (git).
- **Componente propio `ula_cta_band` (antiguo TO-DO #10).** Construido y validado: franja/tarjeta de cierre
  (CTA) antes del footer (slots `title`/`text`/`actions`; borde azul marcado + fondo claro; **no** full-bleed,
  ocupa el ancho del contenedor). Se alimenta de un **tipo de bloque de contenido** `cta_band` (campos
  `field_cta_title`/`field_cta_text`/`field_cta_link`) colocado en Layout Builder, compuesto vía la plantilla
  `block--block-content--type--cta-band.html.twig` (nombre confirmado con el debug de Twig). Decisión: pieza
  nueva e independiente del hero (ADR en `docs/entities/cta_band.md`). Documentado en `COMPONENTS.md` §1.4,
  `entities/cta_band.md`, `CONCEPTOS-DRUPAL.md` e inventario. **El block type y sus ejemplares son
  configuración (BD)**; el componente y la plantilla son código (git).
- **`hero_view` rediseñada a filtro contextual (antiguo TO-DO #9).** El hero ya **no** se empareja con la
  página por un término fijo, sino con un **filtro contextual** sobre `field_target_page` (referencia al
  **nodo** de la página) con valor por defecto «ID de contenido desde la URL». **Una sola vista sirve el
  hero de cualquier página**, sin duplicarla. La incógnita de cómo LB pasaba el argumento se disolvió: «ID
  de contenido desde la URL» lee el nodo de la ruta, no el contexto de LB (validado en `/about`). Cambio de
  modelo: el campo de término `field_hero_page` se sustituyó por `field_target_page` (nodo). Documentado en
  `docs/elements/layout/CONTENT-LAYOUT.md` §5.7 y `docs/entities/hero.md`. **Es configuración (BD)**: la
  vista y el campo viven en la base de datos, no en git.
- **Componente propio `ula_card_simple` (antiguo TO-DO #7).** Construido y validado: tarjeta del design
  system `ula_*` por slots (ver `docs/COMPONENTS.md` §1.1), sustituta de la heredada `card2_simple` (BI).
  Su **adopción** en las vistas existentes (p. ej. universidades, que aún usan la heredada) queda como paso
  de migración posterior (ver `docs/elements/layout/CONTENT-LAYOUT.md` §9.2).
- **Reparto del CSS monolítico (21 KB) al trocear en componentes SDC.** Resuelto con el
  sistema de tres capas: tokens globales (`ula_tokens`) + base de la landing
  (`ula_landing_base`) + CSS por componente. Ver `docs/elements/home/HOME-ARCHITECTURE.md` §3.
