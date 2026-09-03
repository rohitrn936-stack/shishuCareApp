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
    String parentType = 'Guardian',
    required String phone,
    String houseNo = '',
    String street = '',
    String locality = '',
    String city = '',
    String pincode = '',
    required String address,
    required String gender,
    required DateTime dob,
    required int ageYears,
    required int ageMonths,
  }) async {
    final String childID = await generateChildID();

    await _firestore.collection("children").doc(childID).set({
      "childID": childID,
      "childName": childName,
      "parentType": parentType,
      "guardianName": guardianName,
      "phone": phone,
      "houseNo": houseNo,
      "street": street,
      "locality": locality,
      "city": city,
      "pincode": pincode,
      "address": address,
      "village": address, // Keep fallback for existing queries
      "gender": gender,
      "dob": Timestamp.fromDate(dob),
      "ageYears": ageYears,
      "ageMonths": ageMonths,
      "registeredAt": FieldValue.serverTimestamp(),
    });

    return childID;
  }

  // -------------------------------
  // Update Child Profile
  // -------------------------------
  Future<void> updateChild({
    required String childID,
    required String childName,
    required String guardianName,
    String parentType = 'Mother',
    required String phone,
    String houseNo = '',
    String street = '',
    String locality = '',
    String city = '',
    String pincode = '',
    required String address,
    required String gender,
    required DateTime dob,
    required int ageYears,
    required int ageMonths,
  }) async {
    await _firestore.collection("children").doc(childID).update({
      "childName": childName,
      "parentType": parentType,
      "guardianName": guardianName,
      "phone": phone,
      "houseNo": houseNo,
      "street": street,
      "locality": locality,
      "city": city,
      "pincode": pincode,
      "address": address,
      "village": address,
      "gender": gender,
      "dob": Timestamp.fromDate(dob),
      "ageYears": ageYears,
      "ageMonths": ageMonths,
      "updatedAt": FieldValue.serverTimestamp(),
    });
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

  // -------------------------------
  // Case-Insensitive Search Children
  // -------------------------------
  Future<List<QueryDocumentSnapshot>> searchChildren(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return [];

    final snapshot = await _firestore.collection("children").get();

    return snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final childID = (data['childID'] ?? doc.id).toString().toLowerCase();
      final childName = (data['childName'] ?? '').toString().toLowerCase();
      final guardianName = (data['guardianName'] ?? '').toString().toLowerCase();
      final phone = (data['phone'] ?? '').toString().toLowerCase();
      final address = (data['address'] ?? data['village'] ?? '').toString().toLowerCase();

      return childID.contains(cleanQuery) ||
          childName.contains(cleanQuery) ||
          guardianName.contains(cleanQuery) ||
          phone.contains(cleanQuery) ||
          address.contains(cleanQuery);
    }).toList();
  }

  // -------------------------------
  // Vaccinations
  // -------------------------------
  Future<DocumentSnapshot> getVaccinations(String childID) async {
    return await _firestore
        .collection("children")
        .doc(childID)
        .collection("vaccinations")
        .doc("status")
        .get();
  }

  Future<void> updateVaccinationStatus({
    required String childID,
    required String vaccineId,
    required bool isDone,
  }) async {
    await _firestore
        .collection("children")
        .doc(childID)
        .collection("vaccinations")
        .doc("status")
        .set({
      vaccineId: {
        "completed": isDone,
        "date": isDone ? Timestamp.now() : null,
      }
    }, SetOptions(merge: true));
  }

  // -------------------------------
  // Reminder History
  // -------------------------------
  Future<QuerySnapshot> getReminderHistory(String childID) async {
    return await _firestore
        .collection("children")
        .doc(childID)
        .collection("reminders")
        .orderBy("sentAt", descending: true)
        .get();
  }
}
