<?php
/**
 * Añade todos los campos field_* del tipo "landing" al FORM DISPLAY
 * (el formulario de edición), para que el editor los vea y rellene.
 *
 * El script anterior creó los campos (storage + config), pero NO los registró
 * en el form display, por eso no aparecían al editar el nodo. Esto lo corrige.
 *
 * Idempotente: si un campo ya está en el form display, lo deja como está.
 */

$entity_type = 'node';
$bundle = 'landing';

// Cargar el form display 'default' del tipo landing.
$form_display = \Drupal::entityTypeManager()
  ->getStorage('entity_form_display')
  ->load("$entity_type.$bundle.default");

if (!$form_display) {
  // Si no existe, crearlo.
  $form_display = \Drupal::entityTypeManager()
    ->getStorage('entity_form_display')
    ->create([
      'targetEntityType' => $entity_type,
      'bundle' => $bundle,
      'mode' => 'default',
      'status' => TRUE,
    ]);
}

// Obtener todos los campos field_* del bundle.
$defs = \Drupal::service('entity_field.manager')->getFieldDefinitions($entity_type, $bundle);

$weight = 0;
$added = 0; $existing = 0;
foreach ($defs as $name => $def) {
  if (strpos($name, 'field_') !== 0) {
    continue;
  }
  $type = $def->getType();
  // Elegir widget según el tipo de campo.
  $widget = ($type === 'string_long') ? 'string_textarea' : 'string_textfield';

  $component = $form_display->getComponent($name);
  if ($component === NULL) {
    $form_display->setComponent($name, [
      'type' => $widget,
      'weight' => $weight,
      'settings' => ($type === 'string_long')
        ? ['rows' => 3]
        : ['size' => 60],
    ]);
    print "  ✓ añadido al formulario: $name ($widget)\n";
    $added++;
  } else {
    print "  · ya estaba: $name\n";
    $existing++;
  }
  $weight++;
}

$form_display->save();
print "\nRESUMEN form display: $added añadidos, $existing ya estaban.\n";
print "Limpia caché después: ddev drush cr\n";
