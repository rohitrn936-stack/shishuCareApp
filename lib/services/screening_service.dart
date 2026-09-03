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
    Map<String, dynamic>? prescriptionData,
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

    final Map<String, dynamic> dataToSave = {
      "screeningDate": customScreeningDate != null
          ? Timestamp.fromDate(customScreeningDate)
          : FieldValue.serverTimestamp(),
      "ageGroup": ageGroup,
      "results": results,
      "redFlagCount": redFlagCount,
      "completedItems": completedItems,
      "flagsByDomain": flagsByDomain,
      if (parsedWeight != null) "weight": parsedWeight,
      if (parsedHeight != null) "height": parsedHeight,
    };

    if (prescriptionUrl != null) {
      dataToSave["prescriptionUrl"] = prescriptionUrl;
    } else if (existingScreeningID != null && existingScreeningID.isNotEmpty) {
      dataToSave["prescriptionUrl"] = FieldValue.delete();
    }

    if (prescriptionFileName != null) {
      dataToSave["prescriptionFileName"] = prescriptionFileName;
    } else if (existingScreeningID != null && existingScreeningID.isNotEmpty) {
      dataToSave["prescriptionFileName"] = FieldValue.delete();
    }

    if (prescriptionData != null) {
      dataToSave["prescriptionData"] = prescriptionData;
    } else if (existingScreeningID != null && existingScreeningID.isNotEmpty) {
      dataToSave["prescriptionData"] = FieldValue.delete();
    }

    await docRef.set(dataToSave, SetOptions(merge: true));
  }

  Future<void> deleteScreening({
    required String childID,
    required String screeningID,
  }) async {
    final docRef = _firestore
        .collection("children")
        .doc(childID)
        .collection("screenings")
        .doc(screeningID);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          final prescriptionUrl = data['prescriptionUrl'] as String?;
          final prescriptionFileName = data['prescriptionFileName'] as String?;

          if (prescriptionUrl != null && prescriptionUrl.isNotEmpty) {
            await _storageService.deletePrescriptionByUrl(prescriptionUrl);
          } else if (prescriptionFileName != null && prescriptionFileName.isNotEmpty) {
            await _storageService.deletePrescriptionFile(
              childID: childID,
              screeningID: screeningID,
              fileName: prescriptionFileName,
            );
          }
        }
      }
    } catch (_) {}

    // Delete screening document (deletes embedded prescriptionData permanently)
    await docRef.delete();

    // Clean up any legacy subcollection entries
    try {
      final legacyDocs = await _firestore
          .collection("children")
          .doc(childID)
          .collection("prescriptions")
          .where("screeningID", isEqualTo: screeningID)
          .get();
      for (final d in legacyDocs.docs) {
        await d.reference.delete();
      }
    } catch (_) {}
  }
}