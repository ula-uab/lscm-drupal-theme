> ⚠️ **DOCUMENTO HISTÓRICO — ARCHIVADO.**
> Este fue el plan inicial de la landing parametrizada (fases 0–4), **completado**. Se conserva
> como registro de la planificación original. El estado real del proyecto puede diferir de lo aquí
> escrito; la documentación viva está en `../../../elements/home/HOME-ARCHITECTURE.md` y en `../../../ARCHITECTURE.md`.
>
> **Divergencias respecto a lo ejecutado (para referencia):**
> - El prefijo de los componentes fue `ula_`, no `eu_`.
> - Se crearon **8** componentes, no 9: `ula_journey_connector` se descartó (es decoración del layout).
> - El plan llegaba hasta la landing *parametrizada* (props con datos de ejemplo). La **editabilidad
>   desde el admin** (nodo `landing` + 42 campos + plantillas + mapeo campo→prop) fue trabajo
>   posterior, no contemplado en este plan.
> - `lscm-master-page-test` y `-backup` se eliminaron; `lscm-master-static` se conserva como referencia.
>
> Las acciones pendientes de la home se planifican en `../plan-colecciones-editables-e-interactividad.md`.

---

# Plan de desarrollo — Landing parametrizada `lscm-master-page`

## Objetivo

Convertir la maqueta estática `lscm-master-static` (HTML hardcodeado) en una **landing parametrizada** cuyos slots se rellenen **componiendo componentes SDC propios**, con dos requisitos innegociables:

1. **Fidelidad visual absoluta** a la maqueta (debe verse idéntica al preview).
2. **Independencia total de Bootstrap Italia y de Bootstrap.** Los componentes nuevos usan exclusivamente el CSS propio de la maqueta (sistema de variables `--eu-*`), sin clases ni assets de Bootstrap Italia.

> Decisión de arquitectura adoptada: **Filosofía B pura.** No se reutilizan los componentes SDC heredados de Bootstrap Italia (`hero2`, `card2_*`, `timeline2`, etc.). Se crean componentes SDC nuevos y autónomos que reproducen los patrones de la maqueta con su propio CSS.

> Fuera de alcance (pendiente para más adelante): qué hacer con Bootstrap Italia en el resto del sitio (header, footer, vistas de contenido). Este plan solo cubre la landing.

---

## Principio base confirmado por el análisis

La maqueta es un **sistema de diseño autónomo**:

- **CSS 100% propio**, sin `@import`, mixins ni dependencias de Bootstrap.
- **15 tokens de diseño** definidos en un único `:root`: `--eu-blue`, `--eu-blue-dark`, `--eu-blue-light`, `--eu-yellow`, `--eu-yellow-dark`, `--white`, `--off-white`, `--text-dark`, `--text-mid`, `--text-light`, `--border`, `--radius`, `--radius-lg`, `--font-body`, `--font-display`.
- Las clases con nombre "de Bootstrap" (`.container`, `.btn-primary`, `.btn-outline`) están **redefinidas en el CSS propio**; no heredan nada.

Esto permite cumplir fidelidad + independencia **sin compromiso**: troceamos el CSS existente y lo repartimos, sin reescribir estética.

---

## Estrategia de CSS: tokens compartidos + CSS por componente

Esta es la decisión clave de organización (responde al TO-DO sobre el reparto del CSS monolítico):

1. **Tokens globales compartidos.** Los 15 `--eu-*` y tipografías salen del `:root` monolítico y van a un **único fichero de tokens del tema** (p. ej. una librería CSS global del tema, o un `_tokens.css` cargado siempre). Todos los componentes los consumen. Beneficio: cambiar el azul institucional se propaga a todo.

2. **Estilos base/globales** (reset, `.container`, `.section-tag`, `.section-title`, `.section-desc`, animaciones `.reveal`) → a una **librería base de la landing**, compartida por la página y sus componentes.

3. **CSS específico por componente.** Cada componente SDC nuevo lleva **solo su porción** de CSS (la de su patrón), en su propia carpeta. Ejemplo: `uni_card` lleva las reglas `.uni-card`, `.uni-flag`, `.uni-country`, etc.

Resultado: nada de CSS duplicado, tokens centralizados, y cada componente autocontenido en lo que le es propio.

---

## Inventario de componentes SDC nuevos a crear

Derivado de los patrones repetibles detectados en la maqueta. Se agrupan en **componentes "ítem"** (las piezas que se repiten dentro de un slot) y se anota a qué slot de `lscm-master-page` alimentan.

| # | Componente nuevo (machine name) | Patrón / clases CSS | Slot destino en la landing | Repeticiones en maqueta |
|---|--------------------------------|---------------------|----------------------------|--------------------------|
| 1 | `eu_hero_stat` | `.hero-stat`, `.hero-stat-num`, `.hero-stat-label` | `hero_stats` | 4 |
| 2 | `eu_feature_item` | `.feature-item`, `.feature-icon`, `.feature-text` | `about_features` | 6 |
| 3 | `eu_sem_card` | `.sem-card`, `.sem-num`, `.sem-icon`, `.sem-uni`, `.sem-subjects` | `journey_semesters` | 4 |
| 4 | `eu_journey_connector` | `.journey-connector`, `.connector-line` | `journey_semesters` | 3 |
| 5 | `eu_uni_card` | `.uni-card`, `.uni-flag`, `.uni-country`, `.uni-abbr`, `.uni-semesters`, `.uni-sem-tag` | `universities` | 3 |
| 6 | `eu_spec_card` | `.spec-card`, `.spec-top`, `.spec-body`, `.spec-icon`, `.spec-uni`, `.spec-modules` | `specializations` | 2 |
| 7 | `eu_why_item` | `.why-item`, `.why-num` | `why_items` | 6 |
| 8 | `eu_timeline_item` | `.timeline-item`, `.timeline-dot`, `.timeline-line`, `.timeline-content`, `.timeline-left` | `timeline_items` | 4 |
| 9 | `eu_req_card` | `.req-card`, `.req-card-icon` | `requirements_cards` | 4 |

