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
              'ShishuCare',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Child ID : $childID', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Age Group : $ageGroup', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Date : $date', style: const pw.TextStyle(fontSize: 16)),
          pw.Divider(),
          ...results.map((rawItem) {
            final item = rawItem as Map<String, dynamic>;
            final fields = item['fields'] is Map
                ? (item['fields'] as Map).map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  )
                : <String, String>{};

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  item['title']?.toString() ?? 'Checklist item',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Completed : ${item['checked'] == true ? 'Yes' : 'No'}'),
                pw.Text('Red Flag : ${item['redFlag'] == true ? 'Yes' : 'No'}'),
                if ((item['status']?.toString() ?? '').isNotEmpty)
                  pw.Text('Status : ${item['status']}'),
                for (final entry in fields.entries)
                  if (entry.value.trim().isNotEmpty)
                    pw.Text('${_prettyFieldName(entry.key)} : ${entry.value}'),
                pw.Text('Notes : ${item['notes']?.toString() ?? ''}'),
                pw.Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );

    return pdf;
  }

  String _prettyFieldName(String key) {
    switch (key) {
      case 'value': return 'Value';
      case 'result': return 'Result';
      case 'details': return 'Details';
      case 'observation': return 'Observation';
      case 'action': return 'Action';
      case 'tool': return 'Tool';
      case 'method': return 'Method';
      case 'percentile': return 'Percentile';
      case 'systolic': return 'Systolic BP';
      case 'diastolic': return 'Diastolic BP';
      case 'stage': return 'Tanner stage';
      case 'date': return 'Date';
      case 'unit': return 'Unit';
      case 'status': return 'Status';
      default: return key;
    }
  }
}
