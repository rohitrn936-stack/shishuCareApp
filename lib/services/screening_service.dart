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
  }) async {
    int redFlagCount = 0;
    int completedItems = 0;
    final Map<String, int> flagsByDomain = {};

    for (final item in results) {
      if (item["checked"] == true) {
        completedItems++;
      }
      if (item["redFlag"] == true) {
        redFlagCount++;
        final String title = item["title"] ?? "Unknown";
        flagsByDomain[title] = (flagsByDomain[title] ?? 0) + 1;
      }
    }

    final docRef = _firestore
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
      "screeningDate": FieldValue.serverTimestamp(),
      "ageGroup": ageGroup,
      "results": results,
      "redFlagCount": redFlagCount,
      "completedItems": completedItems,
      "flagsByDomain": flagsByDomain,
      "prescriptionUrl": prescriptionUrl,
    });
  }
}