# Inventario de elementos: propios vs heredados (de cara a la independencia de Bootstrap Italia)

> **Tipo de documento:** análisis (Fase 0 del plan maestro de independencia de BI,
> `../plans/paginas-contenido/plan-sistema-paginas-contenido.md`).
>
> **Propósito.** Catalogar el estado actual del tema `bootstrap_ula_lscm` distinguiendo los **elementos
> propios** de los **heredados de Bootstrap Italia (BI)**, para guiar el proceso de independencia. Es el
> **mapa** sobre el que se decide qué se adapta/rehace como propio y qué se elimina al final.
>
> **Artefacto vivo.** Este inventario se mantiene actualizado: cada vez que un elemento cambia de estado
> (heredado → adoptado/propio, o se elimina), se refleja aquí.
>
> **Principio rector (importante).** Las **páginas heredadas son la especificación viva** de qué
> necesitamos: mientras existan, nos dicen qué componentes heredados están en uso real y, por tanto,
> cuáles hay que cubrir con piezas propias. Por eso se inventarían **antes** de eliminarlas, y solo se
> eliminan al final, cuando su contenido ya está cubierto por elementos propios. Este inventario es la
> fotografía de esa especificación.

> **Leyenda de estado:**
> - **Propio** — diseñado por nosotros (nativo del tema).
> - **Heredado (en uso)** — de BI, usado por alguna página viva: candidato a **adaptar/rehacer** como
>   propio o a **sustituir** por diseño nuevo.
> - **Heredado (muerto)** — de BI, sin uso en ninguna página viva: candidato a **eliminación** directa
>   en la fase final (Fase 6), sin necesidad de sustituto.

---

## 1. Resumen

| Categoría | Total | Propios | Heredados en uso | Heredados muertos |
|---|---|---|---|---|
| **Componentes SDC** | 79 | 20 | 21 | 38 |
| **Plantillas** (`templates/`) | 15 | 15 | 0 | — (el `page.html.twig` propio sustituye al de BI desde v1.5.0; no hay plantillas heredadas) |
| **Librerías cargadas globalmente** | 6 | 3 | 3 | — |

> Estas cifras cuentan **elementos de producción**. Aparte, el repositorio versiona **material de
> referencia del piloto** de inline blocks —5 plantillas en `templates/content/` (§3) y la librería
> `pilot` (§4)—, marcado como **caso de uso documental, no producción** (ver
> `../elements/layout/CONTENT-LAYOUT.md` §11–§12); **no** se suma a estos totales.

El grueso del trabajo de independencia, a nivel de componentes, se concentra en los **21 componentes
heredados en uso**: de ellos saldrá la lista de piezas propias a crear (adaptando o rehaciendo). Los
**38 muertos** se eliminan al final sin más. Los **20 propios** ya están (los 12 iniciales + `ula_card_simple`,
`ula_grid_row`, `ula_hero`, `ula_cta_band` y `ula_section_header`, añadidos para el modelo de contenido de
páginas no-home con Layout Builder; más `ula_faculty_detail`, `ula_faculty_card` y `ula_carousel`, añadidos al
modelar la entidad Faculty).

---

## 2. Componentes SDC (`components/`)

### 2.1. Propios (20)

Diseñados por nosotros. No requieren acción de independencia (ya son propios); se listan para
completitud y para fijar la convención de nombres.

