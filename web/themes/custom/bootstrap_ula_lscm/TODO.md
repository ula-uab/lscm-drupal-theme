# TO-DOs — Tema Bootstrap ULA LSCM

> Pendientes **transversales** del tema (afectan a todo el proyecto, no a una página concreta).
> Los pendientes específicos de una parte viven junto a su documentación
> (p.ej. los de la home, en `docs/HOME-ARCHITECTURE.md` §8).

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
En `/admin/appearance/ui/components` algunos componentes muestran errores
`Array to string conversion` y volcados de objetos `Attribute`.
Investigar si es un problema de cómo se declaran ciertas props o un comportamiento
de la galería. No afecta al render real en la página, solo a la previsualización.
**Prioridad:** baja.

### 4. Valorar adoptar gestión de configuración (config/sync)
El sitio no usa config/sync: la configuración vive solo en BD y se respalda con dumps
(ver `docs/HOME-ARCHITECTURE.md` §7.1). Valorar si conviene adoptarla, dado que ya se
usa git para el código. Pros: versionar la config, despliegues reproducibles. Contras:
disciplina añadida, fricción conocida con `config:import` y dependencias de módulos.
**Prioridad:** media (decisión de arquitectura, no urgente).

## Resueltos

- **Reparto del CSS monolítico (21 KB) al trocear en componentes SDC.** Resuelto con el
  sistema de tres capas: tokens globales (`ula_tokens`) + base de la landing
  (`ula_landing_base`) + CSS por componente. Ver `docs/HOME-ARCHITECTURE.md` §3.
