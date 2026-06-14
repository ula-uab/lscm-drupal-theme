# Entidad — `ct_programme_specialisation` (Programme specialisation)

> **Tipo de documento:** diseño de una **entidad propia** del tema (no heredada). Ver `entities/`.
>
> **Creada en:** v1.1.5 · **Mecanismo de consumo:** preprocess → prop (ver
> `../elements/home/HOME-ARCHITECTURE.md` ADR-002).

---

## 1. Qué es y por qué existe

`ct_programme_specialisation` modela las **especializaciones/itinerarios** del máster. Cada nodo es
una especialización. Alimenta la sección de especializaciones de la home (componente `ula_spec_card`).

Es la primera colección que introduce **dos tipos de campo nuevos** respecto a las anteriores: una
descripción **enriquecida** (rich text) y una **imagen** referenciada de la biblioteca de Media. Por
eso su conexión requirió funciones auxiliares en el tema (ver §3) y el **rediseño del componente**
(ver §4).

---

## 2. Campos

| Campo | Tipo | Para qué |
|---|---|---|
| `title` (base) | — | Nombre de la especialización. → prop `title` (sobre la imagen). |
| `field_spec_location` | string | Ubicación: universidad · país (texto libre). → prop `location` (sobre la imagen). |
| `field_spec_description` | text_long (formato **Basic HTML**) | Descripción enriquecida: párrafos y listas (incluidos los módulos). → prop `description` (HTML). |
| `field_spec_image` | entity_reference → media (bundle `image`) | Imagen de fondo de la cabecera. → prop `image` (URL resuelta). |
| `field_order` | integer | Orden de aparición. |

**Sobre la descripción enriquecida.** Se usa el formato **Basic HTML** de Drupal, que permite
`<p>`, `<ul>`/`<ol>`/`<li>`, `<strong>`, `<em>`, `<a>`… pero **no admite el atributo `class`**, lo
que lo hace estructuralmente incapaz de inyectar markup de Bootstrap Italia. El campo está
**restringido a solo Basic HTML** (en "Allowed text formats"), de modo que el editor no puede elegir
otro formato (como "Bootstrap Italia 2") ni por error. El aspecto de los párrafos y listas lo da el
CSS propio del componente (no clases en el HTML). Los antiguos `modules[]` (que eran una invención de
la maqueta) se redactan ahora como una lista dentro de esta descripción.

**Sobre la imagen.** Es una referencia a la biblioteca de **Media** (bundle `image`), no un campo de
imagen simple: la imagen es reutilizable y se elige/sube desde la biblioteca al editar el nodo. Si un
nodo no tiene imagen, la cabecera del componente usa su color de respaldo.

---

## 3. Cómo se consume (lógica en el tema)

Mediante el cargador genérico `_bootstrap_ula_lscm_get_collection()` (ver ADR-002), pero con dos
**resolvers especiales** en el mapa (funciones auxiliares del `.theme`), porque dos campos no son
texto plano:

```
specializations  ← get_collection('ct_programme_specialisation', {
    title:       label del nodo,
    location:    field_spec_location (texto),
    description: _bootstrap_ula_lscm_text_value(nodo, 'field_spec_description'),   // rich text → HTML
    image:       _bootstrap_ula_lscm_media_image_url(nodo, 'field_spec_image'),    // media → URL
  })
```

- **`_bootstrap_ula_lscm_text_value()`** — renderiza un campo de texto con formato aplicando
  `check_markup` (aplica los filtros del formato y devuelve HTML saneado). El componente lo imprime
  con `|raw` (es seguro: Basic HTML ya saneó).
- **`_bootstrap_ula_lscm_media_image_url()`** — resuelve la cadena campo → entidad media → campo de
  imagen del media (`field_media_image`) → archivo → URL absoluta. Devuelve '' si falta algo.

Estas dos auxiliares son **reutilizables** por cualquier futura colección que tenga rich text o
imágenes de Media. El array se pasa como prop `specializations` al marco, que lo pinta con
`ula_spec_card`. Si la carga viene vacía, el marco usa su array de fábrica (`|default`).

---

## 4. Rediseño del componente `ula_spec_card`

Esta colección conllevó **rediseñar el componente** (no solo migrar datos). El diseño anterior tenía
cabecera de color plano con emoji + título + universidad, y cuerpo con descripción + lista de módulos
separada. El nuevo diseño:

- **Cabecera con imagen de fondo** + un overlay oscuro (degradado, más denso abajo) para legibilidad,
  con título + ubicación superpuestos en texto blanco/amarillo. Sin imagen → color de respaldo.
- **Cuerpo con la descripción enriquecida** (HTML), que ya incluye sus propias listas/párrafos.
- **Props nuevas:** `title`, `location`, `image`, `description` (HTML). Se eliminaron `icon`,
  `variant` y `modules`.
- El CSS del componente estila el HTML semántico de la descripción (`<p>`, `<ul>`/`<li>` con punto
  amarillo, `<ol>` con números) sin depender de clases.

---

## 5. Contenido actual (datos de la maqueta)

Dos especializaciones, con la descripción fusionando el párrafo original + los módulos como lista:

| order | title | location |
|---|---|---|
| 0 | Logistics Information Systems | Riga Technical University · Latvia |
| 1 | Logistics Systems Engineering | University of Applied Sciences Wildau · Germany |

Las **imágenes** se añaden manualmente desde la biblioteca de Media al editar cada nodo (no las pone
el script de creación).