| Componente | Tipo | Notas |
|---|---|---|
| `ula_feature_item` | Design system (`ula_*`) | Componente de contenido de la home |
| `ula_hero_stat` | Design system (`ula_*`) | Estadística destacada |
| `ula_req_card` | Design system (`ula_*`) | Tarjeta de requisito |
| `ula_sem_card` | Design system (`ula_*`) | Tarjeta de semestre |
| `ula_spec_card` | Design system (`ula_*`) | Tarjeta de especialización |
| `ula_timeline_item` | Design system (`ula_*`) | Ítem de cronología |
| `ula_uni_card` | Design system (`ula_*`) | Tarjeta de universidad |
| `ula_why_item` | Design system (`ula_*`) | Ítem "por qué" |
| `ula_card_simple` | Design system (`ula_*`, basado en slots) | Tarjeta genérica reutilizable para fondo claro; acepta campos renderizados (flujo Views → UI Patterns) |
| `ula_grid_row` | Design system (`ula_*`, basado en slots) | Rejilla propia de columnas de igual altura; sustituye a `grid_row` (BI) como Format de vista |
| `ula_hero` | Design system (`ula_*`, basado en slots) | Hero/cabecera de página; dos presentaciones vía prop `size` (page/home); reutiliza `ula_hero_stat` por composición para las stats |
| `ula_cta_band` | Design system (`ula_*`, basado en slots) | Franja/tarjeta de cierre (CTA) antes del footer; borde azul + fondo claro; se alimenta de un `block_content` `cta_band` vía plantilla que lo compone (v1.6.2) |
| `ula_section_header` | Design system (`ula_*`, basado en slots) | Cabecera de sección (tag con rayita dorada + título cuerpo-negrita + descripción opcional); se alimenta de un `block_content` `section_header` vía plantilla que lo compone (v1.6.3) |
| `ula_faculty_detail` | Design system (`ula_*`, **bespoke por props**) | Ficha de detalle de un miembro del Faculty (página `/faculty/...`); se alimenta de una plantilla de nodo + preprocess con valores crudos, no por slots (ver `../entities/faculty-member.md` §4.1) |
| `ula_faculty_card` | Design system (`ula_*`, basado en slots) | Tarjeta de un miembro del Faculty para el carrusel de `/about`; Nivel 2 del flujo Views → UI Patterns; retrato foto-o-iniciales (v1.7.0) |
| `ula_carousel` | Design system (`ula_*`, basado en slots) | Contenedor de Nivel 1 (carrusel con flechas/puntos/swipe, sin autoplay); alternativa a `ula_grid_row` como Format de vista (v1.7.0) |
| `lscm_page_header` | Marco de páginas (`lscm_*` propio) | Header del marco de páginas de contenido (Fase 1) |
| `lscm_page_footer` | Marco de páginas (`lscm_*` propio) | Footer provisional del marco (Fase 1) |
| `lscm-master-page` | Marco de la home (`lscm-*` propio) | Marco de la home |
| `lscm-master-static` | Maqueta de referencia (`lscm-*` propio) | Maqueta original; no en producción |

> **Convención de nombres.** `ula_*` se reserva en adelante para **desarrollos nuevos**. Los `lscm_*` /
> `lscm-*` aquí listados son propios pero nacieron antes de fijar esa convención (marco). Cuando se
> adopte un componente heredado y se haga propio, se renombrará con prefijo `ula_*` y pasará a esta
> tabla.

### 2.2. Heredados de BI EN USO (21) — candidatos a adaptar/rehacer

Componentes de Bootstrap Italia que **alguna página viva usa** (vía Views + UI Patterns). Cada uno es
una pieza que habrá que **adaptar como propia** (renombrándola `ula_*`) o **sustituir** por diseño
nuevo, al migrar las páginas que la usan. La columna "usado por" indica las vistas donde aparece (la
especificación viva).

