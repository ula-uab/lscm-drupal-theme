# Plan de desarrollo — Colecciones editables e interactividad de la home

> Planifica las acciones pendientes de la home descritas en `../../elements/home/HOME-ARCHITECTURE.md` §5.
> Sigue el método del plan ya completado (`archive/plan-landing-parametrizada.md`): construir de
> lo simple a lo complejo, validar cada paso antes de seguir, y consolidar en git por hito.

## Objetivo

Llevar la home de su estado actual (editable en **textos**, con las **colecciones** de ítems aún
fijas en el `.twig` del marco) a un estado en el que:

1. **Las colecciones de ítems sean editables desde el admin** (no hardcodeadas), mediante tipos de
   contenido + vistas, reutilizando el patrón que el sitio ya usa.
2. **La navegación móvil funcione** (menú hamburguesa).
3. **Las pastillas de las tarjetas de universidad sean interactivas** (popover/modal con API nativa).
4. Quede **eliminada la vista vieja** `page_home`, huérfana desde que la home pasó a ser el nodo `landing`.

Requisitos transversales (heredados del proyecto):

- **Fidelidad visual** a la maqueta: ningún cambio debe alterar el aspecto ya validado.
- **Independencia de frameworks externos** en lo que se añada (interactividad con **API nativa** del
  navegador, sin Bootstrap ni librerías JS de terceros).
- **No meter configuración pesada en BD** innecesariamente (ver `../../ARCHITECTURE.md` §5.1):
  la config nueva (tipos de contenido, campos, vistas) vive en BD y se respalda con dumps; se
  conservan scripts reproducibles cuando aplique.

---

## Principios base confirmados por el estado actual

- **El patrón "contenido editable → componente" ya existe en el sitio**: la timeline de Admissions
  usa nodos `ct_admission_preenrolment_step` listados por una **vista** que los pinta con el
  componente `timeline_item2` vía `ui_patterns_views`. Es el patrón a replicar para las colecciones
  de la home, en lugar de inventar uno nuevo.
- **Los 8 componentes `ula_*` ya están listos** para recibir datos por props; hoy los reciben de
  arrays fijos en el marco. El cambio consiste en que esos datos vengan de **nodos vía vista**, no
  de arrays.
- **La decisión de tipos de contenido + vistas (no Paragraphs)** ya está tomada y registrada.
- **La interactividad (hamburguesa, pastillas) es funcionalidad nueva**: la maqueta no la tiene
  (los enlaces se ocultan en móvil; las pastillas son estáticas). Se añade con API nativa.

---

## Inventario de las 8 colecciones a migrar

Cada colección pasará a ser un **tipo de contenido** cuyos nodos alimentan una **vista** que los
pinta con su componente `ula_*`. El orden de migración va de la más rica (piloto) a las más simples.

| # | Colección | Componente destino | Campos previsibles del tipo de contenido | Nº ítems en maqueta |
|---|-----------|--------------------|------------------------------------------|---------------------|
| 1 | Universidades (**piloto**) | `ula_uni_card` | flag, country, name, abbr, description, tags[] | 3 |
| 2 | Especializaciones | `ula_spec_card` | icon, title, university, description, modules[], variant | 2 |
| 3 | Semestres (journey) | `ula_sem_card` | semester, icon, university, title, subjects[], variant | 4 |
| 4 | Why-items | `ula_why_item` | number, title, description | 6 |
| 5 | Timeline de admisión | `ula_timeline_item` | title, description, show_line | 4 |
| 6 | Requisitos | `ula_req_card` | icon, title, description | 4 |
| 7 | Features (about) | `ula_feature_item` | icon, title, description | 6 |
| 8 | Stats (hero) | `ula_hero_stat` | number, label | 3–4 |

Notas:
- Los campos con `[]` (tags, modules, subjects) son **multivalor**; decidir por colección si se
  modelan como campo multivalor simple o requieren estructura adicional.
- Decidir, por colección, si el contenido tendrá **página de detalle propia** en el sitio (lo que
  refuerza el enfoque nodos+vistas y condiciona qué campos crear).

---

## Orden de construcción

### Fase 0 — Limpieza previa (rápida, riesgo bajo)
Quitar de en medio lo que ya está obsoleto, antes de añadir cosas nuevas.
- Eliminar la **vista vieja `page_home`** (huérfana desde que la home es el nodo `landing`) — §5.4.
- **Validación:** confirmar que `/home2` deja de existir y que la home (`/`) sigue intacta.
- Dump previo + commit del estado.

