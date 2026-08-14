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
    final extension = fileName.split('.').last.toLowerCase();

    String contentType = 'application/octet-stream';

    if (extension == 'pdf') {
      contentType = 'application/pdf';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      contentType = 'image/jpeg';
    } else if (extension == 'png') {
      contentType = 'image/png';
    }

    final ref = _storage
        .ref()
        .child('prescriptions')
        .child(childID)
        .child(screeningID)
        .child(fileName);

    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(fileBytes, metadata);

    return await ref.getDownloadURL();
  }
}
