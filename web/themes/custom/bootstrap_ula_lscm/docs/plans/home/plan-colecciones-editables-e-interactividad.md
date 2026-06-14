# Plan de desarrollo — Colecciones editables e interactividad de la home

> Planifica las acciones pendientes de la home descritas en `../../elements/home/HOME-ARCHITECTURE.md` §5.
> Sigue el método del plan ya completado (`archive/plan-landing-parametrizada.md`): construir de
> lo simple a lo complejo, validar cada paso antes de seguir, y consolidar en git por hito.
>
> **Mecanismo elegido para las colecciones:** preprocess → prop (no vistas). La decisión, las
> alternativas descartadas y la tabla comparativa están en la **ADR-002** de
> `../../elements/home/HOME-ARCHITECTURE.md` §7.

## Objetivo

Llevar la home de su estado actual (editable en **textos**, con las **colecciones** de ítems aún
fijas en el `.twig` del marco) a un estado en el que:

1. **Las colecciones de ítems sean editables desde el admin** (no hardcodeadas), leyendo los nodos
   de cada tipo de contenido y pasándolos como prop al marco `lscm-master-page`.
2. **La navegación móvil funcione** (menú hamburguesa).
3. **Las pastillas de las tarjetas de universidad sean interactivas** (popover/modal con API nativa).
4. Quede **eliminada la vista vieja** `page_home`, huérfana desde que la home pasó a ser el nodo `landing`.

Requisitos transversales (heredados del proyecto):

- **Fidelidad visual** a la maqueta: ningún cambio debe alterar el aspecto ya validado.
- **Independencia de frameworks externos** en lo que se añada (interactividad con **API nativa** del
  navegador, sin Bootstrap ni librerías JS de terceros).
- **Todo en git siempre que sea posible** (ver `../../ARCHITECTURE.md` §6.1): el sitio no usa
  config/sync, así que se prioriza que la lógica de presentación de la home viva en **código**
  (preprocess + plantillas + componentes), no en configuración de BD. El **contenido** sí vive en
  la BD (los nodos), y se respalda con dumps.

---

## Principios base confirmados por el estado actual

- **El contenido de las colecciones vive (o vivirá) en nodos editables.** Para universidades se
  reutiliza el tipo existente `ct_about_consortium_university`, ampliado con campos nuevos
  (`field_uni_flag`, `field_uni_country`, `field_uni_abbr`, `field_uni_home_pitch`); ver
  `../../analysis/about-and-university-entity.md`.
- **Los 8 componentes `ula_*` ya están listos** para recibir datos por props; hoy los reciben de
  arrays fijos en el marco. El cambio consiste en que esos datos vengan de **nodos leídos por una
  preprocess**, en vez de arrays hardcodeados.
- **El marco `lscm-master-page` no se toca en su forma de pintar:** sigue componiendo cada colección
  con su grid propio (`.uni-grid`, etc.) y su componente `ula_*`. Solo cambia el **origen** de los
  arrays (de hardcodeado a leído de nodos).
- **Mecanismo: preprocess → prop, no vistas.** El patrón de vistas (`ui_patterns_views`) que usa el
  resto del sitio (p. ej. About) se descartó para la home por meter configuración en BD y por el
  riesgo de los wrappers de Views sobre los grids CSS; ver ADR-002. La home es una excepción
  justificada por su naturaleza monolítica y pixel-perfect.
- **La interactividad (hamburguesa, pastillas) es funcionalidad nueva**: la maqueta no la tiene
  (los enlaces se ocultan en móvil; las pastillas son estáticas). Se añade con API nativa.

---

## Inventario de las 8 colecciones a migrar

Cada colección pasará a leerse de **nodos** de un tipo de contenido, que una **preprocess** del tema
convertirá en el array que hoy está hardcodeado, para pasarlo como **prop** al marco. El orden de
migración va de la más rica (piloto) a las más simples.

