# Instalation

1. Install ddev and drupal using this tutorial:
https://drupalize.me/tutorial/install-drupal-locally-ddev

2. Install `bootstrap_italia` using this tutorial
https://github.com/italia/design-drupal-theme

# Plugins

## Basic Plugins
These plugins are mandatory because provides basic/essential functionality
- Components

`composer require 'drupal/components:^3.2'`

- Field Group

`composer require 'drupal/field_group:^4.0'`

- Entity Usage

`composer require 'drupal/entity_usage:^2.0@beta'`

- Entity Reference Display

`composer require 'drupal/entity_reference_display:^2.0'`

- Focal Point

`composer require 'drupal/focal_point:^2.1'`

- Twig Tweak

`composer require 'drupal/twig_tweak:^3.4'`

- Paragraphs

`composer require 'drupal/paragraphs:^1.20'`

## Italia Theme

- Bootstrap Italia

`composer require 'drupal/views_field_view:^1.0@beta'`

- Imce

`composer require 'drupal/imce:^3.1'`

- Color Field

`composer require 'drupal/color_field:^3.0'`

> **Recall** once theme is installed, you have to set "hidden: false" in `italiagov.info.yml`,
> and include `bootstrap.js` and `popper.js` to "src/js/custom" to make **modals** work.

## To create Master Thesis

- Views Field View

`composer require 'drupal/views_field_view:^1.0@beta'`

Tutorial: https://ostraining.com/blog/drupal/views-field-view/

## To style the content types

- UI Patterns

`composer require 'drupal/ui_patterns:^2.0'`

## DO NOT INSTALL

- UI Patterns Paragraphs

`composer require 'drupal/ui_patterns_paragraphs:^1.0@alpha'`

- UI Suite

- UI Suite Bootstrap

This module is useful only to steal components from.

`composer require 'drupal/ui_suite_bootstrap:^5.2'`

## Patches

Eventually, this error will appear

> NOTICE: PHP message: Uncaught PHP Exception TypeError: "Drupal\Core\Asset\JsCollectionOptimizerLazy::optimizeGroup(): Return value must be of type string, null returned" at /var/www/html/web/core/lib/Drupal/Core/Asset/JsCollectionOptimizerLazy.php line 177

It is patched by replacing the line with:

```php
return $this->optimizer->clean($data) ?? $data;
```

https://www.drupal.org/docs/extending-drupal/themes/contributed-themes/bootstrap/installation-bootstrap-theme/creating-a-custom-bootstrap-sub-theme