Notas:
- Prefijo `eu_` propuesto para marcar que son componentes propios del design system europeo de la landing y distinguirlos de los heredados de Bootstrap Italia. (Ajustable a tu gusto: `lscm_`, `ula_`, etc.)
- Los enlaces de navegación y de footer (`nav_links`, `footer_col*_links`) son simples `<li><a>`; **no necesitan componente propio**, se rellenan como listas en el slot.
- El `hero`, el `about-card`, el bloque CTA y el footer son **estructura de la página** (van en el `.twig` de `lscm-master-page`, parametrizados con props), no componentes repetibles.

---

## Orden de construcción

Se construye de lo más simple a lo más complejo, validando fidelidad en cada paso.

### Fase 0 — Preparación de la base CSS
- Extraer los 15 tokens `:root` a la librería de tokens global del tema.
- Extraer los estilos base/globales (`.container`, `.section-*`, `.reveal`) a la librería base de la landing.
- Declarar ambas librerías en `bootstrap_ula_lscm.libraries.yml` y asegurar que se cargan.
- **Validación:** la maqueta estática debe seguir viéndose igual tras mover el CSS.

### Fase 1 — Componente piloto: `eu_hero_stat`
Es el más simple (3 clases, solo props: número + etiqueta). Sirve de **patrón de referencia** para todos los demás.
- Crear carpeta `components/eu_hero_stat/` con: `eu_hero_stat.component.yml` (props: `number`, `label`), `eu_hero_stat.twig`, `eu_hero_stat.css` (solo las reglas `.hero-stat*`).
- Añadir una `.story.yml` de preview.
- **Validación:** previsualizar el componente aislado y compararlo con la sección hero de la maqueta.

### Fase 2 — Resto de componentes "ítem"
En este orden (de menos a más props/slots): `eu_why_item`, `eu_feature_item`, `eu_req_card`, `eu_journey_connector`, `eu_timeline_item`, `eu_sem_card`, `eu_uni_card`, `eu_spec_card`.
- Cada uno sigue el patrón del piloto: carpeta, `.component.yml`, `.twig`, `.css` propio, `.story.yml`.
- **Validación por componente:** preview aislado fiel a su patrón en la maqueta.

### Fase 3 — Recablear `lscm-master-page`
- Reescribir el `.usage.twig` (y/o el `.twig`) para que cada slot se rellene **componiendo** los componentes nuevos en vez de HTML hardcodeado. Ejemplo conceptual del slot `universities`: un bucle/lista de `eu_uni_card` con sus props.
- Mantener intactos los props de texto simples (títulos de sección, descripciones) que ya existen.
- **Validación:** renderizar `lscm-master-page` con datos de ejemplo y compararla pixel a pixel con `lscm-master-static`.

### Fase 4 — Verificación final y limpieza
- Comparar la landing parametrizada con el preview de referencia (`lscm-master-static-preview.html`).
- Confirmar que no se carga ningún CSS/JS de Bootstrap Italia para renderizar la landing.
- Decidir el destino de `lscm-master-static` y `lscm-master-page-test` (¿se conservan como referencia, se archivan, se borran?).
- Commit + push por hito.

---

## Método de trabajo (acordado para este proyecto)

- Se construye **un componente cada vez**, se previsualiza y se valida la fidelidad **antes** de pasar al siguiente.
- Nada se da por bueno sin verlo renderizado.
- Cada hito se consolida en git (commit + push).
- El preview autónomo `lscm-master-static-preview.html` es la **referencia visual** contra la que comparar.

---

## Cuestiones abiertas a decidir al arrancar

1. **Prefijo de los componentes nuevos:** `eu_`, `lscm_`, `ula_` u otro.
2. **Dónde cargar los tokens globales:** librería propia del tema cargada siempre, o adjunta a la landing únicamente.
3. **Estructura de slots vs props en los componentes ítem:** p. ej. en `eu_uni_card`, decidir qué es prop (nombre, país, abreviatura) y qué es slot (descripción con HTML, lista de tags).
4. **Granularidad:** ¿`eu_journey_connector` merece ser componente propio o es parte de `eu_sem_card`/del layout del slot? (Propuesto como componente por claridad, revisable.)

---

## Resumen

Se crean **9 componentes SDC nuevos y autónomos** (independientes de Bootstrap Italia), alimentados por el CSS propio de la maqueta repartido en: tokens globales + base de la landing + CSS por componente. Se construyen de simple a complejo, validando fidelidad en cada paso, empezando por `eu_hero_stat` como patrón. Finalmente se recablea `lscm-master-page` para componer estos componentes en sus slots, sustituyendo el HTML hardcodeado actual.
