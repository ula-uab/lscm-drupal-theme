# Análisis — Página About y la entidad "Universidad del consorcio"

> **Tipo de documento:** hallazgo de investigación. Registra el estado actual de una sección existente
> del sitio (heredada, construida sobre Bootstrap Italia) **antes** de rehacerla en clave propia.
> No describe cómo *debería* ser, sino cómo *es hoy*, más las opciones de diseño detectadas.
>
> **Fecha del análisis:** 2026-06-13.
> **Motivo:** al construir la sección de universidades de la home (que reutiliza la entidad
> `ct_about_consortium_university`), se inspeccionó cómo está modelada y usada esa entidad hoy.

---

## 1. La entidad: tipo de contenido `ct_about_consortium_university`

Las universidades del consorcio son **nodos** de este tipo de contenido. Cada universidad tiene su
**propia página de nodo** (p. ej. la UAB es `/node/13`).

**Campos actuales:**

| Campo | Machine name | Tipo | Uso observado |
|---|---|---|---|
| Título | `title` | (base) | Nombre de la universidad. |
| Body | `body` | text_with_summary | Descripción. |
| Image | `field_image` | image | Imagen grande (logo/foto) para la card de About. |
| Order | `field_order` | integer | Orden de aparición. |
| Modal - Text | `field_about_conuni_modal_text` | text_long | Texto ampliado que se muestra en un modal "+ info". **Formato Bootstrap Italia 2.** |

**Organización del formulario de edición:** los campos están agrupados con **field_group** en dos
pestañas: `group_card` (Title, Summary, Body, Image, Order) y `group_modal` (Modal - Text).

**Observaciones / deuda detectada:**
- `field_about_conuni_modal_text` usa **formato de texto de Bootstrap Italia**, lo que lo ata al
  tema base. Es un punto a resolver cuando se independice la sección About.
- **No existe** ningún campo para país, acrónimo, "bandera" (emoji), ni semestres asociados. La
  entidad está modelada para lo que About necesita hoy, no para una ficha completa de universidad.

---

## 2. Cómo se muestra hoy (dos representaciones)