| # | Colección | Componente destino | Campos del tipo de contenido | Nº ítems en maqueta |
|---|-----------|--------------------|------------------------------|---------------------|
| 1 | Universidades (**piloto**) | `ula_uni_card` | flag, country, abbr, home_pitch (+ title, body, image ya existentes) | 3 |
| 2 | Especializaciones | `ula_spec_card` | icon, title, university, description, modules[], variant | 2 |
| 3 | Semestres (journey) | `ula_sem_card` | semester, icon, university, title, subjects[], variant | 4 |
| 4 | Why-items | `ula_why_item` | number, title, description | 6 |
| 5 | Timeline de admisión | `ula_timeline_item` | title, description, show_line | 4 |
| 6 | Requisitos | `ula_req_card` | icon, title, description | 4 |
| 7 | Features (about) | `ula_feature_item` | icon, title, description | 6 |
| 8 | Stats (hero) | `ula_hero_stat` | number, label | 3–4 |

Notas:
- Los campos con `[]` (modules, subjects, tags) son **multivalor** o relaciones; decidir por
  colección cómo se modelan.
- Decidir, por colección, si el contenido tendrá **página de detalle propia** en el sitio (lo que
  condiciona qué campos crear).
- **Universidades — pastillas pendientes:** las pastillas de semestre (`tags`) de `ula_uni_card`
  dependen de una relación universidad↔semestre aún no modelada (ver
  `../../analysis/about-and-university-entity.md` §3.4). El piloto se hace **sin** pastillas.

---

## Orden de construcción

### Fase 0 — Limpieza previa (rápida, riesgo bajo)
Quitar de en medio lo que ya está obsoleto, antes de añadir cosas nuevas.
- Eliminar la **vista vieja `page_home`** (huérfana desde que la home es el nodo `landing`) — §5.4.
- **Validación:** confirmar que `/home2` deja de existir y que la home (`/`) sigue intacta.
- Dump previo + commit del estado.

> Esta fase quedó **pospuesta** por decisión del usuario; se retomará más adelante.

### Fase 1 — Piloto de colección editable: **universidades**
La colección más rica, que ejercita el patrón completo (lectura de nodos → array → prop → render).
Es el patrón de referencia que validará el mecanismo para las demás.

- **1.1 Reutilizar el tipo de contenido** `ct_about_consortium_university` (ya existe; las
  universidades ya son nodos con página propia). **Hecho:** ampliado con `field_uni_flag`,
  `field_uni_country`, `field_uni_abbr`, `field_uni_home_pitch`.
- **1.2 Rellenar los nodos** (UAB/13, RTU/14, UASW/15) con los datos de la maqueta. **Hecho.**
- **1.3 Escribir la preprocess** en el tema que lee los nodos de universidad (ordenados por
  `field_order`) y construye el array `universities` con la forma que el marco espera (las claves que
  hoy tiene el array hardcodeado: flag, country, name, abbr, description…).
- **1.4 Pasar el array como prop** al marco: que `node--landing.html.twig` (o la preprocess del nodo
  landing) inyecte `universities` leído de nodos, en lugar del array fijo del `.twig` del marco.
- **1.5 Hacer que el marco use la prop** si llega, y el array de fábrica si no (mismo patrón de
  `|default()` que los textos): así la home se ve igual, pero alimentada por nodos.
- **Validación:** la sección de universidades de la home se ve **idéntica** a la actual, pero ahora
  editar un nodo de universidad cambia la tarjeta. Las pastillas quedan fuera (pendiente §3.4).

### Fase 2 — Replicar el patrón al resto de colecciones
Una vez validado el piloto, aplicar el mismo mecanismo a las 7 restantes, en orden de menos a más
complejas (stats, why-items, features, requisitos, timeline, semestres, especializaciones).
- Cada colección: tipo de contenido + campos + nodos + entrada en la preprocess + prop al marco.
- Valorar generalizar la preprocess para que cargue las colecciones de forma uniforme.
- **Validación por colección:** la sección se ve idéntica, alimentada por nodos.
- Consolidar en git por colección o por grupos coherentes.