| Componente BI | Usado por (vistas) | Observación para la independencia |
|---|---|---|
| `grid_row` | page_about, page_about_consortium, page_admission, page_alumni, page_contents, page_contents_*_semester (4), page_home, page_home_cards | El más transversal: contenedor de rejilla. Pieza estructural clave a rehacer como propia |
| `card` | page_about, page_home_cards, test | Tarjeta básica |
| `card2_simple` | page_about_consortium, page_elegibility_admission_requirements | Variante de tarjeta |
| `card2_big` | page_contents | Variante de tarjeta grande |
| `modal2` | page_about_consortium, page_contents_*_semester (4) | Modal (ventana emergente) |
| `point_list2` | page_admission, page_contents | Lista de puntos |
| `table` | page_elegibility_criteria, page_elegibility_ranks | Tabla |
| `table_row` | page_elegibility_criteria, page_elegibility_ranks | Fila de tabla |
| `table_cell` | page_elegibility_criteria, page_elegibility_ranks | Celda de tabla |
| `accordion` | page_admission_pre_timeline, page_admission_reg_timeline, page_faq_group | Acordeón |
| `accordion_item` | page_admission_pre_timeline, page_admission_reg_timeline, page_faq_group | Ítem de acordeón |
| `timeline2` | page_admission_pre_timeline, page_admission_reg_timeline | Cronología |
| `timeline_item2` | page_admission_pre_timeline, page_admission_reg_timeline | Ítem de cronología |
| `alert2` | page_elegibility | Aviso/alerta |
| `grid_row_2` | page_elegibility, page_student_hub | Variante de rejilla |
| `hero2` | page_home | Hero (cabecera destacada) |
| `toast` | page_home | Notificación tipo toast |
| `toast_container` | page_home | Contenedor de toasts |
| `button2` | page_home_cards | Botón |
| `avatar2` | view_page_experiences | Avatar |
| `academic_calendar` | page_student_hub | Calendario académico (posiblemente específico del proyecto, a analizar) |

