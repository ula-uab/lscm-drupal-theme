# Entidad — bloque de contenido `inline_lb_richtext` (texto enriquecido)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque de
> contenido** (`block_content`) colocado como **inline block de Layout Builder**. · **Mecanismo:** patrón A
> (texto enriquecido; **no** compone SDC). Modelado sobre el `pilot_richtext` de referencia. Ver
> `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.1 y la guía de inline blocks de
> `../elements/layout/CONTENT-LAYOUT.md` (§11).

---

## 1. Qué es y por qué existe

`inline_lb_richtext` modela **body en prosa** (párrafos, listas, encabezados intermedios) editable en la
propia página. Cubre el texto libre de las secciones y, en particular, el **panel destacado** «The
Engineering Edge» (§1 de la maqueta). Es el patrón **A**: texto enriquecido directo, sin componer SDC; el
aspecto lo da el CSS propio.

**Dos variantes (campo `variant`), por el contraste.** El mismo «artefacto de texto» aparece en dos fondos
opuestos: prosa normal sobre fondo claro, y el panel «Edge» sobre azul con texto blanco. Para no inventar un
artefacto por fondo, se modela una **opción de presentación** (decisión transversal D5: `list_string` en el
bloque): `plain` (sin caja) y `panel_blue` (caja azul con texto claro).

---

## 2. Campos (tipo de bloque `inline_lb_richtext`)

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| **Block description** (base) | — | 1 | Nombre administrativo. No se muestra. |
| `field_inline_lb_rt_body` | text_long (Basic HTML) | 1 | El contenido enriquecido. Formato restringido a Basic HTML (anti-BI). |
| `field_inline_lb_rt_variant` | list_string (`plain`/`panel_blue`) | 1 | Presentación. Por defecto `plain`. |

> **Nota de implementación (BD):** el campo `field_inline_lb_rt_variant` (List text) se creó **por la UI** de
> Drupal, no por script — ver nota transversal en `../ARCHITECTURE.md` (crear `list_string` por
> `FieldStorageConfig::create()` falla en este sitio).

---

## 3. Cómo se consume (lógica en el tema)

Plantilla `templates/content/block--block-content--type--inline-lb-richtext.html.twig`, con el **armazón
estándar de bloque** (imprescindible en un inline block; ver `inline-lb-section-header.md` §3).

- **Anti-BI:** imprime `field_inline_lb_rt_body.0.processed|raw` (aplica el filtro de Basic HTML, que no
  inyecta clases ni markup de BI) sin pasar por `field.html.twig`.
- **Variante → clase modificadora:** la plantilla escribe `inline-lb-richtext--{{ variant }}` (`_`→`-`). El
  aspecto lo da `css/inline-lb-richtext.css`, registrado como **librería `inline_lb_richtext`** y adjuntado
  con `attach_library` (mecanismo CSS-propio del piloto: librería + attach_library, §11.4.2 de
  `CONTENT-LAYOUT.md`). `panel_blue` fuerza todo el texto en claro sobre el degradado azul.

> **Configuración en BD, no en git.** Tipo de bloque, campos y ejemplares en BD; el repo versiona la
> plantilla, el CSS y la librería. Dump previo obligatorio.

---

## 4. Pendiente conocido

> **[PENDIENTE] Variante «Panel azul» no se ve correctamente.** La variante `plain` funciona; `panel_blue`
> no renderiza bien (a diagnosticar: carga de la librería vía `attach_library`, aplicación de la clase
> `--panel-blue`, o los estilos del panel). El `plain` es el caso validado; el panel queda como deuda.

## 5. Relación con otros

- **vs. `inline_lb_steps`:** la «Application Roadmap» **no** se cubre con una lista numerada en `panel_blue`,
  sino con el artefacto de pasos dedicado (`inline-lb-steps.md`), más impactante.
- **Reutilizado por `inline_lb_stack`:** la pieza de texto del stack reutiliza la clase
  `.inline-lb-richtext--plain` y su librería.