La misma entidad universidad se renderiza hoy de **dos formas distintas** (ejemplo de "una entidad,
varias representaciones" — ver `../ARCHITECTURE.md` §5.3):

### 2.1. Como tarjeta en la página About (vía vista `page_about_consortium`)

- **Vista:** `page_about_consortium`. **No tiene display de página propio** (no responde en una URL
  suelta); se integra dentro de la página About.
- **Patrón de dos niveles** (ver `../ARCHITECTURE.md` §5.5):
  - **Contenedor:** componente `bootstrap_ula_lscm:grid_row` (rejilla Bootstrap), 3 columnas en
    escritorio (`col_lg: 4`), 1 en móvil (`col_xs: 12`).
  - **Tarjeta (row):** componente `bootstrap_ula_lscm:card2_simple`, variante `image`, con este mapeo:
    - slot `card_title` ← campo `title` (**con enlace al nodo**, vía `link_to_entity: true`).
    - slot `card_image` ← campo `field_image`.
    - slot `card_text` ← campo `body` **+** un componente anidado `bootstrap_ula_lscm:modal2`
      (modal de Bootstrap Italia) con botón **"+ info"**, cuyo cuerpo (`modal_body`) ← campo
      `field_about_conuni_modal_text`.
- **Orden:** por `field_order` (asc).
- **Los dos elementos interactivos de la tarjeta de About:**
  1. El **título enlaza** a la página de la universidad (`/node/N`) — vía `link_to_entity`.
  2. El botón **"+ info"** abre un **modal** (Bootstrap Italia) con el texto ampliado.

> **Lección aprendida (añadido v1.5.1).** Este mapeo es **la referencia que funciona**: al construir la
> vista equivalente en clave propia se replicó exactamente este patrón (slots por **`view_field`**,
> formatter de imagen **en el campo** de la vista, **variante** del componente que pinta la imagen,
> `link_to_entity` para el enlace, componente de modal anidado en el slot de texto). El detalle del flujo
> y un checklist de diagnóstico están en `../elements/layout/CONTENT-LAYOUT.md` §5. La forma correcta de
> abordar la vista nueva era **partir de este análisis y comparar** con esta vista que ya funcionaba,
> antes de construir desde cero.

### 2.2. Como página de nodo (`/node/N`) — SIN DISEÑAR

- Al visitar la página propia de una universidad, Drupal renderiza el **Manage display** del modo
  Default, que hoy muestra **todos los campos apilados uno debajo de otro** (Image, Body, Links,
  Modal-Text, Order), sin diseño.
- **Problema detectado:** el campo `field_about_conuni_modal_text` aparece **suelto al final** de la
  página (porque su display no está oculto), cuando su propósito es mostrarse *dentro del modal* en
  la tarjeta de About. En la página de nodo queda fuera de contexto.
- **Conclusión:** la página de detalle de la universidad **está sin diseñar**; es una de las cosas a
  rehacer.

**Componentes de Bootstrap Italia implicados** (a sustituir al independizar): `grid_row`,
`card2_simple`, `modal2`, y el formato de texto BI del campo modal.

---

## 3. Opciones de diseño para la entidad "Universidad"

Decidido ya que las universidades son **una entidad única reutilizable** (las mismas en About y en la
home — ver `../ARCHITECTURE.md` §5.3), estas son las opciones y cuestiones de diseño abiertas para
ampliarla sin romper su uso actual.

### 3.1. Campos a añadir (DECIDIDO) — para alimentar `ula_uni_card` en la home

`ula_uni_card` necesita: `name`, `description`, `flag`, `country`, `abbr`, `tags`. Decisiones tomadas
(2026-06-13):

| Prop de `ula_uni_card` | Origen | Decisión |
|---|---|---|
| `name` | `title` | Ya existe (sin cambios). |
| `flag` | nuevo `field_uni_flag` (texto corto) | **Emoji** de bandera (🇪🇸🇱🇻🇩🇪). Campo de texto. |
| `country` | nuevo `field_uni_country` (texto corto) | **Añadir.** |
| `abbr` | nuevo `field_uni_abbr` (texto corto) | **Añadir.** |
| `description` | nuevo `field_uni_home_pitch` (string_long) | **Campo propio**, NO se reutiliza `body`: mensaje *engaging* para la tarjeta de la home (el `body` es la descripción formal de About). |
| `tags` (semestres) | (pendiente — ver §3.4) | **No se implementa ahora.** Previsto como relación universidad↔semestre. La tarjeta del piloto se renderiza sin tags. |
| (enlace a `/node/N`) | URL canónica del nodo | No requiere campo; se enlaza en la vista con `link_to_entity`. |

**Principio:** **añadir** campos, no modificar ni borrar los existentes, para no afectar a la página
About que ya los usa.

**Machine names de los campos nuevos:** `field_uni_flag`, `field_uni_country`, `field_uni_abbr`,
`field_uni_home_pitch`.

### 3.2. Representaciones de la entidad

La universidad tiene (algunas ya, otras a futuro):

1. **Tarjeta en About** — existe (a rehacer en clave propia al independizar About).
2. **Tarjeta en la home** (`ula_uni_card`) — en construcción (piloto de colecciones editables).
3. **Página de detalle propia** (`/node/N`) — hoy sin diseñar; a rehacer.

Cada representación es una **vista o display distinto** sobre la misma entidad. Conviene tenerlas
todas en mente al decidir los campos, para que la entidad sirva a las tres sin duplicar datos.

### 3.3. Cuestiones abiertas (actualizadas)

- **Enlace de la tarjeta de la home:** ¿debe `ula_uni_card` enlazar a la página de detalle? Si sí,
  decidir si se **añade una prop de URL** al componente (hoy no la tiene) o si el enlace envuelve la
  tarjeta desde la vista. Se resolverá al construir la vista del piloto.
- **Página de detalle sin diseñar:** la página `/node/N` muestra los campos en crudo; pendiente de
  rehacer (no urge para la home, pero queda anotado).
- **Formato BI del campo modal:** `field_about_conuni_modal_text` arrastra Bootstrap Italia; resolver
  al independizar About.
- *(Resueltas: `flag` → emoji; `description` → campo propio `field_uni_home_pitch`; `tags` → ver §3.4.)*

### 3.4. PENDIENTE DE MODELAR — Relación universidad↔semestre (las pastillas `tags`)

> **Estado:** diseño previsto, **no implementado**. Se abordará cuando se modele la entidad
> "semestre" (probablemente al rehacer la sección de contenidos/semestres, que ya tiene entidades
> `ct_contents_subject` y vistas `page_contents_*`). El piloto de universidades (fase 1) se completa
> **sin** las pastillas.

**Qué son las pastillas.** En la tarjeta `ula_uni_card`, las pastillas (`tags`) indican los
**semestres en los que se estudia en esa universidad**. Cada pastilla tiene una etiqueta (p. ej.
"Semester 1") y, al pulsarla, mostrará un **modal/popover** con información.

**El dato clave (lo que condiciona el modelo).** El texto que se muestra en el modal **no es un
atributo de la universidad ni del semestre por separado**: depende de la **combinación** universidad
× semestre (y del rol de *lead partner*). Es decir, "la UAB en el Semestre 1" tiene un texto, y "la
RTU en el Semestre 3" tiene otro. Una información que depende de la combinación de dos entidades es
el signo de que **la combinación misma es una entidad** (una *entidad de relación* o "through
entity").

**Diseño previsto (a confirmar al implementar):**

- Una entidad **"Semestre"** (tipo de contenido propio), ya que la relación universidad↔semestre será
  relevante en otras partes del sitio (no solo en la tarjeta de la home).
- Una **entidad de relación universidad↔semestre** que represente "esta universidad EN este semestre",
  con sus campos propios — principalmente el **texto del modal** (dependiente de la combinación) y, en
  su caso, el rol de *lead partner*.
- La tarjeta de la home alimentaría sus `tags` (`{label, info}`) desde esa relación: `label` = el
  semestre; `info` = el texto del modal de esa combinación concreta.

**El componente ya está preparado.** `ula_uni_card` define `tags` como un array de objetos
`{label, info}` — exactamente "etiqueta de semestre + info para el modal". **No hay que tocar el
componente**; solo, en el futuro, alimentar esos `tags` desde la relación. La interactividad del
modal/popover en sí es el pendiente §5.3 de la home (`../elements/home/HOME-ARCHITECTURE.md`), a
resolver con **API nativa** del navegador (`popover`/`<dialog>`), sin Bootstrap.

**Valores exactos de las pastillas en la maqueta (a reproducir cuando se modele la relación).**
Al migrar las universidades a editables (Opción 3) las pastillas se dejaron vacías (`tags: []`), pero
el array de fábrica de la maqueta contenía estos valores, que son el punto de partida de lo que la
relación universidad↔semestre debe acabar generando:

| Universidad | Pastillas (`label`) en la maqueta |
|---|---|
| UAB (🇪🇸) | `Semester 1` · `Lead Partner` |
| RTU (🇱🇻) | `Semester 2` · `Semester 3 & 4 (option)` |
| UASW (🇩🇪) | `Semester 3 & 4 (option)` |

> Obsérvese que estas pastillas mezclan dos cosas distintas: **semestres** ("Semester 1", "Semester 2",
> "Semester 3 & 4 (option)") y un **rol** ("Lead Partner"). Esto confirma que la relación
> universidad↔semestre lleva datos propios (el rol, el carácter opcional de un semestre, y el texto
> del modal), reforzando que es una **entidad de relación** y no un simple campo multivalor. El
> "info" de cada pastilla (el texto del modal) aún no existía en la maqueta; se añadirá al modelar
> la relación.

**Por qué no se hace en el piloto.** La "info" del modal aún no existe como contenido y depende de un
modelo (semestres + relación) que se diseñará en su momento. Modelarlo ahora agrandaría el piloto
mucho más allá de su propósito (validar el mecanismo tipo de contenido → vista → componente). Se
prioriza cerrar el piloto con los campos 1-4 y dejar las pastillas previstas.

---

## 4. Relación con el trabajo en curso

Este análisis surgió al abordar la **Fase 1 (piloto universidades)** del plan
`../plans/home/plan-colecciones-editables-e-interactividad.md`. Las decisiones de §3.1 y §3.3
alimentan directamente el diseño de los campos a añadir y de la vista de la home. El resto (rehacer
About, rehacer la página de detalle) queda registrado para cuando se aborden esas secciones.
