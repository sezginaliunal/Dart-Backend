import 'dart:io';

import 'package:alfred/alfred.dart';

final _uploadDirectory = Directory('uploadedFiles');

class FileUploadController {
  static Future<Map<String, String>> handleUpload(
      HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;

    // Create the upload directory if it doesn't exist
    if (!(await _uploadDirectory.exists())) {
      await _uploadDirectory.create();
    }

    // Get the uploaded file content
    final uploadedFile = (body['file'] as HttpBodyFileUpload);
    var fileBytes = (uploadedFile.content as List<int>);

    // Create the local file name and save the file
    await File('${_uploadDirectory.path}/${uploadedFile.filename}')
        .writeAsBytes(fileBytes);

    // Return the path to the user
    final filePath =
        'https://${req.headers.host}/files/${uploadedFile.filename}';
    return {'path': filePath};
  }
}
