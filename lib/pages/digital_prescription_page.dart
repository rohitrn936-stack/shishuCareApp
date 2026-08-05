import 'package:flutter/material.dart';

class DigitalPrescriptionPage extends StatefulWidget {
  const DigitalPrescriptionPage({super.key});

  @override
  State<DigitalPrescriptionPage> createState() =>
      _DigitalPrescriptionPageState();
}

class _DigitalPrescriptionPageState extends State<DigitalPrescriptionPage> {
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController medicineController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();

  @override
  void dispose() {
    diagnosisController.dispose();
    notesController.dispose();

    medicineController.dispose();
    dosageController.dispose();
    durationController.dispose();
    instructionController.dispose();

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

            const SizedBox(height: 25),
            const Text(
              "Medicine",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: "Medicine Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                hintText: "Example: 250 mg",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: "Duration",
                hintText: "Example: 5 Days",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: instructionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Instructions",
                hintText: "Example: After food",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

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
                hintText: "Additional notes...",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed: () {},

                icon: const Icon(Icons.save),

                label: const Text("Save Prescription"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
