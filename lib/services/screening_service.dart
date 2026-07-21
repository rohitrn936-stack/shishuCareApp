import 'package:cloud_firestore/cloud_firestore.dart';

class ScreeningService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveScreening({
    required String childID,
    required String ageGroup,
    required List<Map<String, dynamic>> results,
  }) async {
    int redFlagCount = 0;
    int completedItems = 0;

    for (final item in results) {
      if (item["checked"] == true) {
        completedItems++;
      }

      if (item["redFlag"] == true) {
        redFlagCount++;
      }
    }

    await _firestore
        .collection("children")
        .doc(childID)
        .collection("screenings")
        .add({
          "screeningDate": FieldValue.serverTimestamp(),
          "ageGroup": ageGroup,
          "results": results,
          "redFlagCount": redFlagCount,
          "completedItems": completedItems,
        });
  }
}
