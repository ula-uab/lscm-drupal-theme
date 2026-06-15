# TO-DOs — Tema Bootstrap ULA LSCM

> Pendientes **transversales** del tema (afectan a todo el proyecto, no a una página concreta).
> Los pendientes específicos de una parte viven junto a su documentación
> (p.ej. los de la home, en `docs/elements/home/HOME-ARCHITECTURE.md` §5).

## Abiertos

### 1. Avisos `Deprecated` de Gutenberg en la salida de drush
Cada comando `ddev drush ...` imprime avisos de obsolescencia del módulo `gutenberg`
(`_gutenberg_is_gutenberg_enabled()` y otros), que ensucian la salida.
**Opciones a explorar:** actualizar el módulo `gutenberg` a una versión compatible con
la versión de PHP del entorno, o ajustar `error_reporting` para ocultar `E_DEPRECATED`.
**Prioridad:** baja (es ruido, no afecta a funcionalidad).

### 2. Actualización de seguridad de Drupal
Considerar aplicar las actualizaciones de seguridad de Drupal core/contrib cuando proceda.
**Antes de hacerlo:** commit + push del estado actual y dump de BD, como red de seguridad.
**Prioridad:** media (revisar periódicamente).

### 3. Errores de renderizado en la galería UI Patterns
En `/admin/appearance/ui/components` la previsualización de algunos componentes muestra
errores `Array to string conversion` y volcados de objetos `Drupal\Core\Template\Attribute`.
**No es un problema de los SDC propios (`ula_*`)**: parece un comportamiento general de la
galería al previsualizar componentes que reciben/emiten objetos `Attribute`. No afecta al
render real en la página, solo a la previsualización en la galería.
**Prioridad:** baja.

### 4. Valorar adoptar gestión de configuración (config/sync)
El sitio no usa config/sync: la configuración vive solo en BD y se respalda con dumps
(ver `docs/elements/home/HOME-ARCHITECTURE.md` §7.1). Valorar si conviene adoptarla, dado
que ya se usa git para el código. Pros: versionar la config, despliegues reproducibles.
Contras: disciplina añadida, fricción conocida con `config:import` y dependencias de módulos.
Es la vía para cerrar la fragilidad estructural "código en git / config solo en BD".
**Prioridad:** media (decisión de arquitectura, no urgente).

### 5. Componentes residuales sin uso en `components/`
Quedan tres componentes que no forman parte del design system `ula_*` ni se usan en la
home: `avatar_fixed`, `modal_fixed`, `timeline_fixed`. Revisar si son restos de pruebas y,
si se confirma que no se usan en ninguna parte, eliminarlos para no dejar deuda.
**Prioridad:** baja (limpieza).

### 6. Eliminar la vista heredada `page_home`
Vista de Drupal heredada que servía la home antigua, hoy sustituida por la home como nodo +
plantilla Twig (ADR-001). Era la **Fase 0** del plan de colecciones editables (ya completado y
archivado); se reconvirtió en este TO-DO transversal. **Condición:** ejecutarla cuando se haya
**avanzado en la independencia de Bootstrap Italia**, ya que es una limpieza de configuración
heredada que encaja en ese trabajo de desvinculación. **Antes de tocarla:** dump de BD (la vista
es configuración, vive solo en BD) y verificar qué se pierde. Análisis original en
`docs/elements/home/HOME-ARCHITECTURE.md` §5.4.
**Prioridad:** baja (condicionada al avance de independencia de BI).

## Resueltos

- **Reparto del CSS monolítico (21 KB) al trocear en componentes SDC.** Resuelto con el
  sistema de tres capas: tokens globales (`ula_tokens`) + base de la landing
  (`ula_landing_base`) + CSS por componente. Ver `docs/elements/home/HOME-ARCHITECTURE.md` §3.
