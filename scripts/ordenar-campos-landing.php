<?php
/**
 * Reordena los campos del FORM DISPLAY del tipo "landing" por secciones,
 * siguiendo el mismo orden que la landing (no alfabético).
 *
 * No activa módulos ni cambia campos: solo ajusta el 'weight' de cada campo
 * en el formulario de edición. Seguro y reversible.
 */

$form_display = \Drupal::entityTypeManager()
  ->getStorage('entity_form_display')
  ->load('node.landing.default');

if (!$form_display) {
  print "ERROR: no existe el form display node.landing.default\n";
  return;
}

// Orden lógico por secciones (espejo de la landing).
$order = [
  // Marca / logo
  'field_logo_url', 'field_brand_top', 'field_brand_sub',
  // Hero
  'field_hero_badge_text', 'field_hero_title', 'field_hero_title_highlight',
  'field_hero_description', 'field_hero_cta1_text', 'field_hero_cta1_url',
  'field_hero_cta2_text', 'field_hero_cta2_url',
  // About
  'field_about_tag', 'field_about_title', 'field_about_desc',
  'field_about_cta_text', 'field_about_cta_url',
  // Journey
  'field_journey_tag', 'field_journey_title', 'field_journey_desc',
  'field_journey_cta_text', 'field_journey_cta_url',
  // Universities
  'field_uni_tag', 'field_uni_title', 'field_uni_desc',
  'field_uni_cta_text', 'field_uni_cta_url',
  // Specializations
  'field_spec_tag', 'field_spec_title', 'field_spec_desc',
  'field_spec_cta_text', 'field_spec_cta_url',
  // Admission
  'field_adm_tag', 'field_adm_title', 'field_adm_desc',
  'field_adm_cta_text', 'field_adm_cta_url',
  // Get in touch
  'field_contact_tag', 'field_contact_title', 'field_contact_desc',
  'field_contact_email', 'field_contact_faq_text', 'field_contact_faq_url',
];

$weight = 0;
$updated = 0;
foreach ($order as $field_name) {
  $component = $form_display->getComponent($field_name);
  if ($component !== NULL) {
    $component['weight'] = $weight;
    $form_display->setComponent($field_name, $component);
    $updated++;
  } else {
    print "  ⚠ no está en el form display: $field_name\n";
  }
  $weight++;
}

$form_display->save();
print "\nRESUMEN: $updated campos reordenados por secciones.\n";
print "Orden: marca → hero → about → journey → universities → specializations → admission → contact\n";
print "Limpia caché: ddev drush cr\n";
