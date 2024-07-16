import 'dart:convert';

import 'package:alfred/alfred.dart';

extension HttpRequestExtension on HttpRequest {
  Future<Map<String, dynamic>?> parseBodyJson() async {
    if (headers.contentType?.mimeType == 'application/json') {
      try {
        final body = await utf8.decodeStream(this);
        return jsonDecode(body);
      } catch (e) {
        print('JSON parsing error: $e');
      }
    }
    return null;
  }
}
