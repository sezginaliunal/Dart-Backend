import 'package:alfred/alfred.dart';
import 'package:project_base/model/api_response.dart';

class JsonResponseHelper {
  static Future<void> sendJsonResponse(
    HttpResponse res,
    ApiResponse<dynamic> result, {
    int statusCode = 200,
  }) async {
    res.statusCode = statusCode;
    await res.json(result.toJson((value) => value as Object));
  }
}
