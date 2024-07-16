import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/main.dart';

class FileUploadController {
  Future<String> handleFileUpload(
      HttpRequest req, Map<String, dynamic> body) async {
    final uploadedFile = (body['file'] as HttpBodyFileUpload);

    // Create the upload directory if it doesn't exist
    if (!(await uploadDirectory.exists())) {
      await uploadDirectory.create();
    }

    // Get the uploaded file content
    var fileBytes = uploadedFile.content as List<int>;

    // Create the local file name and save the file
    final filePath = '${uploadDirectory.path}/${uploadedFile.filename}';
    await File(filePath).writeAsBytes(fileBytes);

    // Construct the avatar URL
    final avatarUrl =
        'https://${req.headers.host}/files/${uploadedFile.filename}';
    return avatarUrl;
  }
}
