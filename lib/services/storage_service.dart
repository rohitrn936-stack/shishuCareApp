import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPrescription({
    required String childID,
    required String screeningID,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child("prescriptions")
        .child(childID)
        .child(screeningID)
        .child(fileName);

    final uploadTask = await ref.putData(fileBytes);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> deletePrescriptionFile({
    required String childID,
    required String screeningID,
    required String fileName,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child("prescriptions")
          .child(childID)
          .child(screeningID)
          .child(fileName);
      await ref.delete();
    } catch (_) {}
  }

  Future<void> deletePrescriptionByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}