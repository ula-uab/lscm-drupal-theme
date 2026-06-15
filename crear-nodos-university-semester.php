<?php

/**
 * Crea los nodos de relación universidad × semestre (ct_university_semester) que
 * alimentan las pastillas de semestre de ula_uni_card, y marca la UAB como
 * "Lead Partner" con su texto de modal.
 *
 * Mapeo (un nodo por pastilla = un término de semestre; opción 2, etiquetas limpias):
 *   UAB (13)      → Semester 1            [First, tid 13]
 *   RTU (14)      → Semester 2/3/4        [Second 14, Third RTU 15, Fourth RTU 20]
 *   TH Wildau(15) → Semester 3/4          [Third Wildau 16, Fourth Wildau 21]
 * + UAB marcada como lead (field_uni_is_lead = true) con su modal.
 *
 * La pastilla "Lead Partner" NO es un nodo de relación: es atributo de la UAB.
 *
 * Los textos de modal son PROVISIONALES (el usuario los afina editando los nodos /
 * la universidad). La opcionalidad de 3º/4º (elección RTU vs TH Wildau) se explica
 * en el texto del modal, no en la etiqueta.
 *
 * IDs verificados en el sitio (pueden variar si se recrean entidades; revisar).
 *
 * Idempotente: no duplica un nodo de relación con la misma (universidad, semestre).
 *
 * Uso:  ddev drush php:script crear-nodos-university-semester.php
 */

use Drupal\node\Entity\Node;

$bundle = 'ct_university_semester';

// nid de universidades y tid de semestres (verificados).
$UAB = 13; $RTU = 14; $WILDAU = 15;
$SEM1 = 13; $SEM2 = 14; $SEM3_RTU = 15; $SEM3_W = 16; $SEM4_RTU = 20; $SEM4_W = 21;

// Cada fila: [uni_nid, sem_tid, pill_label, order, modal_text provisional].
$rows = [
  [$UAB,    $SEM1,     'Semester 1', 0, '<p>At UAB (Barcelona), students complete the first semester: foundations of logistics and supply chain management. <em>(Provisional text — edit in the node.)</em></p>'],
  [$RTU,    $SEM2,     'Semester 2', 0, '<p>At RTU (Riga), students complete the second semester. <em>(Provisional text — edit in the node.)</em></p>'],
  [$RTU,    $SEM3_RTU, 'Semester 3', 1, '<p>Third semester at RTU (Riga), as an optional track. Students may choose RTU or TH Wildau for semesters 3 and 4. <em>(Provisional text — edit in the node.)</em></p>'],
  [$RTU,    $SEM4_RTU, 'Semester 4', 2, '<p>Fourth semester at RTU (Riga): specialisation and thesis, optional track. <em>(Provisional text — edit in the node.)</em></p>'],
  [$WILDAU, $SEM3_W,   'Semester 3', 0, '<p>Third semester at TH Wildau, as an optional track. Students may choose RTU or TH Wildau for semesters 3 and 4. <em>(Provisional text — edit in the node.)</em></p>'],
  [$WILDAU, $SEM4_W,   'Semester 4', 1, '<p>Fourth semester at TH Wildau: specialisation and thesis, optional track. <em>(Provisional text — edit in the node.)</em></p>'],
];

// Idempotencia: pares (uni, sem) ya existentes.
$existing = [];
$ids = \Drupal::entityQuery('node')->accessCheck(FALSE)->condition('type', $bundle)->execute();
foreach (Node::loadMultiple($ids) as $n) {
  $u = $n->get('field_us_university')->target_id ?? '';
  $s = $n->get('field_us_semester')->target_id ?? '';
  $existing["$u-$s"] = $n->id();
}

$created = 0;
foreach ($rows as [$uni, $sem, $label, $order, $modal]) {
  if (isset($existing["$uni-$sem"])) {
    print "• relación uni $uni × sem $sem ya existe (nodo {$existing["$uni-$sem"]}), saltada\n";
    continue;
  }
  // Título interno para identificar el cruce en el admin.
  $uni_node = Node::load($uni);
  $title = ($uni_node ? $uni_node->get('field_uni_abbr')->value : "uni$uni") . " — $label";

  $node = Node::create([
    'type'  => $bundle,
    'title' => $title,
    'status' => 1,
    'field_us_university' => ['target_id' => $uni],
    'field_us_semester'   => ['target_id' => $sem],
    'field_us_pill_label' => $label,
    'field_us_modal_text' => ['value' => $modal, 'format' => 'basic_html'],
    'field_order'         => $order,
  ]);
  $node->save();
  $created++;
  print "  ✓ $title (nodo {$node->id()})\n";
}

// Marcar UAB como lead partner con su modal (provisional).
$uab = Node::load($UAB);
if ($uab) {
  $uab->set('field_uni_is_lead', TRUE);
  $uab->set('field_uni_lead_modal_text', [
    'value'  => '<p>UAB is the lead partner of the consortium, coordinating the joint programme across the three universities. <em>(Provisional text — edit in the UAB node.)</em></p>',
    'format' => 'basic_html',
  ]);
  $uab->save();
  print "\n✓ UAB marcada como Lead Partner (con modal provisional)\n";
}
else {
  print "\n⚠ No se encontró el nodo UAB (nid $UAB) para marcar como lead\n";
}

print "\nHecho. Creados $created nodos de relación.\n";
print "Edita los textos de modal (provisionales) en /admin/content?type=$bundle\n";
print "y el modal de Lead Partner en el nodo UAB.\n";
