# Entidad — bloque de contenido `cta_band` (CTA band)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.6.2 · **Naturaleza:** **tipo de bloque de contenido** (`block_content`), **no** un
> tipo de contenido (nodo). · **Mecanismo de consumo:** bloque colocado en Layout Builder + **plantilla del
> bloque que compone un componente SDC** (`ula_cta_band`), distinto del patrón Views → UI Patterns del hero
> (ver `../COMPONENTS.md` §1.4 y `../CONCEPTOS-DRUPAL.md`, composición de SDC).

---

## 1. Qué es y por qué existe

`cta_band` modela una **franja / tarjeta de llamada a la acción** para el **cierre de una página**: el
bloque que va justo antes del footer con un título, un texto breve y un botón (en la maqueta de About,
«Ready to Apply?» + un párrafo + «Start your application»). La presentación la pone el componente propio
`ula_cta_band`: tarjeta al ancho del contenedor, **borde azul marcado** y **fondo claro**, sin romper el
contenedor de contenido.

**Por qué un tipo de bloque y no un tipo de contenido (nodo).** Un CTA band **no es una página** ni una
entidad navegable: es una pieza que se **coloca dentro** de una página, puede repetirse y variar de una
página a otra. Esa es exactamente la naturaleza de un **bloque de contenido** (`block_content`): trozos
editables y colocables, frente a los nodos, que son páginas. Modelarlo como block type permite crear un
**ejemplar por página** (con su propio texto) y colocarlo donde toque en Layout Builder.

**Por qué un block type propio y no un bloque de UI Patterns suelto.** Se valoró colocar el componente
directamente como bloque de UI Patterns (escribiendo el texto en la configuración del bloque). Se descartó
por la fragilidad conocida de UI Patterns con texto en slots en este sitio (ver `../../TODO.md`, nota sobre
`source_id`/`textfield`). El block type con campos + plantilla que compone el SDC es el mecanismo **conocido
y validado** (la misma idea de composición desde plantilla que el paragraph del hero), y encaja con que los
CTA bands sean **distintos por página** (un ejemplar por página).

**Por qué la presentación la aporta el componente y no el contenido.** El bloque solo guarda **datos**
(título, texto, enlace). El aspecto (borde azul, fondo claro, botón) lo pone el componente `ula_cta_band`
(design system `ula_*`), de modo que el contenido editable queda libre de markup y de clases de Bootstrap
Italia.

---

## 2. Campos (tipo de bloque `cta_band`)

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| **Block description** (base) | — | 1 | Nombre **administrativo** del ejemplar (p. ej. «CTA band — About»); identifica el bloque en la gestión. **No** se muestra al visitante. |
| `field_cta_title` | string | 1 | Título **visible** de la tarjeta («Ready to Apply?»). → slot `title`. |
| `field_cta_text` | string_long | 1 | Párrafo descriptivo. Texto plano. → slot `text`. |
| `field_cta_link` | link | 1 | Botón: **URL + texto del enlace**. → slot `actions`. |

**Por qué un `field_cta_title` aparte del título administrativo.** El título base del bloque es
**administrativo** (para identificarlo en la lista de bloques), no el título visible. Se crea
`field_cta_title` para el texto que se ve en la tarjeta, separando «cómo se llama el bloque en la gestión»
de «qué se ve», y para leerlo en la plantilla igual que los demás campos (`content.field_cta_*`), sin
recurrir a la etiqueta del bloque (cuyo acceso desde Twig es menos directo).

---

## 3. Cómo se consume (lógica en el tema)

El bloque **no** se visita como página: se **coloca** en una sección del **Layout Builder** de la página
(en About, la última sección, antes del footer), con la casilla **«Display title» desmarcada** (el título
visible es `field_cta_title`, dentro del componente, no la etiqueta administrativa). El flujo de render:

1. **Plantilla del bloque** `templates/content/block--block-content--type--cta-band.html.twig`. El nombre de
   esta plantilla **se confirmó con el debug de Twig**: la sugerencia que Layout Builder emite para este
   bloque es `block--block-content--type--cta-band` (lleva `--type--` en medio; **no**
   `block--block-content--cta-band`, que no dispara). Es el theme hook `block`.
2. La plantilla **compone el componente** `ula_cta_band` por inclusión:
   `{{ include('bootstrap_ula_lscm:ula_cta_band', { title: …, text: …, actions: … }) }}`.
3. **Cómo se pasan los campos:** `title` y `text` se pasan como **valor crudo** (`cta.field_cta_title.value`,
   con `cta = content['#block_content']`), **no** como render array. Dos motivos: (a) así **no** pasan por
   `field.html.twig` (que en este sitio, por herencia de subtema, sirve **Bootstrap Italia**), dejando el
   render interno libre de la ruta de plantillas de BI; (b) evita meter un `<div class="field…">` dentro del
   `<h2>` del componente (HTML inválido). El enlace (`actions`) **sí** se pasa como **render array**
   (`content.field_cta_link`): así el formateador Link de Drupal construye el `<a>` con el `href` correcto
   (más fiable que armarlo a mano), y el CSS del componente lo estila como botón.

> **Nota de independencia de BI.** Con este reparto, el título y el texto quedan fuera de la ruta de
> plantillas de BI; el **enlace** todavía pasa por `field.html.twig` de BI (se priorizó la fiabilidad del
> `href`). El render interno será 100 % ajeno a BI cuando se corte el base theme (Fases 6/7) o si se decide
> construir el `<a>` a mano (requiere validar el formato del `uri` del campo Link).

> **Configuración en BD, no en git.** El tipo de bloque `cta_band`, sus campos y cada ejemplar son
> **configuración/contenido**: viven en la base de datos, no en el repositorio (ver `../ARCHITECTURE.md`,
> separación de fuentes de verdad). El repo solo versiona el **código**: el componente `ula_cta_band` y la
> plantilla del bloque. Cualquier operación sobre esta configuración exige **dump previo** de la BD.

---

## 4. ADR — `ula_hero` (cabecera) vs `ula_cta_band` (franja de cierre)

**Contexto.** Al modelar el cierre de la página de About surgió la tentación de reutilizar `ula_hero` (que
ya existía) como «hero de pie de página», añadiéndole una variante «no-cabecera».

**Decisión.** Se modela una **pieza nueva e independiente** (`ula_cta_band` + block type `cta_band`), **no**
una variante del hero.

**Motivos.**

- **Rol distinto.** El hero es la **cabecera** (lo primero que se ve, fondo azul, full-bleed, pegado bajo el
  header); el CTA band es el **cierre** (lo último, tarjeta clara dentro del contenedor, antes del footer).
  Mezclarlos en un solo componente forzaría el concepto de «hero».
- **Estructura distinta.** El CTA band es más simple (título + texto + un botón); no tiene eyebrow,
  resaltado, ni stats.
- **Multiplicidad distinta.** El hero es **uno por página** (emparejado al nodo, ver `hero.md`); el CTA band
  puede aparecer en **cualquier página** e incluso varias veces, y se coloca a discreción del editor.
- **Mecanismo de alimentación distinto.** El hero se alimenta por **Views → UI Patterns** (filtro contextual
  por el nodo); el CTA band por **block_content + plantilla que compone el SDC**.

**Consecuencia / regla de uso.** No se reutiliza `ula_hero` para cierres ni `ula_cta_band` para cabeceras.
Son dos componentes del catálogo con roles separados (ver `../COMPONENTS.md` §1.3 y §1.4).