> **Notas:**
> - `page_home` y `page_home_cards` corresponden a la **home heredada** (la vista `page_home` está en el
>   TODO #6 para eliminar, ya sustituida por la home propia nodo+Twig). Sus componentes se inventarían
>   igualmente, pero su eliminación va ligada a esa limpieza.
> - `test` es una vista de pruebas; a revisar si debe conservarse.
> - `academic_calendar` no parece un componente genérico de BI; conviene analizar su origen (podría ser
>   un componente a medida del desarrollo previo).

### 2.3. Heredados de BI SIN USO (38) — herencia muerta, candidatos a eliminar

Componentes de Bootstrap Italia que **ninguna página viva usa**. Son herencia muerta: candidatos a
**eliminación** directa en la Fase 6, sin necesidad de sustituto. Se listan para no perderlos de vista
y poder eliminarlos en bloque al final.

```
accordion2, alert, badge, blockquote, breadcrumb, button, button_group, button_toolbar,
callout2, card2_carousel_evidence, card2_special, card2_teaser, card_body, card_group,
card_overlay, carousel, carousel_item, close_button, collapse2, dropdown, figure, gallery2,
grid_row_1, grid_row_3, grid_row_4, list, list2, list_group, list_group_item, modal, nav,
navbar, navbar_nav, offcanvas, pagination, progress, progress_stacked, spinner
```

> **Cautela.** "Sin uso" aquí significa "no referenciado en ninguna **vista**". Antes de eliminar un
> componente concreto conviene una comprobación final de que tampoco lo usa ninguna plantilla, bloque
> de Layout Builder u otro mecanismo. Para el inventario inicial, el barrido de vistas da el grueso
> fiable (las páginas heredadas son vistas).

---

## 3. Plantillas (`templates/`)

| Plantilla | Origen | Estado | Notas |
|---|---|---|---|
| `templates/layout/page--front.html.twig` | Propia | Propio | Marco de la home (elemento home) |
| `templates/layout/page.html.twig` | Propia | Propio | Marco genérico de páginas no-home (v1.5.0, Fase 2). Sustituye al de BI |
| `templates/content/node--landing.html.twig` | Propia | Propio | Render del nodo landing (home) |
| `templates/content/paragraph--hero-stat.html.twig` | Propia | Propio | Render del paragraph `hero_stat`: reutiliza `ula_hero_stat` por composición (v1.6.0) |
| `templates/content/block--block-content--type--cta-band.html.twig` | Propia | Propio | Render del bloque `cta_band`: compone `ula_cta_band` con los campos del bloque (v1.6.2) |
| `templates/content/block--block-content--type--section-header.html.twig` | Propia | Propio | Render del bloque `section_header`: compone `ula_section_header`; guarda campos opcionales con `isEmpty` (v1.6.3) |
| `templates/content/node--ct-faculty-member--full.html.twig` | Propia | Propio | Render del nodo faculty (view mode `full`): compone `ula_faculty_detail` con la variable `faculty` (valores crudos vía preprocess); acotada a `full` (v1.6.x) |
| `templates/content/block--block-content--type--inline-lb-statgrid.html.twig` | Propia | Propio | Render del bloque `inline_lb_statgrid` (rejilla de cifras, inline block): compone `ula_grid_row` + `ula_hero_stat` desde el paragraph `inline_lb_p_stat` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-section-header.html.twig` | Propia | Propio | Render del bloque `inline_lb_section_header` (cabecera de sección como inline block): reutiliza `ula_section_header` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-richtext.html.twig` | Propia | Propio | Render del bloque `inline_lb_richtext` (texto enriquecido, variantes `plain`/`panel_blue`): CSS propio + librería (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-steps.html.twig` | Propia | Propio | Render del bloque `inline_lb_steps` (cronología): compone `ula_timeline_item` desde el paragraph `inline_lb_p_step` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-pills.html.twig` | Propia | Propio | Render del bloque `inline_lb_pills` (pastillas/etiquetas): compone `ula_pill` / `ula_pill_group` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-cardgrid.html.twig` | Propia | Propio | Render del bloque `inline_lb_cardgrid` (rejilla de tarjetas): compone `ula_card_simple` en `ula_grid_row` desde el paragraph `inline_lb_p_card` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-stack.html.twig` | Propia | Propio | Render del bloque `inline_lb_stack` (pila heterogénea): mezcla piezas de texto y pastillas desde los paragraphs `inline_lb_p_text` / `inline_lb_p_pills` (v1.8.0) |
| `templates/content/block--block-content--type--inline-lb-table.html.twig` | Propia | Propio | Render del bloque `inline_lb_table` (tabla de contenido): compone un `<table>` propio desde el paragraph `inline_lb_p_trow`, pintando exactamente `m` celdas por fila; CSS propio + librería (v1.8.1) |

> **Resuelto en v1.5.0 (Fase 2):** el tema **ya tiene `page.html.twig` propio**
> (`templates/layout/page.html.twig`), que sustituye al heredado de Bootstrap Italia para todas las
> páginas no-home. Monta header/footer propios (`lscm_page_*`), las regiones funcionales activas y una
> rejilla propia (librería `lscm_page`), sin clases `container/row/col/it-*` de BI. El análisis del
> `page.html.twig` de BI (sus 5 partials) y el diseño del propio están en
> `../elements/layout/SHARED-FRAME-LAYOUT.md` §7–8 (ADR-LAYOUT-003).

> **Material de referencia del piloto (no producción).** Además de las 15 plantillas propias de
> producción de la tabla, en `templates/content/` viven **5 plantillas del piloto de inline blocks**
> (mecanismo de body de sección; ver `../elements/layout/CONTENT-LAYOUT.md` §11–§12), versionadas como
> **caso de uso documental**: `block--block-content--type--pilot-richtext.html.twig`,
> `…--pilot-card.html.twig`, `…--pilot-stack.html.twig`, `paragraph--pilot-p-text.html.twig`,
> `paragraph--pilot-p-pill.html.twig`. **No** cuentan como plantillas de producción y **no** dependen de
> Bootstrap Italia (texto por `…processed|raw`, composición de SDC propios, CSS propio); su única
> finalidad es servir de referencia. Su CSS es `css/pilot.css` (librería `pilot`, §4). La configuración
> asociada (tipos de bloque/paragraph, campos, inline blocks colocados en `/about-lb`) vive en BD, no en
> git, y el script de creación no se versiona.

---

## 4. Librerías (assets CSS/JS)

Cargadas globalmente desde el `.info.yml` (ver concepto en `../CONCEPTOS-DRUPAL.md` §2).

| Librería | Origen | Estado | Papel |
|---|---|---|---|
| `bootstrap_ula_lscm/libraries-ui` | Propia | Propio | Assets de interfaz del tema |
| `bootstrap_ula_lscm/custom` | Propia | Propio | Estilos propios personalizados |
| `bootstrap_ula_lscm/ula_tokens` | Propia | Propio | Tokens de diseño `ula_*` (colores, tipografías) |
| `bootstrap_ula_lscm/lscm_page` | Propia | Propio | Rejilla y wrappers del marco de páginas (v1.5.0). Cargada a demanda por `page.html.twig` |
| `bootstrap_italia/base` | **Heredada de BI** | Heredado (en uso) | CSS estructural de BI: viste los componentes de BI en uso. Eliminar en Fase 6, solo cuando nada dependa de él |
| `bootstrap_italia/enable-all-tooltips` | **Heredada de BI** | Heredado (en uso) | JS de tooltips de BI |
| `bootstrap_italia/load-fonts` | **Heredada de BI** | Heredado (en uso) | Carga de fuentes de BI |

> **Declaradas pero NO cargadas** (comentadas en el `.info.yml`): `vanilla`, `cdn`, `hot`, `ddev`.
> También hay declarada en el `.libraries.yml` `ula_landing_base`, cuyo uso conviene aclarar. Pendiente
> de revisar su propósito y vigencia.

> **Librería del piloto (no global, material de referencia).** El `.libraries.yml` declara también la
> librería **`pilot`** (`css/pilot.css`), que **no** se carga globalmente desde el `.info.yml`: la
> adjuntan con `attach_library` las plantillas del piloto de inline blocks (§3, caso de uso documental;
> ver `../elements/layout/CONTENT-LAYOUT.md` §11–§12). No es CSS de producción, **no** cuenta en la tabla
> de librerías globales de arriba y depende solo de `ula_tokens` (cero Bootstrap Italia).

---

## 5. Regiones

El `.info.yml` redeclara **56 regiones** con el esquema completo de Bootstrap Italia (ver concepto en
`../CONCEPTOS-DRUPAL.md` §3). De ellas, solo unas pocas tienen bloques colocados por las páginas vivas;
el resto es herencia muerta candidata a adelgazar en la Fase 6.

**Regiones con bloques colocados (en uso real), según Block layout:**
`brand`, `breadcrumb`, `content` (crítica: el contenido principal), `footer_menu`,
`footer_small_prints`, `header_center_search`, `header_nav`, `header_slim_action`,
`header_slim_menu`, `help`, `local_tasks`, `notification`, `title`. (`sidebar_second` tiene un bloque
desactivado.)

**Resto (~43 regiones):** declaradas pero sin bloques en uso —incluidas todas las `home_*_row_*`, las
`before/after_content_*`, `footer_first/second/third/fourth`, etc.—. Herencia muerta candidata a
eliminar del `.info.yml` en la Fase 6.

> El detalle completo de las 56 regiones y su análisis está en el histórico de la investigación; aquí
> se resume lo accionable (usadas vs muertas).

---

## 6. Conclusión y uso de este inventario

- **Lo que ya es propio:** 20 componentes SDC + 15 plantillas + 3 librerías. No requieren acción.
- **Lo que hay que adaptar/rehacer (el trabajo de fondo):** los **21 componentes de BI en uso** y el
  `page.html.twig` (crear propio). De aquí sale la lista de piezas propias a construir, página a página.
- **Lo que se eliminará al final (Fase 6):** los **38 componentes muertos**, las **~43 regiones**
  muertas, y las **3 librerías `bootstrap_italia/*`** —cada cosa, solo cuando nada vivo dependa de ella.

Este inventario se actualiza conforme cada componente heredado en uso se adapta como propio (cambia de
la tabla 2.2 a la 2.1, renombrado) o se confirma su eliminación.

---

## 7. Cómo se visten hoy las páginas no-home (marco propio + contenido con CSS de BI)

> **Información clave para la migración de componentes.** Documenta de dónde salen los estilos que se
> ven en las páginas no-home tras adoptar el `page.html.twig` propio (v1.5.0). Es la base para ir
> adaptando/rehaciendo los componentes del contenido interno.

Tras la Fase 2, en cada página no-home **conviven dos fuentes de estilo**:

1. **CSS propio** (`ula_tokens`, `lscm_page`, y los CSS de los componentes `ula_*`/`lscm_*`) →
   viste el **marco**: header, footer, rejilla de página. Es independiente de Bootstrap Italia.

2. **CSS de Bootstrap Italia** (librería **`bootstrap_italia/base`**, cargada globalmente desde el
   `.info.yml`) → viste el **contenido interno** de las páginas: los componentes heredados que usan las
   vistas (`grid_row`, `card`, `card2_*`, `modal2`, `table`, `accordion`, `academic_calendar`, etc.),
   incluyendo su tipografía, colores, rellenos, botones y demás.

**Por eso el contenido interno "se ve bien" pese a no haberlo migrado:** no está huérfano de estilos;
sigue tirando del CSS de Bootstrap Italia que el tema **continúa cargando globalmente**. No se ha
copiado ni adaptado nada de BI para lograrlo: es, literalmente, el CSS de BI todavía activo.

**Implicaciones para la migración (Fases 3–6):**
- El marco ya es **independiente** de BI; el **contenido interno de las páginas no migradas, no**:
  depende de `bootstrap_italia/base`.
- Para cada componente heredado en uso (ver §2.2), "hacerlo propio" implica **reproducir en CSS propio
  el aspecto** que hoy le da `bootstrap_italia/base` (tipografía, colores, espaciados, bordes, estados
  de botón…), adaptándolo al design system `ula_*`. Mientras un componente siga dependiendo del CSS de
  BI, no se puede retirar esa librería.
- **`bootstrap_italia/base` solo se podrá eliminar (Fase 6)** cuando **ningún** contenido vivo dependa
  de ella, es decir, cuando todos los componentes en uso se hayan migrado a `ula_*` con su propio CSS.
- **Caso señalado — `academic_calendar` (en `/student-hub`):** es uno de los componentes cuyo buen
  aspecto actual proviene del CSS de BI (o de CSS a medida del desarrollo previo; su origen exacto está
  pendiente de analizar, ver §2.2). Al migrarlo, habrá que reproducir su aspecto con CSS propio. Es un
  candidato a analizar con detalle por su complejidad visual.

> **Método sugerido al migrar un componente:** inspeccionar qué reglas de `bootstrap_italia/base` (u
> otro CSS) le dan su aspecto actual, y reproducir el resultado equivalente con CSS propio basado en
> los tokens `ula_*`. Así el componente migrado se ve igual o mejor, pero sin depender de BI.

> **Primer contenido interno ya independiente de BI (v1.6.x–v1.7.0).** El cuadro de arriba describe el estado
> **general**: el contenido interno de las páginas no-home se viste con `bootstrap_italia/base`. Pero la entidad
> **Faculty** ya rompe esa dependencia en su parcela: tanto la **ficha de detalle** (`/faculty/...`, componente
> `ula_faculty_detail`) como la **sección Faculty & Research de `/about`** (vista `faculty_cards` →
> `ula_carousel` + `ula_faculty_card`) se visten **íntegramente con CSS propio `ula_*`**, sin clases ni markup
> de Bootstrap Italia (la foto usa `media_thumbnail`, no «Rendered entity», para no arrastrar markup de BI; ver
> `../entities/faculty-member.md` §4 y `../elements/layout/CONTENT-LAYOUT.md` §5). Es el **primer contenido
> interno** (no marco) servido sin BI: no migra un componente concreto de §2.2, sino que estrena contenido
> nuevo ya independiente. No permite aún retirar `bootstrap_italia/base` (el resto del contenido interno sigue
> dependiendo de ella), pero marca el inicio de la senda de la Fase 6 a nivel de contenido.
