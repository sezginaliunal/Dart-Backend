import 'dart:async';
import 'dart:io';
import 'package:hali_saha/config/constants/response_messages.dart';
import 'package:hali_saha/controllers/user_controller.dart';
import 'package:hali_saha/model/api_response.dart';
import 'package:hali_saha/services/features/jwt.dart';
import 'package:hali_saha/utils/enums/account.dart';
import 'package:hali_saha/utils/helpers/json_helper.dart';

class Middleware {
  final JwtService jwtService = JwtService();
  final UserController userController = UserController();
  // Admin olup olmadığını kontrol eden fonksiyon
  FutureOr<void> isAdmin(HttpRequest req, HttpResponse res) async {
    final userId = req.headers.value('userId');

    if (userId == null) {
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

    final isUserExist = await userController.isUserExist(userId);
    if (!isUserExist.success) {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
      );

      return JsonResponseHelper.sendJsonResponse(
        res,
        result,
        statusCode: result.statusCode,
      );
    }

    final parseUser = await userController.getUserById(userId);
    if (parseUser.success) {
      final isAdmin = parseUser.data?.accountRole == AccountRole.admin;
      if (!isAdmin) {
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
    } else {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
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

  FutureOr<void> isPrivilegedUser(HttpRequest req, HttpResponse res) async {
    final userId = req.headers.value('userId');

    if (userId == null) {
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

    final isUserExist = await userController.isUserExist(userId);
    if (!isUserExist.success) {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
      );

      return JsonResponseHelper.sendJsonResponse(
        res,
        result,
        statusCode: result.statusCode,
      );
    }

    final parseUser = await userController.getUserById(userId);
    if (parseUser.success) {
      // Enum değerini int üzerinden kontrol et
      final userRole = checkAccountRole(parseUser.data?.accountRole ?? 0);
      final isPrivileged = userRole.isPrivileged;

      if (!isPrivileged) {
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
    } else {
      final result = ApiResponse<void>(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
      );

      return JsonResponseHelper.sendJsonResponse(
        res,
        result,
        statusCode: result.statusCode,
      );
    }
  }
}
