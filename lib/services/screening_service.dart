import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_page/services/storage_service.dart';

class ScreeningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  Future<void> saveScreening({
    required String childID,
    required String ageGroup,
    required List<Map<String, dynamic>> results,
    Uint8List? prescriptionBytes,
    String? prescriptionFileName,
    DateTime? customScreeningDate,
    String? existingScreeningID,
  }) async {
    int redFlagCount = 0;
    int completedItems = 0;
    final Map<String, int> flagsByDomain = {};

    double? parsedWeight;
    double? parsedHeight;

    for (final item in results) {
      if (item["checked"] == true) {
        completedItems++;
      }
      if (item["redFlag"] == true) {
        redFlagCount++;
        final String title = item["title"] ?? "Unknown";
        flagsByDomain[title] = (flagsByDomain[title] ?? 0) + 1;
      }

      final title = (item["title"] as String? ?? "").toLowerCase();
      final unit = (item["unit"] as String? ?? "").toLowerCase();
      final valStr = item["value"] as String? ?? "";
      final numMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(valStr);
      if (numMatch != null) {
        final valNum = double.tryParse(numMatch.group(1)!);
        if (valNum != null) {
          if (title.contains('weight') || title.contains('wt') || unit == 'kg') {
            parsedWeight = valNum;
          } else if (title.contains('length') || title.contains('height') || title.contains('ht') || (unit == 'cm' && !title.contains('head') && !title.contains('hc'))) {
            parsedHeight = valNum;
          }
        }
      }
    }

    final docRef = (existingScreeningID != null && existingScreeningID.isNotEmpty)
        ? _firestore
            .collection("children")
            .doc(childID)
            .collection("screenings")
            .doc(existingScreeningID)
        : _firestore
            .collection("children")
            .doc(childID)
            .collection("screenings")
            .doc();

    String? prescriptionUrl;

    if (prescriptionBytes != null && prescriptionFileName != null) {
      prescriptionUrl = await _storageService.uploadPrescription(
        childID: childID,
        screeningID: docRef.id,
        fileBytes: prescriptionBytes,
        fileName: prescriptionFileName,
      );
    }

    await docRef.set({
      "screeningDate": customScreeningDate != null
          ? Timestamp.fromDate(customScreeningDate)
          : FieldValue.serverTimestamp(),
      "ageGroup": ageGroup,
      "results": results,
      "redFlagCount": redFlagCount,
      "completedItems": completedItems,
      "flagsByDomain": flagsByDomain,
      "prescriptionUrl": prescriptionUrl,
      if (parsedWeight != null) "weight": parsedWeight,
      if (parsedHeight != null) "height": parsedHeight,
    });
  }

  Future<void> deleteScreening({
    required String childID,
    required String screeningID,
  }) async {
    await _firestore
        .collection("children")
        .doc(childID)
        .collection("screenings")
        .doc(screeningID)
        .delete();
  }
}