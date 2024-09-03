import 'dart:async';
import 'dart:io';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/features/jwt.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class Middleware {
  final JwtService jwtService = JwtService();
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

  // Bearer token doğrulama fonksiyonu
  FutureOr<void> authenticate(HttpRequest req, HttpResponse res) async {
    final authHeader = req.headers.value('Authorization');
    final userId = req.headers.value('userId');

    if (authHeader == null ||
        !authHeader.startsWith('Bearer ') ||
        userId == null) {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.invalidHeader.message,
        statusCode: HttpStatus.unauthorized,
      );

      return JsonResponseHelper.sendJsonResponse(
        res,
        result,
        statusCode: result.statusCode,
      );
    }

    final token = authHeader.substring(7); // 'Bearer ' kısmını çıkart

    final isValid = await jwtService.checkJwt(token, userId);

    if (!isValid) {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.invalidToken.message,
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
