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

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,

      appBar: AppBar(
        title: const Text("Screening Report"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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

                          Row(
                            children: [
                              Icon(
                                item["checked"]
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: item["checked"]
                                    ? Colors.green
                                    : Colors.grey,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                item["checked"] ? "Completed" : "Not Completed",
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(
                                item["redFlag"]
                                    ? Icons.flag
                                    : Icons.flag_outlined,
                                color: item["redFlag"]
                                    ? Colors.red
                                    : Colors.grey,
                              ),

                              const SizedBox(width: 10),

                              Text(
                                item["redFlag"] ? "Red Flag" : "No Red Flag",
                              ),
                            ],
                          ),

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
