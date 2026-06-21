# Elemento: Layout — Diseño del contenido de páginas no-home (Layout Builder)

> **Nivel:** elemento (transversal a las páginas de contenido). Este documento es el **segundo
> elemento del layout**: mientras `SHARED-FRAME-LAYOUT.md` documenta el **marco compartido** (header +
> footer + `page.html.twig` que envuelve toda página no-home), este documenta **cómo se compone el
> contenido interno** de esas páginas — el "relleno" que va **dentro** del marco — usando **Drupal
> Layout Builder** como mecanismo de composición.
>
> **Relación con el marco.** El marco (`SHARED-FRAME-LAYOUT.md`) pone el header arriba, el footer abajo
> y el contenedor de contenido en medio; Layout Builder compone **lo que va en ese contenedor**. Son
> dos elementos del layout complementarios: el marco es el continente, este es el contenido.
>
> **Relación con la home.** La home **no** usa este modelo: es una portada autónoma servida como nodo
> `landing` + plantilla Twig (ver `../home/HOME-ARCHITECTURE.md`, ADR-001). Este modelo es para las
> **páginas no-home** (About, Contents, Admission, Eligibility, Student Hub… y las que vengan).
>
> Referenciado desde `../../ARCHITECTURE.md`.

---

## Índice

- [1. Qué es y para qué sirve](#1-qué-es-y-para-qué-sirve)
- [2. Por qué Layout Builder (y por qué se descartó para la home)](#2-por-qué-layout-builder-y-por-qué-se-descartó-para-la-home)
- [3. El modelo de composición de una página no-home](#3-el-modelo-de-composición-de-una-página-no-home)
- [4. Tipos de bloque que puede contener una sección](#4-tipos-de-bloque-que-puede-contener-una-sección)
- [5. Caso central: una vista que pinta entidades con tarjetas (flujo Views → UI Patterns)](#5-caso-central-una-vista-que-pinta-entidades-con-tarjetas-flujo-views--ui-patterns)
  - [5.1. El patrón de dos niveles](#51-el-patrón-de-dos-niveles)
  - [5.2. Cómo se alimenta cada slot: las fuentes (`source`)](#52-cómo-se-alimenta-cada-slot-las-fuentes-source)
  - [5.3. Lección aprendida: `view_field` vs `entity_field` (y por qué la imagen fallaba)](#53-lección-aprendida-view_field-vs-entity_field-y-por-qué-la-imagen-fallaba)
  - [5.4. La imagen: formatter en el campo de la vista, no en el slot](#54-la-imagen-formatter-en-el-campo-de-la-vista-no-en-el-slot)
  - [5.5. La variante del componente](#55-la-variante-del-componente)
  - [5.6. Diagnóstico por comparación: checklist de un slot que no pinta](#56-diagnóstico-por-comparación-checklist-de-un-slot-que-no-pinta)
  - [5.7. Variante: una sola instancia (el hero de página)](#57-variante-una-sola-instancia-el-hero-de-página)
  - [5.8. Slots opcionales: el guard de presencia con Twig debug](#58-slots-opcionales-el-guard-de-presencia-con-twig-debug)
  - [5.9. Enlace/botón a la página de la entidad: «Link to Content»](#59-enlacebotón-a-la-página-de-la-entidad-link-to-content)
  - [5.10. Un slot alimentado por varias fuentes](#510-un-slot-alimentado-por-varias-fuentes)
  - [5.11. Leer un campo de una entidad referenciada (relación no requerida)](#511-leer-un-campo-de-una-entidad-referenciada-relación-no-requerida)
  - [5.12. El contenedor de Nivel 1 puede ser un carrusel](#512-el-contenedor-de-nivel-1-puede-ser-un-carrusel)
- [6. Validación: la prueba piloto `/about-lb`](#6-validación-la-prueba-piloto-about-lb)
- [7. Independencia de Bootstrap Italia en este modelo](#7-independencia-de-bootstrap-italia-en-este-modelo)
- [8. Implicación para la configuración (sitio sin config/sync)](#8-implicación-para-la-configuración-sitio-sin-configsync)
- [9. Pendientes específicos de este elemento](#9-pendientes-específicos-de-este-elemento)
- [10. ADR-LAYOUT-004 — Adopción de Layout Builder como mecanismo de composición de páginas no-home](#10-adr-layout-004--adopción-de-layout-builder-como-mecanismo-de-composición-de-páginas-no-home)

---

## 1. Qué es y para qué sirve

Las páginas no-home del sitio (About, Contents, Admission…) necesitan **componer contenido
estructurado**: secciones apiladas verticalmente, cada una con su tipo de contenido (un grid de
tarjetas, un bloque de texto, una imagen, una colección de ítems…). Hace falta un mecanismo que:

- permita **apilar secciones heterogéneas** de forma flexible, página a página;
- deje **componer visualmente** sin programar una plantilla Twig a medida por cada página;
- sea manejable, idealmente, por un **editor** (site builder) además de por desarrollo;
- y respete la **independencia de Bootstrap Italia** (el aspecto lo aportan los componentes propios
  `ula_*`, no el framework heredado).

El mecanismo adoptado es **Drupal Layout Builder (LB)**: una página no-home se modela como un **nodo**
cuyo contenido se compone con LB en **secciones**, y cada sección contiene **bloques**. Uno de esos
bloques —el caso más rico— es **una vista que selecciona entidades del sitio (nodos) y las pinta con
componentes propios** (tarjetas), vía UI Patterns.

> **No confundir con el marco.** Layout Builder **no** sustituye al header/footer ni al
> `page.html.twig` (eso es el marco compartido, `SHARED-FRAME-LAYOUT.md`). LB compone **el contenido
> que va dentro** del contenedor que el marco reserva. La página se ve así: marco (header + footer) +
> contenido compuesto con LB en medio.

---

## 2. Por qué Layout Builder (y por qué se descartó para la home)

**Aclaración histórica importante.** En la documentación del proyecto consta que Layout Builder se
**descartó** en su momento (ver `../../ARCHITECTURE.md` §5.2 y §6.1, y el documento de la home). Ese
descarte fue una decisión tomada **para la home**, en un momento en que no se había conseguido hacer
funcionar el flujo de composición con LB + UI Patterns que **hoy sí funciona** (validado en el piloto
`/about-lb`, ver §6). No fue una incompatibilidad técnica insalvable de LB, sino el estado de
conocimiento de entonces; por eso la home se resolvió con el mecanismo que hoy tiene (nodo `landing` +
plantilla Twig).

**La situación ahora es distinta, y por dos motivos el balance cambia para las páginas no-home:**

1. **El mecanismo ya está dominado.** Se ha validado de extremo a extremo cómo componer una página con
   LB y cómo, dentro de ella, una vista pinta entidades con tarjetas propias. Lo que antes era un
   obstáculo (no saber hacerlo funcionar) ya no lo es.
2. **El caso de uso es el adecuado para LB.** La home es una **portada única, autónoma, a medida**: una
   plantilla Twig propia le encaja. Las páginas no-home son **muchas, heterogéneas y de estructura
   repetible** (secciones apiladas); componerlas una a una con plantillas Twig a medida sería costoso y
   poco mantenible. LB da exactamente esa composición por secciones, reutilizable página a página, y
   manejable por un editor.

**Conclusión.** Se **adopta Layout Builder como mecanismo de composición del contenido de las páginas
no-home**, conviviendo con la decisión (vigente, para la home) de servir la portada con plantilla Twig.
Son dos contextos distintos con dos soluciones distintas, no una contradicción. La decisión formal está
en el [ADR-LAYOUT-004](#10-adr-layout-004--adopción-de-layout-builder-como-mecanismo-de-composición-de-páginas-no-home).

> **Coste asumido.** LB guarda su composición como **configuración en la base de datos**, no en
> código. En un sitio sin `config/sync` (ver §8 y `../../ARCHITECTURE.md` §6.1), esto añade
> configuración no versionada cuya única red de seguridad es el **dump de BD**. Es un coste real,
> aceptado a cambio de la flexibilidad de composición; se mitiga con la disciplina de dumps y, a
> futuro, con la eventual adopción de gestión de configuración (TO-DO transversal).

---

## 3. El modelo de composición de una página no-home

Una página no-home se compone con Layout Builder así:

```
Nodo (la página)                 ← una página no-home = un nodo con Layout Builder activado
  └── Layout Builder (override por nodo)
        ├── Sección 1   (un layout: 1 columna, 2 columnas…)
        │     └── bloque(s) en su(s) región(es)
        ├── Sección 2
        │     └── bloque(s)
        ├── Sección 3
        │     └── bloque(s)
        └── …                       ← N secciones apiladas verticalmente
```

**Conceptos:**

- **El nodo es la página.** La página no-home se modela como un **nodo** al que se le da el **alias** de
  su ruta (p. ej. `/about`). El nodo es el contenedor; Layout Builder le da la estructura interna. (Esto
  resuelve "quién crea la ruta": la crea el nodo, como cualquier nodo del sitio.)
- **Secciones = bandas horizontales apiladas.** Cada sección es una franja vertical de la página, con un
  **layout** propio (una columna, dos columnas, etc.). Las secciones se apilan en el orden en que se
  definen. Es el "vector vertical" de la página.
- **Bloques = el contenido de cada región de cada sección.** Dentro de una sección, cada **región** del
  layout (p. ej. `content` en una de una columna; `first`/`second` en una de dos) contiene uno o más
  **bloques**. El bloque es la unidad de contenido concreta.

**Activación de Layout Builder.** LB se activa sobre un **tipo de contenido**, con dos modos:
- **Por tipo (sin override):** todos los nodos de ese tipo comparten un layout.
- **Por nodo (con override):** cada nodo compone su propia página. Es el modo que usan las páginas
  no-home, porque cada página tiene una composición distinta.

> **Una entidad, varias representaciones (coherente con `../../ARCHITECTURE.md` §5.3).** El mismo nodo
> (p. ej. una universidad) puede aparecer como tarjeta dentro de una página compuesta con LB y, a la
> vez, tener su propia página de detalle con otro display. LB compone *páginas*; las entidades que
> muestra siguen siendo reutilizables en otros contextos.

---

## 4. Tipos de bloque que puede contener una sección

Una región de una sección puede contener distintos tipos de bloque. Los relevantes para este modelo:

- **Bloque de vista (`views_block:*`)** — una vista con display de **bloque** insertada en la sección.
  Es **el caso central** de este modelo: la vista selecciona entidades (nodos) y las pinta con
  componentes propios (tarjetas) vía UI Patterns. Se detalla en §5.
- **Bloque de campo (`field_block:*`)** — pinta un campo concreto del propio nodo de la página.
- **Bloque de campo extra (`extra_field_block:*`)** — elementos "pseudo-campo" del nodo (p. ej. los
  enlaces).
- **Bloque de contenido / bloque personalizado** — un bloque de texto o markup reutilizable.
- **Componente UI Patterns directo (`ui_patterns:*`)** — un componente SDC insertado directamente como
  bloque en la sección, sin pasar por una vista (útil para piezas sueltas no ligadas a una colección de
  entidades).

> El editor elige, en cada sección, qué bloque(s) colocar. La página final es la suma de las secciones y
> sus bloques.

---

## 5. Caso central: una vista que pinta entidades con tarjetas (flujo Views → UI Patterns)

El bloque más rico de una sección es **una vista que presenta una colección de entidades del sitio como
una rejilla de tarjetas**. Este es el flujo **Views → UI Patterns**, y es el mismo patrón transversal de
contenido editable del tema (ver `../../ARCHITECTURE.md` §5): el contenido vive en **nodos** editables,
una **vista** los selecciona y ordena, y un **componente** propio pinta cada uno.

Esta sección documenta el detalle técnico **completo** de ese flujo —incluyendo las lecciones aprendidas
al validarlo—, de modo que sirva de receta para construir cualquier vista equivalente. (Hay solape
deliberado con `../../ARCHITECTURE.md` §5.5, que cubre el mismo patrón a nivel de tema; aquí se trata en
el contexto de su uso dentro de Layout Builder.)

### 5.1. El patrón de dos niveles

Una vista que pinta una colección con componentes usa **dos niveles**, cada uno con su propio componente
UI Patterns:

- **Nivel 1 — el *Format / Style* de la vista (el contenedor).** `Format → Show: Component` define un
  componente que **envuelve todas las filas**: típicamente una **rejilla**, cuyo slot de contenido
  recibe la fuente especial `view_rows` ("todas las filas de la vista"). Ahí se configuran las columnas
  responsive del grid.
- **Nivel 2 — el *Row* (cada entidad).** El **row plugin** `Component` define el componente que pinta
  **cada fila** (cada entidad): una **tarjeta**, cuyos slots/props se alimentan de los campos de la
  vista.

```
Vista (display de bloque, insertable en una sección de LB)
├── Format/Style: Component   →  componente CONTENEDOR (rejilla)
│        slot "content" ← view_rows   (todas las filas)
│
└── Row: Component            →  componente ÍTEM (tarjeta), por cada fila
         slot ← view_field    (un campo de la vista, ya renderizado)
         slot ← textfield     (un literal fijo)
         slot ← component      (otro componente anidado, p. ej. un modal)
         [campo con link_to_entity: true → enlaza a /node/N]
```

> **Alternativa para el grid.** El contenedor del Nivel 1 puede ser un componente de rejilla propio, o
> bien puede dejarse el *Format* en "Unformatted list" y resolver la disposición en **grid horizontal
> con CSS propio** (`ula_*`) sobre el contenedor que Views genera (clase `.view-<id>`, targeteable sin
> configuración extra). La elección del mecanismo de grid es un pendiente con implicaciones propias
> (ver §9): la regla de fondo es que **el aspecto lo controle el design system propio**, no el framework
> heredado. **Hoy existe ya el contenedor propio `ula_grid_row`** (ver §9.1 y `../../COMPONENTS.md` §1.2).

### 5.2. Cómo se alimenta cada slot: las fuentes (`source`)

Cada slot (o prop) de la tarjeta se rellena con una **fuente** (`source_id`). Las relevantes:

- **`view_field`** — el valor de un **campo añadido a la sección *Fields* de la vista**, ya renderizado
  por su propio formatter. Es la fuente recomendada para este modelo (ver §5.3).
- **`entity_field`** (`[Entity] ➜ [Field]`) — el valor de un campo **directamente de la entidad de la
  fila**, sin necesidad de añadirlo a *Fields*. Útil para texto, pero **problemático para imágenes**
  (ver §5.3 y §5.4).
- **`textfield`** — un valor literal fijo escrito en la configuración (p. ej. la etiqueta de un botón).
- **`component`** — **otro componente anidado** dentro del slot, lo que permite composición (p. ej. un
  modal dentro del cuerpo de una tarjeta).
- **`view_rows`** — todas las filas (se usa en el slot de contenido del contenedor del Nivel 1).

**Slots vs props.** Un componente expone *slots* (reciben contenido renderizable: HTML, un campo
renderizado) y *props* (reciben valores que el componente formatea: un string, un booleano). El
mecanismo de mapeo es el mismo; cambia el destino. Esta distinción es **decisiva** para conectar datos:
un slot acepta un campo renderizado (incluida una imagen); una prop de texto solo acepta texto plano
(pasarle un campo renderizable da el error "got object").

> **Enlace a la página de la entidad.** Para que un campo enlace a la página del propio nodo (`/node/N`)
> **no se usa un campo de URL ni se almacena nada**: se marca, en la configuración de ese campo dentro de
> la vista, la casilla **"Link this field to the original entity"** (`link_to_entity: true`). Es una
> propiedad del campo **en la vista**. Si la entidad tiene página de detalle propia, este es el mecanismo
> para enlazarla desde su tarjeta. **Salvedad importante:** esto sirve cuando el **texto del enlace es el
> propio valor del campo** (p. ej. el nombre que enlaza a la ficha). Si se quiere un enlace con **texto fijo
> distinto** (un botón «View profile»), `link_to_entity` + texto reescrito **no funciona** (se pierde el
> `<a>`): ver §5.9.

### 5.3. Lección aprendida: `view_field` vs `entity_field` (y por qué la imagen fallaba)

Existen **dos vías** para alimentar un slot desde una vista, y la diferencia es **determinante para las
imágenes**:

- **`view_field`** (referenciar un campo añadido en *Fields*, ya formateado). Funciona para **todo tipo
  de campo, imágenes incluidas**, porque el formatter del campo (incluido el formatter de imagen y su
  image style) se configura **en el campo de la vista**, y el slot solo **referencia** el resultado ya
  renderizado.
- **`entity_field`** (`[Entity] ➜ [Field]`, tomar el campo directamente de la entidad). Funciona bien
  para campos de **texto** (vía `[Field item] Text value`, que devuelve un escalar), pero **no permite
  configurar el formatter de imagen** en este contexto de fila de Views: el sub-formulario del formatter
  no expone el selector necesario, de modo que la imagen **no se renderiza**.

**Por eso, el modelo recomendado es alimentar TODOS los slots vía `view_field`** (campos añadidos en
*Fields*), que es además el mecanismo que usa la vista heredada equivalente del sitio y que se confirmó,
por comparación, como el que funciona.

> **Lección de método (registrada también en las instrucciones del proyecto).** Este punto se resolvió
> **comparando** la vista nueva con la vista heredada que ya renderizaba las tarjetas correctamente: la
> heredada alimentaba todos los slots con `view_field` y configuraba el formatter de imagen en el campo;
> la nueva usaba `entity_field` y por eso la imagen quedaba en blanco. La primera pregunta ante un fallo
> es *"¿en qué se diferencia esto de lo que ya funciona?"*, no *"¿qué puede estar mal en abstracto?"*.

### 5.4. La imagen: formatter en el campo de la vista, no en el slot

Consecuencia directa de §5.3. Para que una tarjeta muestre una imagen:

1. **Añadir el campo imagen a la sección *Fields*** de la vista.
2. **Configurar su formatter en el propio campo**: Formatter = **Image**, con un **image style**
   seleccionado (no vacío) y el enlace que proceda. (Un image style vacío es causa de que la imagen no
   se vea aunque todo lo demás esté bien.)
3. **Apuntar el slot de imagen de la tarjeta a ese campo vía `view_field`.**

El formatter de imagen vive, por tanto, **en el campo de la vista**, no en el slot. El slot solo
consume lo ya renderizado.

> **Nota sobre el tipo de campo.** Esto aplica a un campo **imagen directo** (tipo `image`). Si el campo
> fuese una **referencia a media**, el principio es el mismo (el formatter se configura en el campo, no en
> el slot), **pero la elección del formatter es crítica para la independencia de Bootstrap Italia**: el
> formatter **"Rendered entity"** (`entity_reference_entity_view`) renderiza la **entidad media completa** en
> su view mode, que en este subtema atraviesa las plantillas de **Bootstrap Italia** (markup heredado dentro
> del slot) y además trae más envoltorio del que una tarjeta necesita. La vía limpia y anti-BI es un formatter
> que emita **solo la `<img>`**: **"Thumbnail"** (`media_thumbnail`) con un **image style** seleccionado (no
> vacío) y *Link image to* = *Nothing*. Saca la imagen del thumbnail de la media sin renderizar la entidad, de
> modo que al slot llega una `<img>` y nada de Bootstrap Italia. El recorte (p. ej. circular) lo aporta el CSS
> del componente, no el image style. **Este matiz se incorporó al modelar la entidad Faculty** (ver
> `../../entities/faculty-member.md` §4.2): la primera versión usó "Rendered entity" y metía markup BI; se
> corrigió a `media_thumbnail`.

### 5.5. La variante del componente

Muchas tarjetas tienen **variantes** (versiones visuales del mismo componente). Si el componente solo
**pinta el hueco de imagen en una variante concreta** (p. ej. una variante "image"), hay que
**seleccionar esa variante** en la configuración del componente (en el formulario del row, el selector
*Variant*, arriba del todo, antes de los slots). Con la variante por defecto, el dato de imagen puede
llegar correctamente al slot y **aun así no pintarse**, porque la plantilla de esa variante no dibuja el
hueco.

> **Lección aprendida.** En el piloto, con todos los slots bien mapeados (imagen incluida vía
> `view_field` con su formatter), la imagen seguía sin verse hasta seleccionar la variante adecuada del
> componente. La variante es, por tanto, parte del mapeo a revisar cuando una pieza no aparece.

### 5.6. Diagnóstico por comparación: checklist de un slot que no pinta

Cuando un slot no muestra su contenido, comparar contra un slot que **sí** funciona (o contra la vista
heredada equivalente) y revisar, en orden:

1. **¿El campo existe en el bundle** que la vista lista? (Un slot mapeado a un campo de otro bundle queda
   vacío.)
2. **¿La fuente del slot es la correcta?** Para imagen, `view_field` (no `entity_field`); para texto,
   `view_field` o `[Field item] Text value`.
3. **Si es `view_field`: ¿está el campo añadido en *Fields*** y, si es imagen, **con formatter Image e
   image style no vacío**?
4. **¿La variante del componente** es la que pinta ese slot? (Ver §5.5.)
5. **¿Hay un resto de configuración anterior** (un mapeo `entity_field` previo no eliminado) pisando el
   nuevo?

> Confirmar siempre **de qué entorno** procede el dato observado (local `*.ddev.site` vs. hosting) antes
> de diagnosticar, para no mezclar entornos.

### 5.7. Variante: una sola instancia (el hero de página)

El mismo flujo **Views → UI Patterns** sirve para alimentar **un componente de instancia única**, no solo
una colección de tarjetas. El caso es el **hero de página**: una vista devuelve **un** hero (el de la
página) y un componente (`ula_hero`) lo pinta. Es el patrón que consume el tipo de contenido `hero` (ver
`../../entities/hero.md`) y el componente `ula_hero` (ver `../../COMPONENTS.md` §1.3).

Difiere del caso de colección (§5.1) en dos cosas:

- **No hay Nivel 1 (contenedor/rejilla).** Una instancia única no necesita un grid que envuelva filas: solo
  se usa el **Row** = `Component` `bootstrap_ula_lscm:ula_hero`, con sus slots alimentados por `view_field`
  (`eyebrow`←`field_hero_eyebrow`, `title`←`field_hero_title`, `title_highlight`←`field_hero_highlight`,
  `subtitle`←`field_hero_subtitle`, `actions`←`field_hero_ctas`, `stats`←`field_hero_stats`) y la prop
  `size` fijada a `page`.
- **La vista devuelve la instancia que toca con un _filtro contextual_.** En vez de listar una colección,
  `hero_view` tiene un **filtro contextual** sobre `field_target_page` —el campo del hero que **referencia
  el nodo de la página**— con valor por defecto **«ID de contenido desde la URL»**, y se limita a **1
  resultado**. Al renderizarse en `/about` (nodo 93), el argumento es ese nodo y la vista devuelve el hero
  cuyo `field_target_page` apunta a él. El emparejamiento «esta página ↔ este hero» lo hace el **argumento
  de la URL**, no un filtro fijo.

```
Vista hero_view (display de bloque, en la Sección 0 del LB de la página)
└── Row: Component  →  bootstrap_ula_lscm:ula_hero  (prop size = page)
        slots ← view_field (eyebrow/title/title_highlight/subtitle/actions/stats)
   [Filtro contextual: field_target_page = nodo de la URL · tipo = Hero · límite 1]
```

**La colección anidada (stats), por composición.** Las estadísticas del hero **sí** son una colección, pero
**dentro** del único nodo (campo multivalor `field_hero_stats`), no filas de la vista. Se renderizan como
*Rendered entity*; cada paragraph `hero_stat` pasa por su plantilla
(`templates/content/paragraph--hero-stat.html.twig`), que **incluye** el componente `ula_hero_stat`. Así una
colección dentro de una entidad se pinta como varios componentes **sin** *field formatter* de UI Patterns
(que este sitio no tiene) — ver `../../entities/hero.md` §3 y `../../CONCEPTOS-DRUPAL.md` (composición de
SDC). Es el mismo mecanismo de "varios" que ya da un campo multivalor mapeado a un slot (como las CTAs).

**Por qué filtro contextual por el nodo (y no taxonomía fija).** El diseño inicial (v1.6.0) usaba un
**filtro fijo por término** (`field_hero_page` = un término del vocabulario `page_id`): sólido, pero **no
escalable** — cada página obligaba a **duplicar la vista** con otro término. Se rediseñó a **filtro
contextual por el nodo de la página** (campo `field_target_page` → nodo `lb_contents`). La incógnita que en
su día frenó el contextual —cómo pasar el argumento desde Layout Builder— **se disolvió** al usar **«ID de
contenido desde la URL»** como valor por defecto: ese origen lee el **nodo de la ruta**, no el contexto de
LB, así que funciona con el bloque embebido **sin depender de LB**. Validado en `/about` (con una vista de
prueba que, embebida en el LB, recibía el nid 93 de la página). Coste asumido: el hero referencia el
**nodo** de la página, no un término; al editar un hero se elige la página destino. Resultado: **una sola
`hero_view` sirve el hero de todas las páginas**.

**Full-bleed (presentación, no Views).** En la variante `page`, el hero rompe el contenedor de contenido del
marco (`.lscm-page__container`, max-width 1200px) para ocupar **todo el ancho** y pegarse bajo el header,
como la portada. Esto es CSS del componente (`ula_hero.css`), **requiere página de una columna** (sin
sidebars) y compensa el `padding-top` del marco; los detalles y avisos están comentados en el propio CSS. No
es un asunto de Views ni de Layout Builder.

### 5.8. Slots opcionales: el guard de presencia con Twig debug

Un componente slot-based pinta cada bloque **por presencia** (`{% if slot %}`): si el slot trae contenido lo
muestra, si está vacío lo omite (o pinta un respaldo). En el flujo Views → UI Patterns ese guard ingenuo
**falla**, y la causa es sutil: **un campo de la vista sin valor NO llega al slot como cadena vacía**. Con el
**Twig debugging ACTIVADO** —lo habitual en local— Views envuelve cada campo en comentarios de depuración:

```html
<!-- THEME DEBUG -->
<!-- THEME HOOK: 'views_view_field' -->
<!-- BEGIN OUTPUT from '.../views-view-field.html.twig' -->
<!-- END OUTPUT from '.../views-view-field.html.twig' -->
```

Aunque el campo esté vacío, el slot recibe **esos comentarios** (y espacios). Para Twig, eso es una cadena
**no vacía** → `{% if slot %}` da **siempre verdadero** → el bloque se pinta aunque no haya dato, y el
respaldo (p. ej. el retrato de iniciales cuando no hay foto) **nunca** aparece.

**Guard fiable**, válido con Twig debug ON y OFF: renderizar el slot, **eliminar los comentarios HTML** y ver
si queda algo:

```twig
{%- set _has_value = slot is defined and (slot|render|preg_replace('/<!--.*?-->/s', '')|trim) is not empty -%}
{% if _has_value %} … {% else %} … {% endif %}
```

Cuando hay dato, tras quitar comentarios queda contenido real (texto, una `<img>`, etc.) → verdadero. Cuando
el campo venía vacío, solo quedaban comentarios → cadena vacía → falso. En producción (debug OFF) el slot
vacío suele ser ya falsy, pero **el guard tiene que funcionar también en local** (donde se desarrolla): un
guard que solo acierta en producción es una trampa para quien trabaje en local.

> **Aviso de dependencia.** El filtro `preg_replace` en plantillas Twig **no siempre está disponible** (puede
> requerir Twig Tweak u otra extensión). Si el entorno no lo tiene, la plantilla dará error de "filter
> preg_replace does not exist"; en ese caso, una alternativa sin dependencias es trocear por los marcadores de
> comentario (`split` por `<!--` / `-->`) y comprobar si queda alguna etiqueta. Verificar en el Drupal real.

> **Lección aprendida (Faculty, slot `image` de `ula_faculty_card`).** Con `{% if image %}`, las tarjetas
> **sin** foto no mostraban el retrato de iniciales (el slot vacío no era falsy por los comentarios de debug);
> al endurecer el guard a "buscar literalmente `<img`" se rompió el caso **con** foto. El guard correcto es el
> de arriba (quitar comentarios y mirar si queda algo). El detonante se confirmó comprobando que el Twig
> debugging estaba activado, **no** suponiéndolo.

### 5.9. Enlace/botón a la página de la entidad: «Link to Content»

§5.2 explica que `link_to_entity: true` enlaza un campo a la página del nodo. Eso sirve cuando el **texto del
enlace es el propio valor del campo** (el nombre que enlaza a la ficha). Pero a menudo una tarjeta necesita un
**botón con texto fijo** —«View profile»— que apunte al nodo. Ahí hay tres caminos, y solo uno es limpio:

- **`link_to_entity` + texto reescrito** (*Rewrite results → Override the output… with custom text*): **NO
  funciona**. Al reescribir el texto, Views **descarta el `<a>`** que aportaba `link_to_entity`; al slot llega
  el texto pelado «View profile» **sin enlace**, y el CSS del botón (que estila un `<a>`) no encuentra nada que
  pintar.
- **«Output this field as a custom link»** (enlace personalizado con *Link path*): exige escribir la ruta con
  un **token** (nid o alias) que la vista debe exponer en *Replacement patterns*. Si la vista **no expone** un
  token de ruta (solo tokens de campos de texto), este camino obliga a **añadir y reordenar** un campo de ruta
  solo para esto. Frágil; se descarta salvo necesidad.
- **Campo «Link to Content»** (`view_node`) — **la solución canónica.** Es un campo de Views (*Add → "Link to
  Content"*, descripción «Provide a view link to the Content») que emite directamente
  `<a href="/ruta-del-nodo">TEXTO</a>`, con el **texto del enlace** que se escribe en su opción *Text to
  display*. Se desactiva su etiqueta, se pone *Text to display* = «View profile» y se mapea el slot `link` a
  ese campo vía `view_field`. El `<a>` llega hecho desde la vista y el CSS del botón lo estila.

> **Lección aprendida (Faculty, slot `link` de `ula_faculty_card`).** El botón «View profile» salía como texto
> plano porque el campo usaba `link_to_entity` + texto reescrito (se perdía el `<a>`). La vista **no exponía**
> token de ruta en *Replacement patterns* (solo campos de texto), así que «custom link» no era viable sin
> añadir campos. Se resolvió sustituyendo ese campo por **«Link to Content»** con *Text to display* = «View
> profile». Es el mecanismo a usar siempre que se quiera un botón de texto fijo hacia la página de la entidad.

### 5.10. Un slot alimentado por varias fuentes

Un slot **no** está limitado a una sola fuente: en el formulario del row se pueden **añadir varias fuentes** a
un mismo slot, y UI Patterns las **concatena** por orden de su peso (`_weight`). Esto es útil cuando dos campos
son **mutuamente excluyentes por entidad** y deben ocupar el **mismo hueco visual**: cada fila rellena uno u
otro, nunca los dos, así que el slot muestra el que tenga valor.

> **Lección aprendida (Faculty, slot `affiliation`).** La afiliación de un profesor es el **acrónimo de su
> universidad interna** (vía relación, §5.11) **o** un **texto externo** (`field_ct_fcltmb_affil_external`),
> nunca ambos. Se mapearon **las dos** fuentes al slot `affiliation` (acrónimo con `_weight` 0, externo con
> `_weight` 1); como en cada nodo solo una tiene valor, el slot pinta la correcta. Difiere del patrón de
> `consortium_universities`, donde cada slot tenía una única fuente; por eso se documenta aquí.

### 5.11. Leer un campo de una entidad referenciada (relación no requerida)

Un dato que la tarjeta necesita puede vivir **no en la entidad de la fila, sino en otra entidad que esta
referencia**. El caso típico: la tarjeta lista nodos A (faculty) pero quiere mostrar un campo que está en el
nodo B (universidad) al que A apunta por un campo de referencia. La vía en Views:

1. **Añadir una relación** (*Advanced → Relationships*) sobre el campo de referencia de A hacia B (p. ej.
   `field_ct_fcltmb_affil_internal` → Content).
2. **Marcarla como NO requerida** (`required: false`). Esto es **crítico**: una relación **requerida** es un
   *inner join* y **elimina de la vista todas las filas A que no tengan la referencia rellena** (si los nodos
   no tienen afiliación interna, desaparecen todos). No requerida es un *left join*: las filas A se conservan, y
   el campo de B sale vacío donde no haya referencia.
3. **Añadir el campo de B** (p. ej. `field_uni_abbr`) y, en su configuración, fijar el desplegable
   **«Relationship»** a la relación creada (por defecto pone *Do not use a relationship*). Eso es lo que hace
   que el campo se lea **del nodo B**, no de A.

> **Lección aprendida (Faculty, acrónimo de universidad).** El acrónimo (UAB…) vive en el nodo **universidad**
> del consorcio, no en el faculty. Se trajo con una relación **no requerida** sobre `affil_internal` y el campo
> `field_uni_abbr` colgado de esa relación. Síntoma a vigilar: al marcar la relación como requerida, el preview
> de la vista **se vacía entero** (desaparecen los nodos sin afiliación interna). La primera comprobación ante
> "se han ido todas las filas" es el flag `required` de las relaciones.

### 5.12. El contenedor de Nivel 1 puede ser un carrusel

§5.1 describe el Nivel 1 (contenedor) como una **rejilla** (`ula_grid_row`), pero el contenedor es
**intercambiable**: cualquier componente que reciba `view_rows` en un slot sirve. El tema incluye
**`ula_carousel`** (ver `../../COMPONENTS.md` §1.6) como Nivel 1 alternativo: en vez de disponer las filas en
una cuadrícula estática, las pagina en un **carrusel** (flechas, puntos, swipe; sin autoplay). El encaje en la
vista es idéntico al de la rejilla —*Format → Show: Component* = `bootstrap_ula_lscm:ula_carousel`, slot
`content` ← `view_rows`— y cambia solo la prop de disposición: `ula_carousel` expone **`visible`** (cuántas
tarjetas por vista: 3 escritorio / 2 tablet / 1 móvil) en lugar de `columns`. El Nivel 2 (la tarjeta) no se
entera de en qué contenedor vive.

> **Lección aprendida (Faculty).** La sección Faculty & Research de `/about` usa `ula_carousel` como Nivel 1 y
> `ula_faculty_card` como Nivel 2. Demuestra que la receta de §5.1 no está atada a la rejilla: el contenedor es
> una pieza más del modelo de dos niveles, sustituible sin tocar la tarjeta.

---

## 6. Validación: la prueba piloto `/about-lb`

El modelo se validó con una **prueba piloto** sobre un nodo en `/about-lb` (tipo de contenido de prueba
`lb_test`, con Layout Builder por override), que sirvió para **decidir entre Paragraphs y Layout Builder**
como mecanismo de composición. Sobre ese nodo se compusieron **varias secciones verticales** (una
columna y dos columnas), y la sección más compleja fue **un grid de tarjetas alimentado por la vista de
las universidades del consorcio** (`consortium_universities`, display de bloque), que tras aplicar el
flujo de §5 renderizó las tarjetas completas (título, subtítulo, texto e imagen).

> **Alcance del piloto.** `/about-lb` es un **banco de pruebas** que validó *que el mecanismo funciona*
> (composición multi-sección + vista que pinta entidades con tarjetas). **No** es la composición
> definitiva de ninguna página real: contiene bloques de relleno de prueba que no forman parte del
> modelo. Lo que este documento eleva a modelo es **el mecanismo** (§3–§5), no el contenido concreto del
> piloto.
>
> **About es solo la primera.** El piloto se hizo de cara a About, pero About es **una** de las muchas
> páginas no-home que adoptarán este modelo (Contents, Admission, Eligibility, Student Hub…). El modelo
> es lo reutilizable; About es su primer caso de aplicación.

---

## 7. Independencia de Bootstrap Italia en este modelo

- El contenedor (rejilla) y la tarjeta de cada fila deben ser **componentes propios `ula_*`**, no los
  heredados de Bootstrap Italia. El piloto se construyó, por disponibilidad inmediata, con una tarjeta
  heredada; **esa tarjeta es lo primero que se rehará** en clave propia, y este documento habla de
  "tarjetas / cards" en general precisamente porque el componente concreto es transitorio.
- El **aspecto** (grid, espaciado, estilo de la tarjeta) lo aporta el **CSS propio** del design system,
  no clases del framework heredado (`container/row/col/it-*`).
- El **contenido rich text** que entre en los slots debe usar formatos que **no inyecten markup ni clases
  de Bootstrap Italia** (p. ej. Basic HTML), conforme a la regla general del proyecto.
- No se introduce **ninguna dependencia nueva** de Bootstrap Italia en las páginas compuestas con este
  modelo.

---

## 8. Implicación para la configuración (sitio sin config/sync)

Todo lo que se compone con Layout Builder —las secciones del nodo, los bloques, la configuración de la
vista y su mapeo a componentes— es **configuración**, y en este sitio la configuración vive **solo en la
base de datos** (no hay `config/sync`; ver `../../ARCHITECTURE.md` §6.1).

Implicaciones prácticas:

- **Antes de tocar la composición** (activar LB, crear/editar la vista, cambiar el mapeo): **dump de BD**
  como red de seguridad. Es la única forma de revertir.
- **Git versiona el código** (componentes, plantillas, CSS, esta documentación), **no** la composición de
  las páginas ni las vistas.
- Adoptar LB **aumenta** la cantidad de configuración no versionada en BD. Es el coste aceptado en el
  ADR-LAYOUT-004, y refuerza el TO-DO transversal de **valorar la adopción de gestión de configuración**.

---

## 9. Pendientes específicos de este elemento

- **9.1. Mecanismo del grid de tarjetas (CSS propio vs. rejilla).** Definir y documentar cómo se aplica el
  **grid** a la colección de tarjetas: si mediante un componente contenedor de rejilla propio (Nivel 1), o
  dejando el *Format* en lista y resolviendo el grid horizontal con **CSS propio `ula_*`** sobre el
  contenedor de la vista (`.view-<id>`). Tiene implicaciones más allá de "una regla CSS" (responsive,
  reutilización entre páginas, relación con las capas de CSS del tema).
  **✓ Resuelto:** se optó por el **componente contenedor de rejilla propio** y se construyó `ula_grid_row`
  (CSS Grid, columnas responsive; ver `../../COMPONENTS.md` §1.2). Queda como paso siguiente su **adopción**
  en las vistas existentes (p. ej. universidades), hoy aún sobre el `grid_row` heredado.
- **9.2. Rehacer la tarjeta en clave propia.** La tarjeta usada en el piloto es un componente heredado de
  Bootstrap Italia; rehacerla como componente `ula_*` propio es el primer paso de migración tras esta
  documentación. (Anotado también como pendiente transversal del design system.)
  **✓ Resuelto:** se construyó `ula_card_simple` (tarjeta propia por slots, fondo claro; ver
  `../../COMPONENTS.md` §1.1) como sustituta de la heredada `card2_simple`. Queda como paso siguiente su
  **adopción** en la vista de universidades, que aún usa la heredada.
- **9.3. Tipo de contenido definitivo de las páginas.** El piloto usó un tipo de prueba (`lb_test`).
  **Actualización (v1.6.0):** las páginas de contenido reales se modelan con el tipo **`lb_contents`**
  (About es un nodo `lb_contents`, con LB por override); `lb_test` queda como tipo de prueba **a retirar**
  (ver `TODO.md` #8). Queda **abierto** decidir formalmente si `lb_contents` es el tipo definitivo (o se
  renombra a un genérico) y si LB se activa por tipo o por nodo. **Parcialmente resuelto.**
- **9.4. Página de detalle de las entidades.** Las entidades que se muestran como tarjetas (p. ej. las
  universidades) tienen además su página de nodo, **hoy sin diseñar** (ver
  `../../analysis/about-and-university-entity.md` §2.2 y §3.3). Pendiente, ligado a este modelo.

---

## 10. ADR-LAYOUT-004 — Adopción de Layout Builder como mecanismo de composición de páginas no-home

**Contexto.** Las páginas no-home (About, Contents, Admission, Eligibility, Student Hub…) necesitan un
mecanismo para componer su contenido interno (secciones apiladas con bloques heterogéneos: grids de
tarjetas, texto, etc.) dentro del marco compartido (`SHARED-FRAME-LAYOUT.md`). En la documentación previa
del proyecto, **Layout Builder figuraba como descartado** (`../../ARCHITECTURE.md` §5.2 y §6.1, y el
documento de la home): ese descarte se decidió **para la home**, en un momento en que no se había logrado
hacer funcionar el flujo de composición LB + Views + UI Patterns. Ese flujo **ya se ha validado** (piloto
`/about-lb`, §6): una página compuesta en secciones con LB, y dentro de una sección una vista que pinta
entidades del sitio con tarjetas propias.

**Decisión.**
1. **Adoptar Layout Builder como mecanismo de composición del contenido de las páginas no-home.** Cada
   página se modela como un **nodo** con LB (override por nodo), compuesto en **secciones** verticales;
   cada sección contiene **bloques** (§3–§4).
2. **El caso central de bloque es una vista que pinta entidades con componentes propios** (tarjetas) vía
   el flujo Views → UI Patterns, alimentando todos los slots por **`view_field`** (§5).
3. **El aspecto lo aporta el design system propio `ula_*`**, sin dependencias nuevas de Bootstrap Italia
   (§7).

**Reconciliación con el descarte previo (home).** Esta decisión **no contradice** la de la home: son
contextos distintos. La home es una **portada única y a medida**, para la que una plantilla Twig propia
(ADR-001) sigue siendo la solución vigente. Las páginas no-home son **muchas y de estructura repetible**,
para las que la composición por secciones de LB es lo apropiado. El descarte de LB documentado en
`../../ARCHITECTURE.md` §5.2/§6.1 debe leerse como **"descartado para la home, en su momento y por el
estado de conocimiento de entonces"**, no como un descarte permanente y global; esas secciones se matizan
en consecuencia.

**Alternativas consideradas.**
- *Paragraphs.* Considerada en el piloto. Un Paragraph **no produce una ruta ni una página**: vive
  **dentro** de un nodo como contenido de un campo. Sirve para estructurar el cuerpo de una entidad, pero
  no para "componer una página" en el sentido de secciones de layout con bloques heterogéneos (vistas,
  campos, componentes). Descartada como mecanismo de composición de página frente a LB.
- *Replicar el mecanismo de la home (nodo + plantilla Twig + preprocess→prop) para cada página no-home.*
  Descartada: obligaría a programar una plantilla a medida por página, costoso y poco mantenible para un
  conjunto amplio y heterogéneo de páginas; y no lo podría manejar un editor.
- *Vista con display de página como "la página entera".* Descartada como modelo general: encierra la
  estructura de la página en la configuración de una vista, poco flexible para apilar secciones
  heterogéneas; las vistas se usan **dentro** de las secciones (como bloques), no como la página entera.

**Consecuencias.**
- **Composición flexible y reutilizable** página a página, manejable por un site builder.
- **Coste de configuración en BD:** LB guarda la composición como configuración no versionada (sitio sin
  `config/sync`). Mitigación: disciplina de **dump antes de tocar** y refuerzo del TO-DO de adoptar
  gestión de configuración (§8).
- **Convivencia de dos modelos de página** durante y después de la transición: la home con plantilla Twig
  propia; las no-home con LB. Es deliberado.
- **Primer trabajo derivado:** rehacer la tarjeta del piloto como componente `ula_*` propio (§9.2), y
  decidir el tipo de contenido definitivo de las páginas (§9.3).

**Relación con otros ADR.**
- **ADR-001 (home)** — la home se sirve con nodo + plantilla Twig; este ADR no la altera, convive con
  ella.
- **ADR-LAYOUT-001/-003** — el marco (`page--<ruta>` → `page.html.twig` propio) envuelve estas páginas;
  LB compone su contenido interno. Marco y composición son complementarios.