### Fase 3 — Menú hamburguesa (móvil) — §5.2
- Añadir un toggle de navegación para móvil que use el **menú principal de Drupal**, con un
  comportamiento mínimo propio (API nativa, sin frameworks).
- **Validación:** en viewport móvil, el menú abre/cierra y los enlaces funcionan; en escritorio, el
  nav se comporta como hasta ahora.

### Fase 4 — Pastillas interactivas de `ula_uni_card` — §5.3
- Requiere haber modelado antes la **relación universidad↔semestre** (entidad semestre + entidad de
  relación con el texto del modal; ver `../../analysis/about-and-university-entity.md` §3.4).
- Convertir las pastillas (`tags`, `{label, info}`) en disparadores de un popover/modal que muestre
  `info`, usando la **API nativa** (`popover` / `<dialog>`).
- **Validación:** al activar una pastilla, aparece su información; sin JS de terceros.

### Fase 5 — Verificación final y consolidación
- Revisar que toda la home sigue fiel a la maqueta y que las colecciones son editables.
- Actualizar `../../elements/home/HOME-ARCHITECTURE.md`: mover las colecciones de "Familia B (en
  código)" a editables, y marcar los pendientes §5.x como resueltos.
- Subir la versión del tema (§1 de `../../ARCHITECTURE.md`) y registrar el hito.

---

## Método de trabajo (el mismo del proyecto)

- Se migra/añade **una cosa cada vez**, se valida (fidelidad + editabilidad) **antes** de seguir.
- **Dump de BD antes de cada cambio de configuración** (los tipos de contenido y campos viven en BD;
  la preprocess y el marco viven en git).
- Nada se da por bueno sin verlo renderizado.
- Cada hito se consolida en git (commit + push), verificando la sincronización con el clon de trabajo.
- Los scripts de creación de campos/tipos se conservan en `scripts/` como referencia reproducible.

---

## Cuestiones abiertas a decidir al arrancar (o por colección)

1. **Páginas de detalle:** ¿qué colecciones tendrán página de detalle propia (universidades,
   especializaciones…)? Condiciona qué campos crear.
2. **Campos multivalor / relaciones:** cómo modelar `modules`, `subjects` y, en universidades, la
   relación con semestres (`tags`, ver `../../analysis/about-and-university-entity.md` §3.4).
3. **Dónde vive la preprocess:** decidir si la carga de nodos va en una *preprocess* del nodo landing
   (`hook_preprocess_node`), en una función auxiliar del `.theme`, o en otro punto. Decisión técnica
   a fijar en el piloto (1.3).
4. **Enlace de la tarjeta de universidad:** ¿debe `ula_uni_card` enlazar a la página de detalle del
   nodo? Si sí, decidir si se añade una prop de URL al componente o cómo se resuelve el enlace.
5. **Agrupación de la migración:** ¿consolidar en git colección por colección, o por grupos?

---

## Resumen

Se hacen **editables** las 8 colecciones de la home leyendo sus datos de **nodos** (tipos de
contenido) mediante una **preprocess** del tema que construye los arrays y los pasa como **prop** al
marco `lscm-master-page` — que sigue pintándolas con sus grids propios y los componentes `ula_*`,
con fidelidad garantizada e independencia total de Bootstrap, y con todo el código en git (ver
ADR-002). Se valida primero con un **piloto (universidades)** antes de replicar. Después se añade la
**interactividad** pendiente (menú hamburguesa y pastillas con API nativa) y se **elimina la vista
vieja** `page_home`. Todo siguiendo el método del proyecto: de simple a complejo, validando fidelidad
en cada paso, con dump previo y consolidación en git por hito.
