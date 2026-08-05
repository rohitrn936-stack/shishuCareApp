import 'package:flutter/material.dart';

class MedicineCard extends StatelessWidget {
  final TextEditingController medicineController;
  final TextEditingController dosageController;
  final TextEditingController durationController;
  final TextEditingController instructionController;

  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicineController,
    required this.dosageController,
    required this.durationController,
    required this.instructionController,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Text(
                  "Medicine",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const Spacer(),

                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
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
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: "Duration",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: instructionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Instructions",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
