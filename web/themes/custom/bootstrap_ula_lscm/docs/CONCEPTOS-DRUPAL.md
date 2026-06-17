# Conceptos clave de Drupal, aplicados al tema `bootstrap_ula_lscm`

> **Propósito.** Este documento es un **manual de referencia** de los conceptos de Drupal que aparecen
> al desarrollar y mantener este tema, **ilustrados y aplicados a nuestro caso concreto**. No pretende
> ser un manual general de Drupal, sino explicar *qué es cada cosa* y *cómo se usa en
> `bootstrap_ula_lscm`*, para que cualquier persona (desarrolladora o editora) que retome el proyecto
> entienda los mecanismos sobre los que está construido.
>
> **Audiencia.** Desarrolladores y editores del sitio del máster, presentes y futuros.
>
> **Cómo crece este documento.** Se amplía a medida que el desarrollo encuentra conceptos nuevos. Cada
> entrada sigue el mismo esquema: *qué es* → *cómo funciona* → *en nuestro tema*.

---

## Índice

1. [Tema, tema base y subtema](#1-tema-tema-base-y-subtema)
2. [Librerías (libraries): los assets CSS/JS](#2-librerías-libraries-los-assets-cssjs)
3. [Regiones](#3-regiones)
4. [Sugerencias de plantilla (theme suggestions)](#4-sugerencias-de-plantilla-theme-suggestions)
5. [SDC — Single Directory Components](#5-sdc--single-directory-components)
6. [Vistas (Views) y UI Patterns](#6-vistas-views-y-ui-patterns)

> *(El índice se irá completando conforme se añadan entradas.)*

---

## 1. Tema, tema base y subtema

**Qué es.** Un **tema** (theme) es el conjunto de plantillas, estilos (CSS), scripts (JS) y configuración
que define **cómo se ve** un sitio Drupal. Un tema puede declararse **hijo** de otro (su **tema base**,
`base theme`): hereda del padre sus plantillas, librerías y regiones, y puede sobrescribir o añadir lo
suyo. A esa relación se le llama **subtema**.

**Cómo funciona.** Cuando un tema es hijo de otro, Drupal combina ambos: si el hijo no aporta una pieza
(p. ej. una plantilla), usa la del padre; si la aporta, la del hijo **gana**. La herencia abarca
plantillas, librerías declaradas y el esquema de regiones.

**En nuestro tema.** `bootstrap_ula_lscm` es **hijo de `bootstrap_italia`** (declarado como
`base theme: bootstrap_italia` en el `.info.yml`). Esto significa que, de partida, hereda de Bootstrap
Italia (BI) gran parte de su maquinaria: su `page.html.twig`, su biblioteca de componentes, su esquema
de regiones y sus librerías CSS. **El objetivo de fondo del proyecto es eliminar esa dependencia** (ver
el plan maestro de independencia de BI, `plans/paginas-contenido/plan-sistema-paginas-contenido.md`):
ir sustituyendo lo heredado por piezas propias hasta poder declarar el tema autónomo.

---

## 2. Librerías (libraries): los assets CSS/JS

**Qué es.** Una **librería** es un **paquete de assets** —ficheros CSS y/o JavaScript— que el tema
declara y que Drupal carga en la página cuando hacen falta. Es el mecanismo estándar de Drupal para
decir "esta página necesita estos CSS y estos JS". Las librerías son las que **"visten"** el HTML: sin
el CSS de la librería correspondiente, el markup se muestra sin estilos.

**Cómo funciona.** Las librerías se declaran en un fichero `<tema>.libraries.yml` (el **catálogo**:
"tengo estas librerías disponibles, y cada una incluye estos ficheros CSS/JS"). Una vez declaradas, se
**activan** de dos formas:

- **Globalmente** — en el `.info.yml`, bajo la clave `libraries:`. Se cargan en **todas** las páginas
  del tema.
- **Bajo demanda** — un componente SDC, una plantilla o un módulo solicita una librería concreta solo
  cuando se usa (p. ej. con `{{ attach_library('tema/mi_libreria') }}` en Twig, o desde el
  `.component.yml` de un SDC). Así no se carga en páginas donde no hace falta.

> **Ilustración real (las dos demos de Block layout).** Al comparar la página *Demonstrate block
> regions* de `bootstrap_ula_lscm` (que se ve "vestida", con la estructura visual reconocible) con la
> de `bootstrap_italia` (que se ve como una lista plana sin estilos), la diferencia **no** estaba en
> las regiones (idénticas en ambos), sino en las **librerías**: nuestro tema carga globalmente el CSS
> que da forma; el tema padre, por sí solo, no carga ninguna librería global y por eso se ve desnudo.

**En nuestro tema.** El catálogo (`bootstrap_ula_lscm.libraries.yml`) declara varias librerías:
`vanilla`, `custom`, `cdn`, `hot`, `ddev`, `ula_tokens`, `ula_landing_base`. De ellas, el `.info.yml`
**carga globalmente** (las no comentadas):

| Librería cargada globalmente | Origen | Papel |
|---|---|---|
| `bootstrap_ula_lscm/libraries-ui` | Propia | Assets de interfaz del tema |
| `bootstrap_ula_lscm/custom` | Propia | Estilos propios personalizados |
| `bootstrap_ula_lscm/ula_tokens` | Propia | **Tokens de diseño `ula_*`** (colores, tipografías): la base visual del design system propio. Cargada siempre, reutilizable en todo el tema |
| `bootstrap_italia/base` | **Heredada de BI** | **CSS estructural de Bootstrap Italia**: la maquetación (grid, header, componentes) que visten las páginas heredadas |
| `bootstrap_italia/enable-all-tooltips` | **Heredada de BI** | JS de tooltips de BI |
| `bootstrap_italia/load-fonts` | **Heredada de BI** | Carga de las fuentes de BI |

Las tres `bootstrap_italia/*` son la **dependencia de BI a nivel de assets**. Son candidatas a
eliminación en la fase final de la independencia (Fase 6 del plan), pero **solo cuando nada dependa de
ellas**: hoy, `bootstrap_italia/base` es lo que da estilo a los componentes de BI que usan las páginas
heredadas; retirarla ahora dejaría esas páginas sin estilos.

> Las librerías comentadas en el `.info.yml` (`vanilla`, `cdn`, `hot`, `ddev`) están **declaradas pero
> no cargadas**. Su propósito y vigencia conviene aclararlos durante el inventario (Fase 0).

---

## 3. Regiones

**Qué es.** Una **región** es un "hueco" con nombre en el layout de una página donde se pueden colocar
**bloques**. Son los contenedores estructurales del tema (p. ej. "cabecera", "contenido principal",
"pie", "barra lateral").

**Cómo funciona.** Las regiones se **declaran** en el `.info.yml` del tema (sección `regions:`). Esa
declaración define *qué* regiones existen, pero **no las dibuja**: dónde y cómo se disponen visualmente
lo decide la plantilla de página (`page.html.twig`), que **imprime** cada región con `{{ page.<nombre>
}}`. La asignación de qué bloque va en qué región se gestiona desde el **Block layout** del admin
(`/admin/structure/block`), que es **por tema** (cada tema tiene su propia disposición de bloques).

Conviene distinguir tres cosas independientes:
- Regiones **declaradas** (en el `.info.yml`): las que existen.
- Regiones **impresas** (en la plantilla): las que esa plantilla concreta pinta. Una plantilla puede
  ignorar regiones declaradas (no imprimirlas), y eso no las elimina del tema.
- Regiones **usadas** (con bloques colocados): las que realmente tienen contenido.

**En nuestro tema.** El `.info.yml` **redeclara explícitamente** el esquema completo de **56 regiones**
de Bootstrap Italia (`page_top`, `header_slim_*`, `brand`, `header_nav`, `before_content_*`, `content`,
`sidebar_*`, `after_content_*`, `footer_*`, las filas de home `home_*_row_*`, `page_bottom`…). Muchas
de ellas son **herencia muerta**: existen pero ninguna página viva coloca bloques en ellas. La región
imprescindible para que una página muestre su contenido es **`content`** (donde va el
`system_main_block`), que es estándar de Drupal, no exclusiva de BI. Adelgazar las regiones no usadas es
una tarea de la fase final de la independencia (Fase 6 del plan).

---

## 4. Sugerencias de plantilla (theme suggestions)

**Qué es.** Un mecanismo por el que Drupal, para renderizar algo (una página, un bloque, un nodo…),
considera **varios nombres de plantilla posibles**, de más específico a más general, y usa **el primero
que exista** como fichero en el tema.

**Cómo funciona.** Para las **páginas**, Drupal genera sugerencias en este orden (de mayor a menor
prioridad), y aplica la primera cuyo fichero exista:

1. `page--front.html.twig` — si es la portada.
2. `page--node--[nid].html.twig` → `page--node--[tipo].html.twig` → `page--node.html.twig` — páginas de
   nodo, de la más específica a la más general.
3. `page--[ruta-por-partes].html.twig` — basadas en la **ruta interna / path**. Por ejemplo, para
   `/about` se genera `page--about.html.twig`.
4. `page.html.twig` — la **genérica**, que se aplica si ninguna más específica existe como fichero.

Los módulos y temas pueden añadir o alterar sugerencias mediante hooks
(`hook_theme_suggestions_HOOK_alter`). La forma fiable de ver las sugerencias reales de una página es
activar el **Twig debugging**, que las vuelca como comentarios en el HTML (`THEME HOOK`, `FILE NAME
SUGGESTIONS`, con `✅` marcando la que se usa y `▪️` las disponibles no usadas).

**En nuestro tema.** Esto es la base de la estrategia del marco de páginas (ver
`elements/layout/LAYOUT-ARCHITECTURE.md`, ADR-LAYOUT-001):
- La **home** usa `page--front.html.twig` (sugerencia 1), su plantilla propia.
- La **página About** se captura con `page--about.html.twig` (sugerencia 3, basada en el path `/about`)
  —verificado con Twig debug—, lo que permite darle un marco propio **sin** crear un `page.html.twig`
  genérico que afectaría a todas las páginas.
- Las **demás páginas no-home** caen hoy en el `page.html.twig` genérico, que el tema **hereda de
  Bootstrap Italia** (el tema no tiene `page.html.twig` propio… todavía: crear uno propio es la Fase 2
  del plan).

---

## 5. SDC — Single Directory Components

**Qué es.** Un **SDC** (Single Directory Component, "componente de directorio único") es la forma nativa
de Drupal moderno (core 10.3+/11) de definir un **componente de interfaz reutilizable**: una carpeta que
contiene, junta, toda la definición del componente —su esquema de propiedades, su plantilla y sus
estilos—.

**Cómo funciona.** Cada componente vive en su propia carpeta dentro de `components/` y contiene como
mínimo:
- `<nombre>.component.yml` — el **esquema**: nombre, descripción, y las **props** (propiedades de
  entrada) y **slots** (huecos de contenido) que acepta.
- `<nombre>.twig` — la **plantilla** que pinta el componente con esas props/slots.
- `<nombre>.css` (opcional) — sus **estilos**, que SDC **autocarga** por convención cuando el componente
  se usa (no hace falta declararlos como librería aparte).

Se referencian con la sintaxis `tema:componente` (p. ej. `bootstrap_ula_lscm:ula_uni_card`) y se
incluyen desde Twig con `{{ include('tema:componente', { prop: valor }) }}`.

**En nuestro tema.** La carpeta `components/` contiene del orden de **70 componentes**, de tres orígenes:
- **Propios del design system (`ula_*`)** — p. ej. `ula_uni_card`, `ula_hero_stat`, `ula_feature_item`…
  Son los componentes de contenido que diseñamos nosotros.
- **Propios del marco (`lscm_*`)** — `lscm_page_header`, `lscm_page_footer` (marco de páginas, Fase 1) y
  `lscm-master-page`, `lscm-master-static` (marco de la home).
- **Heredados de Bootstrap Italia (~58)** — toda la biblioteca de componentes de BI: `card`, `grid_row`,
  `accordion`, `modal2`, `table`, `carousel`, `hero2`, etc. (incluidas variantes con sufijo `2` y
  numeradas). Las páginas heredadas los usan vía Views + UI Patterns.

> **Convención de nombres del proyecto.** En adelante, el prefijo **`ula_*` se reserva para desarrollos
> nuevos**. Los nombres `lscm_*` indican piezas **heredadas** —salvo `lscm_page_*`, que son propias y
> nacieron antes de fijar esta convención—. Cuando se adopta un componente heredado y se hace propio, se
> le cambia el nombre con prefijo propio y pasa al inventario de elementos propios.

---

## 6. Vistas (Views) y UI Patterns

**Qué es.**
- **Views** es el constructor de consultas de Drupal: define páginas o bloques que **listan contenido**
  (nodos, bloques de contenido, etc.) según filtros, orden y formato. Es la herramienta estándar para
  mostrar contenido estructurado.
- **UI Patterns** (módulo contribuido) conecta Views (y otros) con los **componentes SDC**: permite que
  una vista presente su contenido **renderizándolo con un componente**, mapeando los campos del
  contenido a las props/slots del componente.

**Cómo funciona.** En una vista, el "formato de fila" puede ser **UI Patterns**: en lugar de pintar los
campos sueltos, la vista ensambla un componente SDC y le pasa los campos como props/slots. Esa
configuración (qué componente, qué mapeo) se guarda en la **definición de la vista**, que vive en la
**base de datos** (no en el código/git). UI Patterns 2.x se apoya en SDC nativo, por lo que puede
consumir cualquier componente SDC del tema —tanto los de BI como los `ula_*` propios—.

**En nuestro tema.** Es el patrón estructural de **las páginas heredadas**: cada página (About,
Contents, Admission, Eligibility…) es una **vista** que toma un **bloque de contenido** `lscm_*` y lo
presenta con UI Patterns apuntando a **componentes de Bootstrap Italia** (`grid_row`, `card`, `modal2`,
`table`…). La versión instalada es **UI Patterns 2.0.15** con el submódulo `ui_patterns_views`. El plan
de independencia (Fase 4) mantiene el mecanismo de Views pero **redirige la presentación** de los
componentes de BI a componentes propios `ula_*`. Ver el análisis del piloto en
`analysis/about-page-heredada.md`.
