# Entidad — bloque de contenido `inline_lb_pills` (pastillas / etiquetas)

> **Tipo de documento:** diseño de **entidades propias** del tema (no heredadas). Ver `entities/`.
>
> **Creada en:** v1.8.0 (hito «librería de artefactos inline block»). · **Naturaleza:** **tipo de bloque de
> contenido** (`block_content`) colocado como **inline block de Layout Builder**. · **Mecanismo:** patrón B
> (campos → composición de SDC). Estrena los SDC propios `ula_pill` y `ula_pill_group`. Ver
> `../elements/layout/INLINE-BLOCKS-CATALOG.md` §4.4 y `../COMPONENTS.md` (§1, `ula_pill` / `ula_pill_group`).

---

## 1. Qué es y por qué existe

`inline_lb_pills` modela una **colección de pastillas/etiquetas** del body. Cubre «tools» (§2: SAP, AnyLogic,
Python, R, Arena Simulation) y, en variante, «role-grid» (§3: roles profesionales). Decisión transversal
**D2**: en vez de CSS suelto, se crean **SDC reutilizables** `ula_pill` (la pastilla) y `ula_pill_group` (el
contenedor con prop `variant`), con el estilo de pastilla tomado de los **chips de `ula_faculty_detail`**.

---

## 2. Campos (tipo de bloque `inline_lb_pills`)

| Campo | Tipo | Card. | Para qué |
|---|---|---|---|
| **Block description** (base) | — | 1 | Nombre administrativo. No se muestra. |
| `field_inline_lb_pl_labels` | string | **multivalor** | Una etiqueta por delta → prop `label` de `ula_pill`. |
| `field_inline_lb_pl_variant` | list_string (`pill`/`tag_card`) | 1 | Disposición/estilo → prop `variant` de `ula_pill_group`. Por defecto `pill`. |

> **Nota de implementación (BD):** `field_inline_lb_pl_variant` (List text) se creó **por la UI**, no por
> script (ver nota transversal en `../ARCHITECTURE.md` sobre `list_string` por script).

---

## 3. Cómo se consume (lógica en el tema)

Plantilla `templates/content/block--block-content--type--inline-lb-pills.html.twig`, con el **armazón
estándar de bloque**. Recorre `field_inline_lb_pl_labels`, compone un `ula_pill` por etiqueta (array) y lo
pasa al **slot `pills`** de `ula_pill_group` junto con `variant` (mismo patrón que el statgrid: array → slot
del contenedor).

- **Anti-BI:** las etiquetas se pasan como valor plano (`.value`) a la prop del SDC.
- **CSS:** `ula_pill` y `ula_pill_group` son SDC y **autoadjuntan** su CSS; este artefacto **no** necesita
  librería propia ni `attach_library`.
- **Estilo:** `ula_pill` = chip (fondo azul tenue, texto `--eu-blue`, borde, radio 100px), tomado de
  `ula_faculty_detail`. La variante `tag_card` del grupo reestila cada pastilla como tarjeta-etiqueta (filete
  dorado a la izquierda) en rejilla.

> **Configuración en BD, no en git.** Tipo de bloque, campos y ejemplares en BD; el repo versiona la
> plantilla y los dos SDC. Dump previo obligatorio.

## 4. Pendiente conocido

> **[PENDIENTE] No se aprecia diferencia entre `pill` y `tag_card`.** A verificar (la clase `--tag-card` no
> llega/no se aplica, el CSS de `ula_pill_group` no carga o no hace override, o no se cambió la variante al
> probar).

## 5. Relación con otros

- **`ula_pill` / `ula_pill_group`** (`../COMPONENTS.md`): SDC propios estrenados aquí; reutilizables en otras
  páginas y por la pieza de pastillas de `inline_lb_stack`.
