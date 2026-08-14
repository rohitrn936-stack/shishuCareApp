import 'package:cloud_firestore/cloud_firestore.dart';

class ScreeningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveScreening({
    required String childID,
    required String ageGroup,
    required int visitNumber,
    required List<Map<String, dynamic>> results,
  }) async {
    int redFlagCount = 0;
    int completedItems = 0;

    for (final item in results) {
      if (item['checked'] == true) {
        completedItems++;
      }

      if (item['redFlag'] == true) {
        redFlagCount++;
      }
    }

    final screeningRef = await _firestore
        .collection('children')
        .doc(childID)
        .collection('screenings')
        .add({
          'screeningDate': FieldValue.serverTimestamp(),
          'ageGroup': ageGroup,
          'visitNumber': visitNumber,
          'results': results,
          'redFlagCount': redFlagCount,
          'completedItems': completedItems,
          'totalItems': results.length,
        });

    return screeningRef.id;
  }

  Future<void> addPrescriptionUrl({
    required String childID,
    required String screeningID,
    required String prescriptionUrl,
    required String prescriptionFileName,
  }) async {
    await _firestore
        .collection('children')
        .doc(childID)
        .collection('screenings')
        .doc(screeningID)
        .update({
          'prescriptionUrl': prescriptionUrl,
          'prescriptionFileName': prescriptionFileName,
          'prescriptionUploadedAt': FieldValue.serverTimestamp(),
        });
  }
}
