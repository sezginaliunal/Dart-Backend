import 'dart:async';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

class Middleware {
  FutureOr authorization(HttpRequest req, HttpResponse res) {
    if (req.headers.value('Authorization') != 'apikey') {
      return ResponseHandler(message: ResponseMessage.unauthorizedAccess);
    }
  }

  FutureOr fileUpload(HttpRequest req, HttpResponse res) async {
    const maxFileSize = 1024 * 1024;
    int contentLength = req.headers.contentLength;

    if (contentLength > maxFileSize) {
      return ResponseHandler(message: ResponseMessage.fileTooLarge);
    }

    List<String> acceptedFileTypes = ['image/jpeg', 'image/png'];
    String contentType = req.headers.contentType?.mimeType ?? '';

    if (!acceptedFileTypes.contains(contentType)) {
      return ResponseHandler(message: ResponseMessage.itemUnavailable);
    }

    return null;
  }
}
