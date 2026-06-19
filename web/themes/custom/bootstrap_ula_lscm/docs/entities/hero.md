# Entidad — `hero` (Hero) y paragraph `hero_stat` (Hero stat)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.6.0 · **Mecanismo de consumo:** vista con **filtro contextual** por el nodo de la
> página → componente (Views → UI Patterns, por **slots**), distinto del patrón preprocess → prop de la home
> (ver `../elements/layout/CONTENT-LAYOUT.md` y `../COMPONENTS.md`, componente `ula_hero`).

---

## 1. Qué es y por qué existe

`hero` modela **la cabecera (hero) de una página de contenido**: el bloque superior, sobre fondo azul
degradado, con eyebrow, título (con una parte resaltada), subtítulo, llamadas a la acción y, opcionalmente,
una fila de estadísticas. Cada nodo `hero` es **el hero de una página** (el de About, el de Alumni, etc.).

**Por qué un tipo de contenido propio y no markup en una plantilla.** El hero de la home está
*hardcodeado* en la plantilla `lscm-master-page` (alimentado por preprocess → prop). Para las páginas de
contenido se buscó lo contrario: que el hero **no** esté hardcodeado, que sea **editable** desde Drupal y
**reutilizable** en varias páginas. Modelarlo como tipo de contenido permite crear un nodo por hero y
editar sus textos sin tocar código.

**Por qué una entidad separada (y no campos en el tipo de página).** Puede haber heros en varias páginas;
un tipo de contenido `hero` dedicado, con un nodo por página, mantiene el hero como una pieza
independiente y reutilizable. El emparejamiento «este hero ↔ esta página» se resuelve con una **referencia
al nodo de la página** (`field_target_page`, ver §3), no incrustando el hero en el nodo de la página.

**Por qué la presentación la aporta el componente y no el contenido.** El nodo solo guarda **datos**
(textos, enlaces, cifras). El aspecto (degradado, colores, tipografía, disposición) lo pone el componente
propio `ula_hero` (design system `ula_*`), de modo que el contenido editable queda libre de markup y de
clases de Bootstrap Italia. Por eso el subtítulo es **texto plano** (sin formato): evita de raíz cualquier
clase/markup de BI; el estilado lo aporta el CSS del componente.

> **Este tipo, de facto, es el modelo de páginas de contenido tomando forma.** El `hero` y su vista con
> **filtro contextual** son la primera rebanada del modelo de contenido de las páginas (la decisión del «tipo
> de contenido definitivo», ver `../elements/layout/CONTENT-LAYOUT.md` §9.3). No es solo una página: es el
> patrón que se reutilizará.

---

## 2. Campos

### 2.1. Tipo de contenido `hero`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `title` (base) | — | 1 | Título **administrativo** del nodo (p. ej. "About hero"); identifica el nodo en la gestión. **No** es el título visible del hero. |
| `field_hero_eyebrow` | string | 1 | Etiqueta superior corta ("About the Programme"). → slot `eyebrow`. |
| `field_hero_title` | string | 1 | Título principal, parte **no** resaltada. → slot `title`. |
| `field_hero_highlight` | string | 1 | Parte del título **resaltada** en dorado. → slot `title_highlight`. |
| `field_hero_subtitle` | string_long | 1 | Párrafo descriptivo. **Texto plano** (sin formato). → slot `subtitle`. |
| `field_hero_ctas` | link | ∞ | Botones de llamada a la acción: cada valor es **URL + texto del enlace**. → slot `actions`. |
| `field_hero_stats` | entity_reference_revisions → paragraph `hero_stat` | ∞ | Colección de estadísticas. → slot `stats`. |
| `field_target_page` | entity_reference → node (bundle `lb_contents`) | 1 | **Criterio de filtrado**: el **nodo de la página** a la que pertenece el hero. La vista filtra por él con un **filtro contextual** («ID de contenido desde la URL»). Requerido; acotado a `lb_contents`. |

### 2.2. Paragraph `hero_stat`

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| `field_stat_number` | string | 1 | La cifra ("4", "120+", "2 años"). → prop `number` de `ula_hero_stat`. |
| `field_stat_label` | string | 1 | La etiqueta de la cifra ("semestres", "universidades"). → prop `label` de `ula_hero_stat`. |

**Por qué las CTAs son un campo Link y las stats son Paragraphs.** Un CTA es "URL + texto", que el tipo de
campo nativo **Link** guarda exactamente (y admite cardinalidad múltiple): la herramienta nativa cubre el
dato sin estructura extra. Una stat es "número + etiqueta" (dos textos como unidad repetible), y **no**
existe un tipo de campo nativo que lo cubra; por eso se modela con **Paragraphs** (un paragraph `hero_stat`
con dos campos, referenciado múltiple). El criterio es usar la herramienta más simple que cubra el dato, no
uniformar por uniformar.

