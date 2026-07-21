import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------------
  // Generate Child ID
  // -------------------------------
  Future<String> generateChildID() async {
    final DocumentReference counterRef = _firestore
        .collection("counters")
        .doc("childCounter");

    return await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot snapshot = await transaction.get(counterRef);

      int currentNumber;

      if (!snapshot.exists) {
        currentNumber = 1;

        transaction.set(counterRef, {"current": currentNumber});
      } else {
        currentNumber = (snapshot["current"] as int) + 1;

        transaction.update(counterRef, {"current": currentNumber});
      }

      return "CH${currentNumber.toString().padLeft(4, '0')}";
    });
  }

  // -------------------------------
  // Register Child
  // -------------------------------
  Future<String> registerChild({
    required String childName,
    required String guardianName,
    required String phone,
    required String village,
    required String gender,
    required DateTime dob,
    required int ageYears,
    required int ageMonths,
  }) async {
    final String childID = await generateChildID();

    await _firestore.collection("children").doc(childID).set({
      "childID": childID,
      "childName": childName,
      "guardianName": guardianName,
      "phone": phone,
      "village": village,
      "gender": gender,
      "dob": Timestamp.fromDate(dob),
      "ageYears": ageYears,
      "ageMonths": ageMonths,
      "registeredAt": FieldValue.serverTimestamp(),
    });

    return childID;
  }

  // -------------------------------
  // Get Child Details
  // -------------------------------
  Future<DocumentSnapshot> getChild(String childID) async {
    return await _firestore.collection("children").doc(childID).get();
  }

  // -------------------------------
  // Get Screening History
  // -------------------------------
  Future<QuerySnapshot> getScreenings(String childID) async {
    return await _firestore
        .collection("children")
        .doc(childID)
        .collection("screenings")
        .orderBy("screeningDate", descending: true)
        .get();
  }

  // -------------------------------
  // Search by Child ID
  // -------------------------------
  Future<QuerySnapshot> searchByChildID(String childID) async {
    return await _firestore
        .collection("children")
        .where("childID", isEqualTo: childID)
        .get();
  }

  // -------------------------------
  // Search by Child Name
  // -------------------------------
  Future<QuerySnapshot> searchByChildName(String childName) async {
    return await _firestore
        .collection("children")
        .where("childName", isGreaterThanOrEqualTo: childName)
        .where("childName", isLessThan: "$childName\uf8ff")
        .get();
  }
}
