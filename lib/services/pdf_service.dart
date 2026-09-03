import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  // CLINIC & DOCTOR DETAILS
  static const String clinicName = "Child Central";
  static const String clinicTagline = "Pediatric Growth & Child Development Clinic";
  static const String doctorName = "Dr. Jagadish Chinappa";
  static const String doctorRegNo = "MD Pediatrics, KMC Reg. #28842";
  static const String clinicAddress = "717/1 16th main 6th B cross, Koramangala, 3rd block, Bangalore - 560034";
  static const String clinicContact = "Contact: Child Central, Koramangala, Bangalore";

  static const List<Map<String, String>> vaccineList = [
    {'id': 'bcg', 'name': 'BCG (Tuberculosis)', 'age': 'At Birth'},
    {'id': 'opv_0', 'name': 'OPV 0 (Polio Birth Dose)', 'age': 'At Birth'},
    {'id': 'hepb_0', 'name': 'Hepatitis B (Birth Dose)', 'age': 'At Birth'},
    {'id': 'dtp_1', 'name': 'DTP 1 / Pentavalent 1', 'age': '6 Weeks'},
    {'id': 'opv_1', 'name': 'OPV 1', 'age': '6 Weeks'},
    {'id': 'rota_1', 'name': 'Rotavirus 1', 'age': '6 Weeks'},
    {'id': 'pcv_1', 'name': 'PCV 1', 'age': '6 Weeks'},
    {'id': 'dtp_2', 'name': 'DTP 2 / Pentavalent 2', 'age': '10 Weeks'},
    {'id': 'dtp_3', 'name': 'DTP 3 / Pentavalent 3', 'age': '14 Weeks'},
    {'id': 'mr_1', 'name': 'MR 1 / Measles 1', 'age': '9 Months'},
    {'id': 'mr_2', 'name': 'MR 2 / Measles 2', 'age': '16-24 Months'},
    {'id': 'dtp_b1', 'name': 'DTP Booster 1', 'age': '16-24 Months'},
    {'id': 'dtp_b2', 'name': 'DTP Booster 2', 'age': '5 Years'},
  ];

  static bool _isVaccineDueForAge(String vacAge, String visitAge) {
    final v = vacAge.toLowerCase().trim();
    final c = visitAge.toLowerCase().trim();

    if (v == c) return true;
    if (c.contains(v) || v.contains(c)) return true;

    if ((v.contains('birth') && c.contains('birth')) ||
        (v.contains('6 week') && c.contains('6 week')) ||
        (v.contains('10 week') && c.contains('10 week')) ||
        (v.contains('14 week') && c.contains('14 week')) ||
        (v.contains('9 month') && c.contains('9 month')) ||
        (v.contains('16-24') && (c.contains('15') || c.contains('18') || c.contains('24') || c.contains('16-24') || c.contains('2 year'))) ||
        (v.contains('5 year') && (c.contains('4 year') || c.contains('5 year')))) {
      return true;
    }

    return false;
  }

  Future<pw.Document> generateReport({
    required String childID,
    Map<String, dynamic>? childData,
    required String ageGroup,
    required String date,
    required List results,
    Map<String, dynamic>? prescriptionData,
    String? prescriptionUrl,
    String? prescriptionFileName,
    Map<String, dynamic>? vaccinationData,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#4A148C'); // Deep purple
    final secondaryColor = PdfColor.fromHex('#7B1FA2');
    final lightBg = PdfColor.fromHex('#F5F2F9');
    final borderColor = PdfColor.fromHex('#E0E0E0');

    final childName = childData?['childName']?.toString() ?? 'N/A';
    final parentType = childData?['parentType']?.toString() ?? 'Guardian';
    final guardianName = childData?['guardianName']?.toString() ?? 'N/A';
    final phone = childData?['phone']?.toString() ?? 'N/A';
    final gender = childData?['gender']?.toString() ?? 'N/A';
    final address = (childData?['address'] ?? childData?['village'])?.toString() ?? 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: borderColor, thickness: 1),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Confidential Medical Screening Document | $clinicName",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
                pw.Text(
                  "Page ${context.pageNumber} of ${context.pagesCount}",
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),

        build: (context) => [
          // 1. CLINIC LETTERHEAD HEADER
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      clinicName,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      clinicTagline,
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700, fontStyle: pw.FontStyle.italic),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      clinicAddress,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                    ),
                    pw.Text(
                      clinicContact,
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    doctorName,
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: secondaryColor),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    doctorRegNo,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Container(height: 2.5, color: primaryColor),
          pw.SizedBox(height: 12),

          // 2. PATIENT / SCREENING INFORMATION BOX
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: lightBg,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: borderColor),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("PATIENT DETAILS", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 3),
                        pw.Text("$childName ($childID)", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Gender: $gender | $parentType: $guardianName", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("VISIT MILESTONE", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 3),
                        pw.Text("Age Band: $ageGroup", style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Phone: $phone", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text("DATE OF VISIT", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 3),
                        pw.Text(date, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                if (address != 'N/A' && address.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text("Address: $address", style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                ],
              ],
            ),
          ),

          pw.SizedBox(height: 14),

          // 3. PRESCRIPTION SECTION (Rx)
          if (prescriptionData != null || prescriptionUrl != null) ...[
            pw.Row(
              children: [
                pw.Text(
                  "Rx - PRESCRIPTION",
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                if (prescriptionData?['templateName'] != null)
                  pw.Text(
                    " (${prescriptionData!['templateName']})",
                    style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                  ),
              ],
            ),
            pw.SizedBox(height: 6),

            if (prescriptionFileName != null)
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Text("Attached Document: $prescriptionFileName", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              ),

            if (prescriptionData != null) ...[
              if (prescriptionData['diagnosis']?.toString().isNotEmpty == true) ...[
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple50,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: PdfColors.purple200),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Diagnosis: ", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Expanded(
                        child: pw.Text(prescriptionData['diagnosis'], style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
              ],

              if (prescriptionData['medicines'] is List && (prescriptionData['medicines'] as List).isNotEmpty) ...[
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: borderColor, width: 0.5),
                  headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: primaryColor),
                  cellStyle: const pw.TextStyle(fontSize: 9),
                  cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  headers: ['Medicine Name', 'Dosage', 'Duration', 'Instructions'],
                  data: (prescriptionData['medicines'] as List).map<List<String>>((med) {
                    if (med is Map) {
                      return [
                        med['medicine']?.toString() ?? '',
                        med['dosage']?.toString() ?? '',
                        med['duration']?.toString() ?? '',
                        med['instruction']?.toString() ?? '',
                      ];
                    }
                    return ['', '', '', ''];
                  }).toList(),
                ),
                pw.SizedBox(height: 8),
              ],

              if (prescriptionData['notes']?.toString().isNotEmpty == true) ...[
                pw.Text("Doctor Advice / Notes:", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                pw.SizedBox(height: 2),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderColor),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(prescriptionData['notes'], style: const pw.TextStyle(fontSize: 9)),
                ),
                pw.SizedBox(height: 10),
              ],
            ],

            pw.SizedBox(height: 8),
          ],

          // 4. IMMUNIZATION & VACCINATION STATUS TABLE
          if (vaccinationData != null) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "IMMUNIZATION & VACCINATION STATUS",
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
                ),
                pw.Text(
                  "Current Visit Age: $ageGroup",
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.purple900),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(3.5),
                1: pw.FlexColumnWidth(2.0),
                2: pw.FlexColumnWidth(2.8),
                3: pw.FlexColumnWidth(2.2),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primaryColor),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Vaccine Name', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Due Age', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Status', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Date Administered', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ),
                  ],
                ),
                // Vaccine Rows
                ...vaccineList.map((vac) {
                  final id = vac['id']!;
                  final name = vac['name']!;
                  final dueAge = vac['age']!;
                  final record = vaccinationData[id];

                  final bool isDone = record is Map && record['completed'] == true;
                  final bool isDueForVisit = _isVaccineDueForAge(dueAge, ageGroup);

                  String adminDate = '-';
                  if (isDone) {
                    final rawDate = record['date'];
                    if (rawDate != null) {
                      if (rawDate is Timestamp) {
                        final dt = rawDate.toDate();
                        adminDate = '${dt.day}/${dt.month}/${dt.year}';
                      } else if (rawDate is DateTime) {
                        adminDate = '${rawDate.day}/${rawDate.month}/${rawDate.year}';
                      } else {
                        adminDate = rawDate.toString();
                      }
                    } else {
                      adminDate = 'Completed';
                    }
                  }

                  PdfColor rowBg = PdfColors.white;
                  PdfColor textColor = PdfColors.black;
                  String statusStr = 'Pending / Scheduled';

                  if (isDone) {
                    rowBg = PdfColors.green50;
                    textColor = PdfColors.green900;
                    statusStr = '[v] COMPLETED';
                  } else if (isDueForVisit) {
                    rowBg = PdfColors.amber100;
                    textColor = PdfColors.deepOrange900;
                    statusStr = '[!] DUE FOR THIS VISIT';
                  }

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: rowBg),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          name,
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: isDueForVisit || isDone ? pw.FontWeight.bold : pw.FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          dueAge,
                          style: pw.TextStyle(fontSize: 8.5, color: textColor),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          statusStr,
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          isDone ? adminDate : (isDueForVisit ? 'DUE NOW' : 'Pending'),
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: isDone ? pw.FontWeight.bold : pw.FontWeight.normal,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 14),
          ],

          // 5. SCREENING CHECKLIST RESULTS
          pw.Text(
            "SCREENING & DEVELOPMENTAL CHECKLIST",
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: primaryColor),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: secondaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            headers: ['Checklist Assessment Item', 'Completion Status', 'Red Flag Warning', 'Recorded Value & Notes'],
            data: results.map<List<String>>((item) {
              final title = item["title"]?.toString() ?? "";
              final checked = item["checked"] == true ? "COMPLETED" : "NOT COMPLETED";
              final redFlag = item["redFlag"] == true ? "YES (RED FLAG)" : "Normal";
              final value = item["value"]?.toString() ?? "";
              final unit = item["unit"]?.toString() ?? "";
              final notes = item["notes"]?.toString() ?? "";
              final redFlagText = item["redFlagText"]?.toString() ?? "";

              String details = "";
              if (value.isNotEmpty) details += "Value: $value $unit\n";
              if (notes.isNotEmpty) details += "Notes: $notes\n";
              if (item["redFlag"] == true && redFlagText.isNotEmpty) details += "Flag: $redFlagText";

              return [title, checked, redFlag, details.trim().isEmpty ? "-" : details.trim()];
            }).toList(),
          ),

          pw.SizedBox(height: 25),

          // 6. SIGNATURE & STAMP BLOCK
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Report Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  pw.Text("ShishuCare Developmental System", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(width: 140, height: 1, color: PdfColors.grey800),
                  pw.SizedBox(height: 4),
                  pw.Text("Doctor's Signature & Stamp", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  pw.Text(doctorName, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }
}
