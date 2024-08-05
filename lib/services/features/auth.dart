import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:project_base/controllers/auth.dart';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/features/jwt.dart';
import 'package:project_base/services/server/smtp.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/helpers/generate_password.dart';
import 'package:project_base/utils/helpers/json_helper.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final AuthController authController = AuthController();
  final UserController userController = UserController();
  final JwtService jwtService = JwtService();
  final StmpService smtpService = StmpService();

  Future<void> register(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    if (body.isNotEmpty) {
      final name = body['name'];
      final surname = body['surname'];
      final email = body['email'];
      final password = body['password'];
      final pushNotificationId = body['pushNotificationId'];
      final user = User(
          id: Uuid().v4(),
          name: name,
          surname: surname,
          email: email,
          password: password,
          pushNotificationId: pushNotificationId);
      final result = await authController.register(user);
      return JsonResponseHelper.sendJsonResponse(
        statusCode: result.statusCode,
        res,
        result,
      );
    } else {
      return JsonResponseHelper.sendJsonResponse(
          statusCode: HttpStatus.badRequest,
          res,
          ApiResponse(success: false, message: 'Body boş olamaz'));
    }
  }

  Future<void> login(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;

    if (body.isNotEmpty) {
      final email = body['email'];
      final password = body['password'];

      final result = await authController.login(email, password);

      if (result.success) {
        final isUserExist = await userController.isUserExist(email);
        if (isUserExist.data != null) {
          final user = isUserExist.data;
          final jwt = ApiResponse(data: await jwtService.createJwt(user!));

          await authController.replaceTokenInDb(jwt.data!);
          // JwtModel'i JSON formatında döndürme
          return JsonResponseHelper.sendJsonResponse(
            statusCode: result.statusCode,
            res,
            jwt,
          );
        }
      } else {
        return JsonResponseHelper.sendJsonResponse(
          statusCode: result.statusCode,
          res,
          result,
        );
      }
    } else {
      return JsonResponseHelper.sendJsonResponse(
          statusCode: HttpStatus.badRequest,
          res,
          ApiResponse(success: false, message: 'Body boş olamaz'));
    }
  }

  Future<void> logout(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    if (body.isNotEmpty) {
      final accessToken = body['accessToken'];
      final result = await authController.logout(accessToken);

      return JsonResponseHelper.sendJsonResponse(
        statusCode: result.statusCode,
        res,
        result,
      );
    } else {
      return JsonResponseHelper.sendJsonResponse(
          statusCode: HttpStatus.badRequest,
          res,
          ApiResponse(success: false, message: 'Body boş olamaz'));
    }
  }

  Future<void> resetPassword(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    if (body.isNotEmpty) {
      final String email = body['email'];
      final user = await userController.isUserExist(email);
      if (user.data != null) {
        final newPassword = PasswordGenerator.generatePassword();
        await userController.updateUser(
            user.data!.id.toString(), 'password', newPassword.toSha256());

        await smtpService.sendMessage(user.data!.email.toString(), newPassword,
            "${user.data?.name} ${user.data?.surname}");

        final result = ApiResponse<void>(
          success: true,
          message: 'New password sent to your email',
          data: null,
        );

        return JsonResponseHelper.sendJsonResponse(
          statusCode: result.statusCode,
          res,
          result,
        );
      } else {
        final result = ApiResponse<void>(
          success: false,
          message: 'User not found',
          data: null,
        );
        return JsonResponseHelper.sendJsonResponse(
          statusCode: result.statusCode,
          res,
          result,
        );
      }
    } else {
      final result = ApiResponse<void>(
        success: false,
        message: 'Invalid request',
        data: null,
      );
      return JsonResponseHelper.sendJsonResponse(
        statusCode: result.statusCode,
        res,
        result,
      );
    }
  }
}
