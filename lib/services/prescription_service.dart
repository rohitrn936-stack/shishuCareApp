import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> savePrescription({
    required String childID,
    required String diagnosis,
    required String notes,
    required List<Map<String, String>> medicines,
  }) async {
    await _firestore
        .collection("children")
        .doc(childID)
        .collection("prescriptions")
        .add({
          "diagnosis": diagnosis,
          "notes": notes,
          "medicines": medicines,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }
}
