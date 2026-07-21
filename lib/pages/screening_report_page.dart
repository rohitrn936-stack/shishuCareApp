import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:web_page/services/pdf_service.dart';

class ScreeningReportPage extends StatelessWidget {
  final String childID;
  final DocumentSnapshot screening;

  const ScreeningReportPage({
    super.key,
    required this.childID,
    required this.screening,
  });

  @override
  Widget build(BuildContext context) {
    final data = screening.data() as Map<String, dynamic>;

    final List results = data["results"];

    final Timestamp? timestamp = data["screeningDate"];

    final DateTime date = timestamp?.toDate() ?? DateTime.now();

    final int redFlagCount = data["redFlagCount"] ?? 0;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      appBar: AppBar(
        title: const Text("Screening Report"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (redFlagCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "⚑ $redFlagCount flagged",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),

      body: Center(
        child: Container(
          width: 850,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Center(
                  child: Text(
                    "Screening Report",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Child ID : $childID",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 10),

                Text(
                  "Date : ${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 10),

                Text(
                  "Age Group : ${data["ageGroup"]}",
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 35),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Export PDF"),
                    onPressed: () async {
                      final pdf = await PdfService().generateReport(
                        childID: childID,
                        ageGroup: data["ageGroup"],
                        date: "${date.day}/${date.month}/${date.year}",
                        results: results,
                      );

                      await Printing.layoutPdf(
                        onLayout: (format) async => pdf.save(),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),
                ...results.map((item) {
                  final bool isChecked = item["checked"] == true;
                  final bool isFlagged = item["redFlag"] == true;
                  final String redFlagText = (item["redFlagText"] ?? "").toString();
                  final bool isUniversal = item["isUniversal"] == true;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),

                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            item["title"],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 15),

                          if (!isUniversal)
                            Row(
                              children: [
                                Icon(
                                  isChecked ? Icons.check_circle : Icons.cancel,
                                  color: isChecked ? Colors.green : Colors.grey,
                                ),

                                const SizedBox(width: 10),

                                Text(isChecked ? "Completed" : "Not Completed"),
                              ],
                            ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(
                                isFlagged ? Icons.flag : Icons.flag_outlined,
                                color: isFlagged ? Colors.red : Colors.grey,
                              ),

                              const SizedBox(width: 10),

                              Text(isFlagged ? "Red Flag" : "No Red Flag"),
                            ],
                          ),

                          if (isFlagged && redFlagText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              redFlagText,
                              style: const TextStyle(
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],

                          if (!isUniversal) ...[
                            const SizedBox(height: 20),

                            const Text(
                              "Notes",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              item["notes"].toString().isEmpty
                                  ? "-"
                                  : item["notes"],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}