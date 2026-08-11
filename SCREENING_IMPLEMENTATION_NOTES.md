# Preventive screening implementation

The screening flow now uses the complete 31-visit paediatric preventive-care checklist supplied with the project.

## What changed

- Added all 31 age/visit checklists from the supplied PDF.
- Preserved the wording of each checklist item.
- Added a visit selector so a clinician can use the recommended age visit or manually choose another visit.
- Each checklist item now has:
  - completion status
  - red-flag control
  - item-specific result fields where applicable
  - clinical notes
- Growth measurements have dedicated fields and units for weight, length/height, head circumference, gestational age, BMI/BMI percentile, BP, Tanner stage, SpO₂ and jaundice findings where those appear in the supplied checklist.
- Laboratory items have dedicated result fields for the listed tests such as haemoglobin, bilirubin and TSH, plus appropriate result/unit fields for other screening entries.
- Immunisation entries have status and date/review fields.
- Development/mental-behavioural entries have structured result and observation fields.
- Guidance and referral entries have structured action/status fields.
- Screening records now also store the visit number and total item count in Firestore.

## Source

The original supplied checklist PDF is retained at:

`docs/Paediatric_Preventive_Care_Checklist_v1.0.pdf`

The PDF itself states that it is clinical decision support and not a standard of care, and that vaccines should be verified against the current IAP-ACVIP chart before use.
