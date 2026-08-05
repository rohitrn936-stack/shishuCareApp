import 'package:flutter/material.dart';
import 'package:web_page/services/prescription_service.dart';
import 'package:web_page/widgets/medicine_card.dart';

class DigitalPrescriptionPage extends StatefulWidget {
  final String childID;

  const DigitalPrescriptionPage({super.key, required this.childID});

  @override
  State<DigitalPrescriptionPage> createState() =>
      _DigitalPrescriptionPageState();
}

class _DigitalPrescriptionPageState extends State<DigitalPrescriptionPage> {
  final PrescriptionService _prescriptionService = PrescriptionService();

  final TextEditingController diagnosisController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  List<Map<String, TextEditingController>> medicines = [];

  bool isSaving = false;

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

  Future<void> _savePrescription() async {
    setState(() {
      isSaving = true;
    });

    List<Map<String, String>> medicineList = [];

    for (final medicine in medicines) {
      medicineList.add({
        "medicine": medicine["medicine"]!.text,
        "dosage": medicine["dosage"]!.text,
        "duration": medicine["duration"]!.text,
        "instruction": medicine["instruction"]!.text,
      });
    }

    await _prescriptionService.savePrescription(
      childID: widget.childID,

      diagnosis: diagnosisController.text,

      notes: notesController.text,

      medicines: medicineList,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Prescription Saved Successfully")),
    );

    Navigator.pop(context);
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

      appBar: AppBar(
        title: const Text("Digital Prescription"),

        backgroundColor: Colors.deepPurple,

        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
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
                onPressed: isSaving ? null : _savePrescription,

                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),

                label: Text(isSaving ? "Saving..." : "Save Prescription"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