### Fase 1 — Piloto de colección editable: **universidades**
La colección más rica (varios campos + tags), que ejercita el patrón completo. Es el equivalente al
`eu_hero_stat` del plan anterior: el patrón de referencia que validará el mecanismo para las demás.
- **1.1 Inspeccionar el patrón existente**: examinar en el Drupal real (con drush) cómo está montada
  la vista de la timeline de Admissions y el tipo `ct_admission_preenrolment_step`
  (campos, cómo la vista mapea campos→props de `timeline_item2` vía `ui_patterns_views`).
- **1.2 Crear el tipo de contenido** para universidades, con sus campos (script reproducible, como
  en la home — ver `scripts/`).
- **1.3 Crear los 3 nodos** (las universidades reales).
- **1.4 Crear la vista** que los lista y los pinta con `ula_uni_card` vía `ui_patterns_views`,
  mapeando campos→props.
- **1.5 Integrar la vista en la home**, sustituyendo el array fijo `universities` del marco.
- **Validación:** la sección de universidades de la home se ve **idéntica** a la actual, pero ahora
  alimentada por nodos editables. Editar un nodo cambia la tarjeta.

### Fase 2 — Replicar el patrón al resto de colecciones
Una vez validado el piloto, aplicar el mismo mecanismo a las 7 restantes, en orden de menos a más
complejas (stats, why-items, features, requisitos, timeline, semestres, especializaciones).
- Cada colección: tipo de contenido + campos + nodos + vista + integración en el marco.
- **Validación por colección:** la sección correspondiente se ve idéntica, alimentada por nodos.
- Consolidar en git por colección o por grupos coherentes.

### Fase 3 — Menú hamburguesa (móvil) — §5.2
- Añadir un toggle de navegación para móvil que use el **menú principal de Drupal**, con un
  comportamiento mínimo propio (API nativa, sin frameworks).
- **Validación:** en viewport móvil, el menú abre/cierra y los enlaces funcionan; en escritorio, el
  nav se comporta como hasta ahora.

### Fase 4 — Pastillas interactivas de `ula_uni_card` — §5.3
- Convertir las pastillas (`tags`, hoy `{label, info}` renderizado solo como `label`) en disparadores
  de un popover/modal que muestre `info`, usando la **API nativa** (`popover` / `<dialog>`).
- Requiere que la fase 1 haya definido cómo se editan los `tags` con su `info` desde el nodo.
- **Validación:** al activar una pastilla, aparece su información; sin JS de terceros.

### Fase 5 — Verificación final y consolidación
- Revisar que toda la home sigue fiel a la maqueta y que las colecciones son editables.
- Actualizar `../../elements/home/HOME-ARCHITECTURE.md`: mover las colecciones de "Familia B (en código)" a editables,
  y marcar los pendientes §5.x como resueltos.
- Subir la versión del tema (§1 de `../../ARCHITECTURE.md`) y registrar el hito.

---

## Método de trabajo (el mismo del proyecto)

- Se migra/añade **una cosa cada vez**, se valida (fidelidad + editabilidad) **antes** de seguir.
- **Dump de BD antes de cada cambio de configuración** (tipos de contenido, campos, vistas viven en BD).
- Nada se da por bueno sin verlo renderizado.
- Cada hito se consolida en git (commit + push), verificando la sincronización con el clon de trabajo.
- Los scripts de creación de campos/tipos se conservan en `scripts/` como referencia reproducible.

---

## Cuestiones abiertas a decidir al arrancar

1. **Páginas de detalle:** ¿qué colecciones tendrán página de detalle propia (universidades,
   especializaciones…)? Condiciona qué campos crear y refuerza el enfoque nodos+vistas.
2. **Campos multivalor estructurados:** cómo modelar `tags` (con su `info` para el popover),
   `modules` y `subjects`. ¿Campo multivalor simple, o estructura más rica?
3. **Orden de las vistas en la página:** cómo se integran las vistas en el marco `lscm-master-page`
   (¿el marco embebe las vistas, o la plantilla del nodo las orquesta?). Decisión técnica a validar
   en el piloto.
4. **Agrupación de la migración:** ¿consolidar en git colección por colección, o por grupos?
5. **Tipos de contenido vs. vocabulario/taxonomía** para las colecciones más simples (p. ej. stats):
   valorar si algún caso encaja mejor como taxonomía que como tipo de contenido.

---

## Resumen

Se migran las **8 colecciones** de la home de arrays fijos en el `.twig` a **contenido editable**
(tipos de contenido + vistas que pintan los componentes `ula_*` vía `ui_patterns_views`), validando
primero con un **piloto (universidades)** antes de replicar. Después se añade la **interactividad**
pendiente (menú hamburguesa y pastillas con API nativa) y se **elimina la vista vieja** `page_home`.
Todo siguiendo el método del proyecto: de simple a complejo, validando fidelidad en cada paso, con
dump previo y consolidación en git por hito.
