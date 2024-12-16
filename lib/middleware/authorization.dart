import 'dart:async';
import 'dart:io';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class Middleware {
  // Admin olup olmadığını kontrol eden fonksiyon
  FutureOr<void> isAdmin(HttpRequest req, HttpResponse res) async {
    final roleHeader = req.headers.value('role');
    if (roleHeader == null || roleHeader != AccountRole.admin.name) {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.unauthorized.message,
        statusCode: HttpStatus.unauthorized,
      );

      return JsonResponseHelper.sendJsonResponse(
        res,
        result,
        statusCode: result.statusCode,
      );
    }
  }
}
