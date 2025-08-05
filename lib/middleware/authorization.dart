import 'dart:async';
import 'dart:io';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/services/features/jwt.dart';
import 'package:project_base/utils/enums/account.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class Middleware {
  final JwtService jwtService = JwtService();
  final userController = UserController();
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

    final isUserExist = await userController.findUserByField('_id', userId);
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

    final parseUser = await userController.findUserByField('_id', userId);
    if (parseUser.success) {
      final userRole = checkAccountRole(parseUser.data?.accountRole ?? 0);
      final isAdmin = userRole.isAdmin;
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
//Token check
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
    final user = await userController.findUserByField('_id', userId);
    if (user.data?.accountStatus != AccountStatus.active.value) {
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

  FutureOr<void> isPrivilegedUser(HttpRequest req, HttpResponse res) async {
    final userId = req.headers.value('userId');
//Null mı
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
//Kullanıcı Var mı
    final isUserExist = await userController.findUserByField('_id', userId);
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

    final parseUser = await userController.findUserByField('_id', userId);
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
