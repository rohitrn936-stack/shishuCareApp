class PrescriptionTemplate {
  final String name;
  final String diagnosis;
  final List<Map<String, String>> medicines;
  final String notes;

  const PrescriptionTemplate({
    required this.name,
    required this.diagnosis,
    required this.medicines,
    required this.notes,
  });
}

const List<PrescriptionTemplate> prescriptionTemplates = [
  PrescriptionTemplate(
    name: "Acute Fever / Pyrexia",
    diagnosis: "Acute Febrile Illness / Viral Fever",
    medicines: [
      {
        "medicine": "Syr. Paracetamol (125mg/5ml)",
        "dosage": "5 ml (15mg/kg)",
        "duration": "3 days",
        "instruction": "Every 6 hours as needed for temp >38.0°C (Max 4 doses/day)",
      },
      {
        "medicine": "Syr. Vitamin C / Immunity",
        "dosage": "2.5 ml",
        "duration": "5 days",
        "instruction": "Once daily after breakfast",
      },
    ],
    notes: "Ensure adequate oral fluids & rest. Tepid sponging if temperature exceeds 38.5°C.",
  ),
  PrescriptionTemplate(
    name: "Acute Gastroenteritis (Diarrhea & ORS)",
    diagnosis: "Acute Gastroenteritis without severe dehydration",
    medicines: [
      {
        "medicine": "ORS Sachet",
        "dosage": "1 sachet in 1L clean water",
        "duration": "3 days",
        "instruction": "Offer 50-100ml after every loose stool in small frequent sips",
      },
      {
        "medicine": "Syr. Zinc Sulfate (20mg/5ml)",
        "dosage": "5 ml (20mg)",
        "duration": "14 days",
        "instruction": "Once daily after food",
      },
      {
        "medicine": "Syr. Probiotic (Bacillus clausii)",
        "dosage": "1 mini-bottle (5ml)",
        "duration": "5 days",
        "instruction": "Twice daily between meals",
      },
    ],
    notes: "Continue normal breastfeeding and age-appropriate soft diet. Avoid sugary beverages.",
  ),
  PrescriptionTemplate(
    name: "Common Cold & URTI",
    diagnosis: "Acute Upper Respiratory Tract Infection (URTI)",
    medicines: [
      {
        "medicine": "Saline Nasal Drops (0.9% NaCl)",
        "dosage": "2 drops in each nostril",
        "duration": "5 days",
        "instruction": "3-4 times daily before feeding and sleep",
      },
      {
        "medicine": "Syr. Levocetirizine (2.5mg/5ml)",
        "dosage": "2.5 ml",
        "duration": "5 days",
        "instruction": "Once daily at bedtime",
      },
    ],
    notes: "Warm fluids, steam inhalation if tolerable. Keep head slightly elevated during sleep.",
  ),
  PrescriptionTemplate(
    name: "Routine Pediatric Supplementation",
    diagnosis: "Routine Growth & Well-Child Nutrition Supplementation",
    medicines: [
      {
        "medicine": "Vitamin D3 Drops (400 IU/ml)",
        "dosage": "1 ml (400 IU)",
        "duration": "30 days",
        "instruction": "Once daily in the morning",
      },
      {
        "medicine": "Syr. Multivitamin with Iron",
        "dosage": "2.5 ml",
        "duration": "30 days",
        "instruction": "Once daily after lunch",
      },
    ],
    notes: "Maintain exclusive breastfeeding until 6 months, followed by nutrient-rich complementary foods.",
  ),
  PrescriptionTemplate(
    name: "Bronchospasm / Wheeze",
    diagnosis: "Reactive Airway Disease / Mild Bronchospasm",
    medicines: [
      {
        "medicine": "Salbutamol Respules (2.5mg/2.5ml)",
        "dosage": "1 respule via nebuliser",
        "duration": "3 days",
        "instruction": "Every 8 hours with normal saline",
      },
      {
        "medicine": "Syr. Montelukast (4mg)",
        "dosage": "1 sachet / 4mg",
        "duration": "14 days",
        "instruction": "Once daily in the evening",
      },
    ],
    notes: "Avoid exposure to dust, cold air, and domestic smoke. Seek immediate care if chest indrawing occurs.",
  ),
];
