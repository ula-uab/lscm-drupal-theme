<?php
/**
 * Crea los campos del tipo de contenido "landing" para mapear a las props
 * del componente lscm-master-page. Idempotente: si un campo ya existe, lo salta.
 *
 * Tipos:
 *   - string       : texto corto (tags, títulos, textos de botón, urls, email...)
 *   - string_long  : texto largo (descripciones)
 *
 * Nomenclatura: field_<prop> (espejo de la prop del componente).
 */

use Drupal\field\Entity\FieldStorageConfig;
use Drupal\field\Entity\FieldConfig;

$bundle = 'landing';
$entity_type = 'node';

// prop => [tipo_campo, etiqueta]
$fields = [
  // Marca / logo
  'logo_url'            => ['string', 'Logo URL'],
  'brand_top'           => ['string', 'Brand top'],
  'brand_sub'           => ['string', 'Brand sub'],
  // Hero
  'hero_badge_text'     => ['string', 'Hero badge'],
  // hero_title YA existe (no se recrea)
  'hero_title_highlight'=> ['string', 'Hero title highlight'],
  'hero_description'    => ['string_long', 'Hero description'],
  'hero_cta1_text'      => ['string', 'Hero CTA1 text'],
  'hero_cta1_url'       => ['string', 'Hero CTA1 URL'],
  'hero_cta2_text'      => ['string', 'Hero CTA2 text'],
  'hero_cta2_url'       => ['string', 'Hero CTA2 URL'],
  // About
  'about_tag'           => ['string', 'About tag'],
  'about_title'         => ['string', 'About title'],
  'about_desc'          => ['string_long', 'About description'],
  'about_cta_text'      => ['string', 'About CTA text'],
  'about_cta_url'       => ['string', 'About CTA URL'],
  // Journey
  'journey_tag'         => ['string', 'Journey tag'],
  'journey_title'       => ['string', 'Journey title'],
  'journey_desc'        => ['string_long', 'Journey description'],
  'journey_cta_text'    => ['string', 'Journey CTA text'],
  'journey_cta_url'     => ['string', 'Journey CTA URL'],
  // Universities
  'uni_tag'             => ['string', 'Uni tag'],
  'uni_title'           => ['string', 'Uni title'],
  'uni_desc'            => ['string_long', 'Uni description'],
  'uni_cta_text'        => ['string', 'Uni CTA text'],
  'uni_cta_url'         => ['string', 'Uni CTA URL'],
  // Specializations
  'spec_tag'            => ['string', 'Spec tag'],
  'spec_title'          => ['string', 'Spec title'],
  'spec_desc'           => ['string_long', 'Spec description'],
  'spec_cta_text'       => ['string', 'Spec CTA text'],
  'spec_cta_url'        => ['string', 'Spec CTA URL'],
  // Admission
  'adm_tag'             => ['string', 'Adm tag'],
  'adm_title'           => ['string', 'Adm title'],
  'adm_desc'            => ['string_long', 'Adm description'],
  'adm_cta_text'        => ['string', 'Adm CTA text'],
  'adm_cta_url'         => ['string', 'Adm CTA URL'],
  // Get in touch
  'contact_tag'         => ['string', 'Contact tag'],
  'contact_title'       => ['string', 'Contact title'],
  'contact_desc'        => ['string_long', 'Contact description'],
  'contact_email'       => ['string', 'Contact email'],
  'contact_faq_text'    => ['string', 'Contact FAQ text'],
  'contact_faq_url'     => ['string', 'Contact FAQ URL'],
];

$created = 0; $skipped = 0;
foreach ($fields as $prop => $def) {
  [$type, $label] = $def;
  $field_name = 'field_' . $prop;
  // Machine name de campo: máx 32 caracteres. Verificar.
  if (strlen($field_name) > 32) {
    print "  ⚠ SALTADO (nombre >32 car): $field_name\n";
    continue;
  }
  // 1. Field storage (si no existe)
  if (!FieldStorageConfig::loadByName($entity_type, $field_name)) {
    FieldStorageConfig::create([
      'field_name'  => $field_name,
      'entity_type' => $entity_type,
      'type'        => $type,
      'cardinality' => 1,
    ])->save();
  }
  // 2. Field config en el bundle (si no existe)
  if (!FieldConfig::loadByName($entity_type, $bundle, $field_name)) {
    FieldConfig::create([
      'field_name'  => $field_name,
      'entity_type' => $entity_type,
      'bundle'      => $bundle,
      'label'       => $label,
    ])->save();
    print "  ✓ creado: $field_name ($type)\n";
    $created++;
  } else {
    print "  · ya existía: $field_name\n";
    $skipped++;
  }
}
print "\nRESUMEN: $created creados, $skipped ya existían.\n";

// Verificar longitudes de nombre por si alguno excede 32
print "\n=== Verificación de longitud de machine names ===\n";
foreach (array_keys($fields) as $prop) {
  $fn = 'field_'.$prop;
  if (strlen($fn) > 32) print "  ⚠ $fn = ".strlen($fn)." caracteres (EXCEDE 32)\n";
}
print "(sin avisos arriba = todos los nombres son válidos)\n";
