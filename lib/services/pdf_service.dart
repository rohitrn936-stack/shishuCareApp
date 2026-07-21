import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<pw.Document> generateReport({
    required String childID,
    required String ageGroup,
    required String date,
    required List results,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build: (context) => [
          pw.Center(
            child: pw.Text(
              "ShishuCare AI",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Child ID : $childID",
            style: const pw.TextStyle(fontSize: 16),
          ),

          pw.Text(
            "Age Group : $ageGroup",
            style: const pw.TextStyle(fontSize: 16),
          ),

          pw.Text("Date : $date", style: const pw.TextStyle(fontSize: 16)),

          pw.Divider(),

          ...results.map((item) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,

              children: [
                pw.Text(
                  item["title"],
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 5),

                pw.Text("Completed : ${item["checked"] ? "Yes" : "No"}"),

                pw.Text("Red Flag : ${item["redFlag"] ? "Yes" : "No"}"),

                pw.Text("Notes : ${item["notes"]}"),

                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );

    return pdf;
  }
}
