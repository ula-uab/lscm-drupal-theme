# Scripts de configuración — tipo de contenido `landing`

Scripts puntuales (drush `php:script`) usados para crear y ordenar los campos
del tipo de contenido `landing`, que alimenta la home (ver
`web/themes/custom/bootstrap_ula_lscm/docs/ARCHITECTURE.md`).

Se conservan como **referencia reproducible**: documentan cómo se creó la
configuración del nodo `landing` (que, al no haber config/sync, no está en git).

| Script | Qué hace | Orden |
|---|---|---|
| `crear-campos-landing.php` | Crea los campos (`field_storage` + `field_config`) del tipo `landing`. | 1 |
| `anadir-campos-formdisplay.php` | Añade esos campos al formulario de edición (form display) con su widget. | 2 |
| `ordenar-campos-landing.php` | Reordena los campos del formulario por secciones (no alfabético). | 3 |

## Uso

```bash
ddev drush php:script scripts/crear-campos-landing.php
ddev drush php:script scripts/anadir-campos-formdisplay.php
ddev drush php:script scripts/ordenar-campos-landing.php
ddev drush cr
```

Los tres son **idempotentes**: si algo ya existe, lo saltan sin error.
