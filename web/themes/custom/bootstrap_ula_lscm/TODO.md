# TO-DOs — Tema Bootstrap ULA LSCM

> Pendientes **transversales** del tema (afectan a todo el proyecto, no a una página concreta).
> Los pendientes específicos de una parte viven junto a su documentación
> (p.ej. los de la home, en `docs/elements/home/HOME-ARCHITECTURE.md` §5).

## Abiertos

### 1. Avisos `Deprecated` de Gutenberg en la salida de drush
Cada comando `ddev drush ...` imprime avisos de obsolescencia del módulo `gutenberg`
(`_gutenberg_is_gutenberg_enabled()` y otros), que ensucian la salida.
**Opciones a explorar:** actualizar el módulo `gutenberg` a una versión compatible con
la versión de PHP del entorno, o ajustar `error_reporting` para ocultar `E_DEPRECATED`.
**Prioridad:** baja (es ruido, no afecta a funcionalidad).

### 2. Actualización de seguridad de Drupal
Considerar aplicar las actualizaciones de seguridad de Drupal core/contrib cuando proceda.
**Antes de hacerlo:** commit + push del estado actual y dump de BD, como red de seguridad.
**Prioridad:** media (revisar periódicamente).

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

### 9. Rediseñar `hero_view` a filtro contextual (un solo view para todos los heros)
Hoy `hero_view` tiene el término **fijo** en el filtro (`field_hero_page = About`), de modo que **solo
sirve para el hero de About**: añadir un hero a otra página obliga a duplicar la vista. Rediseñarla para
que reciba el término (o el nodo de la página) **como argumento** vía **filtro contextual**, de modo que
**una sola vista** sirva el hero de cualquier página.
**Incógnita a validar primero (en el Drupal real):** cómo Layout Builder pasa el argumento (el nodo de la
página actual) al bloque de la vista — es la incógnita que se aplazó al elegir taxonomía fija (ver
`docs/elements/layout/CONTENT-LAYOUT.md` §5.7). No hay ninguna vista con filtro contextual en el sitio de
la que partir.
**Cuando se aborde:** validar la incógnita; luego reconfigurar la vista (quitar filtro fijo, añadir
contextual) — **configuración, dump previo** — y actualizar `CONTENT-LAYOUT.md` §5.7 y `entities/hero.md`.
**Prioridad:** media (evolución del patrón del hero; desbloquea reutilizarlo en más páginas).

### 10. Componente propio `ula_cta_band` (franja de cierre / llamada a la acción)
La maqueta de About termina con una **franja CTA** (fondo azul, título + texto + un botón), distinta del
hero: otro rol (cierre, no cabecera), más simple, y puede aparecer en cualquier página e incluso varias
veces. Modelarla como **componente SDC propio nuevo** (`ula_cta_band`; slots `title`/`text`/`actions`,
full-bleed, tokens propios), **no** como variante de `ula_hero` (forzaría el concepto).
**A decidir en su mini-análisis:** el mecanismo de colocación/alimentación — bloque de UI Patterns colocado
en Layout Builder (hay `ui_patterns_blocks`) con el texto escrito en la config del bloque, vs. bloque de
contenido en línea con campos. **No** modelarlo con vista-por-término (no es "uno por página").
**Documentación:** ficha en `COMPONENTS.md` + un **ADR** que fije la distinción `ula_hero` (cabecera) vs
`ula_cta_band` (franja de cierre), para no confundir cuándo usar cada uno.
**Prioridad:** media (componente nuevo del design system).

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
| `consortium_universities` | Vista (display de bloque `block_1`, row UI Patterns) | `views.view.consortium_universities` | **Conservar / decidir** — referencia que funciona y posible base de la vista real; no purgar sin decidir |
| Universidades del consorcio | Contenido real (no andamiaje) | `ct_about_consortium_university` — 3 nodos | **Conservar** — contenido real del sitio |

## Resueltos

- **Componente propio `ula_card_simple` (antiguo TO-DO #7).** Construido y validado: tarjeta del design
  system `ula_*` por slots (ver `docs/COMPONENTS.md` §1.1), sustituta de la heredada `card2_simple` (BI).
  Su **adopción** en las vistas existentes (p. ej. universidades, que aún usan la heredada) queda como paso
  de migración posterior (ver `docs/elements/layout/CONTENT-LAYOUT.md` §9.2).
- **Reparto del CSS monolítico (21 KB) al trocear en componentes SDC.** Resuelto con el
  sistema de tres capas: tokens globales (`ula_tokens`) + base de la landing
  (`ula_landing_base`) + CSS por componente. Ver `docs/elements/home/HOME-ARCHITECTURE.md` §3.
