import 'package:flutter/material.dart';

class ScreeningFieldSpec {
  final String key;
  final String label;
  final String? hint;
  final String? unit;
  final TextInputType keyboardType;
  final List<String>? options;

  const ScreeningFieldSpec({
    required this.key,
    required this.label,
    this.hint,
    this.unit,
    this.keyboardType = TextInputType.text,
    this.options,
  });
}

List<ScreeningFieldSpec> screeningFieldSpecs({
  required String section,
  required String title,
}) {
  final t = title.toLowerCase();
  final s = section.toLowerCase();

  // Some measurements appear under physical examination in the source checklist.
  if (t.contains('spo2')) {
    return const [
      ScreeningFieldSpec(
        key: 'value',
        label: 'SpO₂',
        unit: '%',
        keyboardType: TextInputType.number,
      ),
    ];
  }

  if (t.contains('jaundice')) {
    return const [
      ScreeningFieldSpec(
        key: 'value',
        label: 'Jaundice level / finding',
        hint: 'Enter level or observation',
      ),
    ];
  }

  if (t.contains('depression') || t.contains('suicide-risk') ||
      t.contains('anxiety') || t.contains('substance use') ||
      t.contains('heeadsss') || t.contains('m-chat')) {
    return const [
      ScreeningFieldSpec(
        key: 'result',
        label: 'Screening result',
        hint: 'Record score, result or overall finding',
      ),
      ScreeningFieldSpec(
        key: 'tool',
        label: 'Tool / instrument',
        hint: 'If applicable, e.g. named screening tool',
      ),
    ];
  }

  if (s == 'measurements & growth') {
    if (t.contains('weight') || t.contains('birth wt')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'Weight',
          hint: 'Enter measured weight',
          unit: 'kg',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t == 'length' || t.contains('length')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'Length',
          hint: 'Enter measured length',
          unit: 'cm',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t == 'height' || t.contains('standing height') || t.contains('height')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'Height',
          hint: 'Enter measured height',
          unit: 'cm',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t.contains('head circumference')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'Head circumference',
          hint: 'Enter measurement',
          unit: 'cm',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t.contains('gestational age')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'Gestational age',
          hint: 'Enter gestational age',
          unit: 'weeks',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t.contains('bmi')) {
      return const [
        ScreeningFieldSpec(
          key: 'value',
          label: 'BMI',
          hint: 'Enter or calculate BMI',
          unit: 'kg/m²',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        ScreeningFieldSpec(
          key: 'percentile',
          label: 'BMI percentile',
          hint: 'If available',
          unit: '%',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t.contains('bp')) {
      return const [
        ScreeningFieldSpec(
          key: 'systolic',
          label: 'Systolic BP',
          unit: 'mmHg',
          keyboardType: TextInputType.number,
        ),
        ScreeningFieldSpec(
          key: 'diastolic',
          label: 'Diastolic BP',
          unit: 'mmHg',
          keyboardType: TextInputType.number,
        ),
      ];
    }
    if (t.contains('tanner')) {
      return const [
        ScreeningFieldSpec(
          key: 'stage',
          label: 'Tanner stage',
          options: ['I', 'II', 'III', 'IV', 'V'],
        ),
      ];
    }
    return const [
      ScreeningFieldSpec(
        key: 'value',
        label: 'Measured / recorded value',
        hint: 'Enter the value from the assessment',
      ),
    ];
  }

  if (s == 'laboratory & screening') {
    if (t.contains('haemoglobin')) {
      return const [
        ScreeningFieldSpec(
          key: 'result',
          label: 'Haemoglobin result',
          unit: 'g/dL',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
      ];
    }
    if (t.contains('bilirubin')) {
      return const [
        ScreeningFieldSpec(
          key: 'result',
          label: 'Bilirubin result',
          unit: 'mg/dL',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
        ),
        ScreeningFieldSpec(
          key: 'method',
          label: 'Method / context',
          hint: 'e.g. TcB / serum',
        ),
      ];
    }
    if (t.contains('lipid') || t.contains('cholesterol')) {
      return const [
        ScreeningFieldSpec(
          key: 'result',
          label: 'Lipid / cholesterol result',
          hint: 'Enter the reported result',
        ),
        ScreeningFieldSpec(
          key: 'unit',
          label: 'Unit',
          hint: 'e.g. mg/dL or mmol/L',
        ),
      ];
    }
    if (t.contains('tsh')) {
      return const [
        ScreeningFieldSpec(
          key: 'result',
          label: 'TSH result',
          hint: 'Enter reported result',
        ),
        ScreeningFieldSpec(key: 'unit', label: 'Unit'),
      ];
    }
    if (t.contains('hiv') || t.contains('sti')) {
      return const [
        ScreeningFieldSpec(
          key: 'result',
          label: 'Result',
          options: ['Not done', 'Negative', 'Positive', 'Indeterminate'],
        ),
      ];
    }
    return const [
      ScreeningFieldSpec(
        key: 'result',
        label: 'Screening result / finding',
        hint: 'Enter the result or record that the screen was completed',
      ),
    ];
  }

  if (s == 'immunisations due') {
    return const [
      ScreeningFieldSpec(
        key: 'status',
        label: 'Status',
        options: ['Due', 'Given', 'Deferred', 'Not applicable', 'Unknown'],
      ),
      ScreeningFieldSpec(
        key: 'date',
        label: 'Date given / reviewed',
        hint: 'DD/MM/YYYY',
      ),
    ];
  }

  if (s == 'development & mental-behavioural health') {
    return const [
      ScreeningFieldSpec(
        key: 'result',
        label: 'Assessment result',
        options: ['Achieved / appropriate', 'Concern', 'Not achieved', 'Not assessed'],
      ),
      ScreeningFieldSpec(
        key: 'observation',
        label: 'Observation',
        hint: 'Record the observed behaviour / milestone / screen result',
      ),
    ];
  }

  if (s == 'anticipatory guidance') {
    return const [
      ScreeningFieldSpec(
        key: 'status',
        label: 'Guidance status',
        options: ['Given', 'Not given', 'Not applicable'],
      ),
    ];
  }

  if (s == 'referrals considered') {
    return const [
      ScreeningFieldSpec(
        key: 'action',
        label: 'Referral action',
        options: ['No referral', 'Considered', 'Required', 'Completed'],
      ),
      ScreeningFieldSpec(
        key: 'details',
        label: 'Referral details',
        hint: 'Reason, destination or follow-up action',
      ),
    ];
  }

  if (s == 'vision / hearing / dental') {
    return const [
      ScreeningFieldSpec(
        key: 'result',
        label: 'Result / finding',
        options: ['Normal / completed', 'Abnormal / concern', 'Not done'],
      ),
      ScreeningFieldSpec(
        key: 'details',
        label: 'Finding / details',
        hint: 'Record the observation or result',
      ),
    ];
  }

  // Physical examination and any remaining checklist item.
  return const [
    ScreeningFieldSpec(
      key: 'result',
      label: 'Finding / result',
      options: ['Normal', 'Abnormal / concern', 'Not assessed'],
    ),
    ScreeningFieldSpec(
      key: 'details',
      label: 'Clinical finding',
      hint: 'Record the relevant examination finding',
    ),
  ];
}
