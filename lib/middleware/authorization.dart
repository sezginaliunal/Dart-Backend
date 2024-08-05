import 'dart:async';
import 'dart:io';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/utils/helpers/json_helper.dart';
import 'package:project_base/services/features/jwt.dart'; // JwtService'e ulaşmak için gerekli import

class Middleware {
  final JwtService jwtService = JwtService();
  // Admin olup olmadığını kontrol eden fonksiyon
  FutureOr<void> isAdmin(HttpRequest req, HttpResponse res) async {
    final roleHeader = req.headers.value('role');
    if (roleHeader == null || roleHeader != AccountRole.admin.name) {
      final result = ApiResponse(
          success: false,
          message: 'Unauthorized operation: Insufficient permissions',
          data: null,
          statusCode: HttpStatus.unauthorized);

      return JsonResponseHelper.sendJsonResponse(res, result,
          statusCode: result.statusCode);
    }
  }

  // Bearer token doğrulama fonksiyonu
  FutureOr<void> authenticate(HttpRequest req, HttpResponse res) async {
    final authHeader = req.headers.value('Authorization');
    final userId = req.headers.value('userId');

    if (authHeader == null ||
        !authHeader.startsWith('Bearer ') ||
        userId == null) {
      final result = ApiResponse(
          success: false,
          message: 'Authorization header is missing or invalid',
          data: null,
          statusCode: HttpStatus.unauthorized);

      return JsonResponseHelper.sendJsonResponse(res, result,
          statusCode: result.statusCode);
    }

    final token = authHeader.substring(7); // 'Bearer ' kısmını çıkart

    final isValid = await jwtService.checkJwt(token, userId);

    if (!isValid) {
      final result = ApiResponse(
          success: false,
          message: 'Invalid or expired token',
          data: null,
          statusCode: HttpStatus.unauthorized);

      return JsonResponseHelper.sendJsonResponse(res, result,
          statusCode: result.statusCode);
    }

    // Token geçerli ise işleme devam et
  }
}
