import 'dart:convert';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleDriveService {
  static const String _driveScope =
      'https://www.googleapis.com/auth/drive.file';

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<String> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    await _googleSignIn.initialize();

    final authorization = await _googleSignIn.authorizationClient
        .authorizationForScopes(<String>[_driveScope]);

    final auth =
        authorization ??
        await _googleSignIn.authorizationClient.authorizeScopes(<String>[
          _driveScope,
        ]);

    final accessToken = auth.accessToken;

    if (accessToken == null) {
      throw Exception('Could not obtain Google Drive access token.');
    }

    final metadata = <String, dynamic>{'name': fileName, 'mimeType': mimeType};

    final boundary = 'flutter_drive_${DateTime.now().millisecondsSinceEpoch}';

    final body = <int>[];

    body.addAll(utf8.encode('--$boundary\r\n'));

    body.addAll(
      utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
    );

    body.addAll(utf8.encode(jsonEncode(metadata)));

    body.addAll(utf8.encode('\r\n--$boundary\r\n'));

    body.addAll(utf8.encode('Content-Type: $mimeType\r\n\r\n'));

    body.addAll(fileBytes);

    body.addAll(utf8.encode('\r\n--$boundary--\r\n'));

    final response = await http.post(
      Uri.parse(
        'https://www.googleapis.com/upload/drive/v3/files'
        '?uploadType=multipart',
      ),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/related; boundary=$boundary',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Google Drive upload failed.\n'
        'Status: ${response.statusCode}\n'
        'Response: ${response.body}',
      );
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    final fileId = responseData['id'] as String?;

    if (fileId == null || fileId.isEmpty) {
      throw Exception('Google Drive did not return a file ID.');
    }

    return fileId;
  }
}
