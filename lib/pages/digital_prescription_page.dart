import 'package:flutter/material.dart';
import 'package:web_page/data/prescription_templates.dart';
import 'package:web_page/utils/snackbar_helper.dart';
import 'package:web_page/widgets/medicine_card.dart';
import 'package:web_page/widgets/sleek_app_bar.dart';

class DigitalPrescriptionPage extends StatefulWidget {
  final String childID;

  const DigitalPrescriptionPage({super.key, required this.childID});

  @override
  State<DigitalPrescriptionPage> createState() =>
      _DigitalPrescriptionPageState();
}

class _DigitalPrescriptionPageState extends State<DigitalPrescriptionPage> {
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  List<Map<String, TextEditingController>> medicines = [];
  PrescriptionTemplate? selectedTemplate;

  @override
  void initState() {
    super.initState();

    medicines.add({
      "medicine": TextEditingController(),
      "dosage": TextEditingController(),
      "duration": TextEditingController(),
      "instruction": TextEditingController(),
    });
  }

  void _applyTemplate(PrescriptionTemplate? template) {
    if (template == null) return;
    setState(() {
      selectedTemplate = template;
      diagnosisController.text = template.diagnosis;
      notesController.text = template.notes;

      for (final medicine in medicines) {
        medicine["medicine"]?.dispose();
        medicine["dosage"]?.dispose();
        medicine["duration"]?.dispose();
        medicine["instruction"]?.dispose();
      }
      medicines.clear();

      for (final med in template.medicines) {
        medicines.add({
          "medicine": TextEditingController(text: med["medicine"] ?? ""),
          "dosage": TextEditingController(text: med["dosage"] ?? ""),
          "duration": TextEditingController(text: med["duration"] ?? ""),
          "instruction": TextEditingController(text: med["instruction"] ?? ""),
        });
      }
    });
  }

  void _addMedicine() {
    setState(() {
      medicines.add({
        "medicine": TextEditingController(),
        "dosage": TextEditingController(),
        "duration": TextEditingController(),
        "instruction": TextEditingController(),
      });
    });
  }

  void _attachPrescription() {
    List<Map<String, String>> medicineList = [];

    for (final medicine in medicines) {
      final medName = medicine["medicine"]!.text.trim();
      if (medName.isNotEmpty) {
        medicineList.add({
          "medicine": medName,
          "dosage": medicine["dosage"]!.text.trim(),
          "duration": medicine["duration"]!.text.trim(),
          "instruction": medicine["instruction"]!.text.trim(),
        });
      }
    }

    final prescriptionMap = {
      "diagnosis": diagnosisController.text.trim(),
      "notes": notesController.text.trim(),
      "medicines": medicineList,
      if (selectedTemplate != null) "templateName": selectedTemplate!.name,
    };

    showTopSnackBar(context, "Prescription Attached to Screening");

    Navigator.pop(context, prescriptionMap);
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    notesController.dispose();

    for (final medicine in medicines) {
      medicine["medicine"]?.dispose();
      medicine["dosage"]?.dispose();
      medicine["duration"]?.dispose();
      medicine["instruction"]?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2FA),

      appBar: const SleekAppBar(
        title: 'Digital Prescription',
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Select Prescription Template",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<PrescriptionTemplate>(
              value: selectedTemplate,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
                hintText: "Choose a pre-determined template...",
              ),
              items: prescriptionTemplates.map((tmpl) {
                return DropdownMenuItem<PrescriptionTemplate>(
                  value: tmpl,
                  child: Text(tmpl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                );
              }).toList(),
              onChanged: _applyTemplate,
            ),

            const SizedBox(height: 24),

            const Text(
              "Diagnosis",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: diagnosisController,

              maxLines: 3,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),

                hintText: "Enter diagnosis...",
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Medicines",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),

            const SizedBox(height: 15),

            ...medicines.asMap().entries.map((entry) {
              final index = entry.key;

              final medicine = entry.value;

              return MedicineCard(
                medicineController: medicine["medicine"]!,

                dosageController: medicine["dosage"]!,

                durationController: medicine["duration"]!,

                instructionController: medicine["instruction"]!,

                onDelete: () {
                  if (medicines.length == 1) return;

                  setState(() {
                    medicines.removeAt(index);
                  });
                },
              );
            }),

            OutlinedButton.icon(
              onPressed: _addMedicine,

              icon: const Icon(Icons.add),

              label: const Text("Add Another Medicine"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Notes",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: notesController,

              maxLines: 4,

              decoration: const InputDecoration(
                border: OutlineInputBorder(),

                hintText: "Additional Notes",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              height: 50,

              child: ElevatedButton.icon(
                onPressed: _attachPrescription,
                icon: const Icon(Icons.check_circle),
                label: const Text("Attach Prescription to Screening"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
