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

### 3.1. Campos a añadir (para alimentar `ula_uni_card` en la home)

`ula_uni_card` necesita: `name`, `description`, `flag`, `country`, `abbr`, `tags`. Frente a lo que
ya hay:

| Prop de `ula_uni_card` | Origen | ¿Acción? |
|---|---|---|
| `name` | `title` | Ya existe. |
| `description` | `body` (¿encaja en tarjeta compacta?) | Decidir: reutilizar `body` o crear descripción corta propia. |
| `flag` | — | **Decidir:** ¿emoji (texto) o imagen? Si emoji → nuevo campo de texto. |
| `country` | — | **Añadir** campo de texto corto. |
| `abbr` | — | **Añadir** campo de texto corto. |
| `tags` (semestres) | — | **Diseñar:** ¿campo multivalor en la universidad, o relación con los semestres? (El más complejo.) |
| (enlace a `/node/N`) | URL canónica del nodo | No requiere campo; se enlaza en la vista con `link_to_entity`. |

**Principio:** **añadir** campos, no modificar ni borrar los existentes, para no afectar a la página
About que ya los usa.

### 3.2. Representaciones futuras de la entidad

La universidad podría tener (algunas ya, otras a futuro):

1. **Tarjeta en About** — existe (a rehacer en clave propia al independizar About).
2. **Tarjeta en la home** (`ula_uni_card`) — a construir ahora (piloto de colecciones editables).
3. **Página de detalle propia** (`/node/N`) — hoy sin diseñar; a rehacer.

Cada representación es una **vista o display distinto** sobre la misma entidad. Conviene tenerlas
todas en mente al decidir los campos, para que la entidad sirva a las tres sin duplicar datos.

### 3.3. Cuestiones abiertas

- **`flag`:** emoji vs imagen (la maqueta de la home sugiere emoji 🇪🇸🇱🇻🇩🇪; confirmar).
- **`description`:** ¿reutilizar `body` o texto corto propio para la tarjeta de la home?
- **`tags`/semestres:** cómo se modela la relación universidad ↔ semestres en los que se estudia.
- **Enlace de la tarjeta de la home:** ¿debe `ula_uni_card` enlazar a la página de detalle? Si sí,
  hay que **añadir una prop de URL** al componente (hoy no la tiene) — decisión sobre el componente,
  registrar en la doc de la home.
- **Página de detalle sin diseñar:** pendiente de rehacer (no urge para la home, pero queda anotado).
- **Formato BI del campo modal:** `field_about_conuni_modal_text` arrastra Bootstrap Italia; resolver
  al independizar About.

---

## 4. Relación con el trabajo en curso

Este análisis surgió al abordar la **Fase 1 (piloto universidades)** del plan
`../plans/home/plan-colecciones-editables-e-interactividad.md`. Las decisiones de §3.1 y §3.3
alimentan directamente el diseño de los campos a añadir y de la vista de la home. El resto (rehacer
About, rehacer la página de detalle) queda registrado para cuando se aborden esas secciones.