**Por qué el hero referencia el _nodo_ de la página (y no un término).** `field_target_page` apunta al
**nodo `lb_contents`** de la página a la que pertenece el hero. Esto permite que la vista lo seleccione con
un **filtro contextual** por «ID de contenido desde la URL» (ver §3): el argumento es el nodo de la página
que se está visitando, así que **una sola vista sirve el hero de cualquier página**, sin duplicarla.
*(Diseño inicial, en v1.6.0: el hero referenciaba un término del vocabulario `page_id` y la vista filtraba
por término **fijo**, lo que obligaba a una vista por página. Sustituido por la referencia al nodo + filtro
contextual; el campo `field_hero_page` (término) se eliminó y se creó `field_target_page` (nodo).)*

---

## 3. Cómo se consume (lógica en el tema)

El hero **no** se visita como página propia (no hay una URL `/hero-de-about`): se **inyecta** en la página
de contenido que lo usa. El flujo:

1. **Vista `hero_view`** (display de bloque, sin página propia): lista nodos de tipo `hero`, con un **filtro
   contextual** sobre `field_target_page` cuyo valor por defecto es **«ID de contenido desde la URL»**. Al
   renderizarse en una página recibe como argumento el **nodo de esa página** (en `/about`, el nodo 93) y
   devuelve el hero cuyo `field_target_page` apunta a él. Limitada a **1 resultado**. **Una sola vista sirve
   el hero de cualquier página** (no se duplica por página): el emparejamiento lo hace el argumento de la
   URL, no un filtro fijo. Validado: «ID de contenido desde la URL» entrega el nodo de la página también con
   el bloque embebido en Layout Builder (lee la ruta, no el contexto de LB) — ver
   `../elements/layout/CONTENT-LAYOUT.md` §5.7.
2. **Row = Component** `bootstrap_ula_lscm:ula_hero` (Views → UI Patterns). Los campos se mapean a los
   **slots** por `view_field`: `eyebrow`←`field_hero_eyebrow`, `title`←`field_hero_title`,
   `title_highlight`←`field_hero_highlight`, `subtitle`←`field_hero_subtitle`, `actions`←`field_hero_ctas`,
   `stats`←`field_hero_stats`. La prop `size` se fija en **`page`**.
3. **Las stats, por composición.** `field_hero_stats` se renderiza como *Rendered entity*; cada paragraph
   `hero_stat` pasa por la plantilla **`templates/content/paragraph--hero-stat.html.twig`**, que **incluye**
   el componente `ula_hero_stat` pasándole los valores planos de sus campos
   (`paragraph.field_stat_number.value`, `paragraph.field_stat_label.value`). Así cada stat se pinta como un
   `ula_hero_stat` **sin** necesitar un *field formatter* de UI Patterns (que este sitio no tiene) y **sin**
   modificar `ula_hero_stat` (que la home reutiliza igual, por composición). Ver
   `../CONCEPTOS-DRUPAL.md`, composición de componentes SDC.
4. **El bloque de la vista se coloca** en la primera sección del **Layout Builder** de la página de
   contenido (nodo `lb_contents`). El título del bloque se oculta en Layout Builder (casilla "Mostrar
   título" desmarcada).

> **Configuración en BD, no en git.** Todo lo anterior (el tipo de contenido, el paragraph, sus campos, la
> vista `hero_view` y la composición en Layout Builder) es **configuración**: vive en la base de datos, no
> en el repositorio (ver `../../ARCHITECTURE.md`, separación de fuentes de verdad). El repo solo versiona
> el **código** (el componente `ula_hero`, la plantilla del paragraph). Cualquier operación sobre esta
> configuración exige **dump previo** de la BD.

---

## 4. Notas sobre el contenido

- **Un nodo `hero` por página.** El emparejamiento con la página se hace por el **nodo** referenciado en
  `field_target_page`. Si dos heros apuntaran a la misma página, la vista (limitada a 1) mostraría uno
  indeterminado; la unicidad la sostiene la disciplina editorial, no una restricción técnica.
- **Eyebrow, título y resaltado son texto plano** (string): no admiten HTML. El resaltado se modela como un
  campo aparte (`field_hero_highlight`) en vez de incrustar un `<span>` en el título, para no meter markup
  en el contenido editable.
- **El subtítulo es texto plano largo** (string_long), sin formato. Si en el futuro se necesitara formato
  (un enlace, una negrita), habría que cambiarlo a *formatted long* con un formato restringido que **no**
  inyecte clases de Bootstrap Italia; de momento, texto plano (la maqueta es un párrafo liso).
- **CTAs y stats son opcionales por presencia:** si el campo está vacío, el componente no pinta ese bloque
  (el slot correspondiente queda vacío). El hero de About, por ejemplo, puede no llevar CTAs y sí 4 stats.
- **El nodo `hero` no tiene *view display* configurado** (no se navega directamente). Su contenido se arma
  desde los campos vía la vista y la plantilla del paragraph, no desde el display por defecto.
