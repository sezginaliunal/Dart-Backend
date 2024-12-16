import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/auth.dart';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/server/smtp.dart';
import 'package:project_base/utils/helpers/json_helper.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final AuthController authController = AuthController();
  final UserController userController = UserController();
  final StmpService smtpService = StmpService();

  Future<void> register(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    if (body.isNotEmpty) {
      final username = body['name'].toString();
      final email = body['email'].toString();
      final password = body['password'].toString();
      final pushNotificationId = body['pushNotificationId'].toString();
      final user = User(
        id: const Uuid().v4(),
        username: username,
        email: email,
        password: password,
        pushNotificationId: pushNotificationId,
      );
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
        ApiResponse(
          success: false,
          message: ResponseMessages.invalidBody.message,
        ),
      );
    }
  }

  Future<void> login(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;

    if (body.isNotEmpty) {
      final email = body['email'].toString();
      final password = body['password'].toString();

      final result = await authController.login(email, password);

      if (result.success) {
        final isUserExist = await userController.isUserExist(email);
        if (isUserExist.data != null) {
          // JwtModel'i JSON formatında döndürme
          return JsonResponseHelper.sendJsonResponse(
            statusCode: result.statusCode,
            res,
            ApiResponse(message: ResponseMessages.successLogin.message),
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
        ApiResponse(
          success: false,
          message: ResponseMessages.invalidBody.message,
        ),
      );
    }
  }

  Future<void> resetPassword(HttpRequest req, HttpResponse res) async {
    // final body = await req.bodyAsJsonMap;
    // if (body.isNotEmpty) {
    //   final email = body['email'].toString();
    //   final user = await userController.isUserExist(email);
    //   if (user.data != null) {
    //     final newPassword = PasswordGenerator.generatePassword();
    //     await userController.updateUser(
    //       user.data!.id,
    //       'password',
    //       newPassword.toSha256(),
    //     );

    //     await smtpService.sendMessage(
    //       user.data!.email,
    //       newPassword,
    //       '${user.data?.name} ${user.data?.surname}',
    //     );

    //     final result = ApiResponse<void>(
    //       message: 'New password sent to your email',
    //     );

    //     return JsonResponseHelper.sendJsonResponse(
    //       statusCode: result.statusCode,
    //       res,
    //       result,
    //     );
    //   } else {
    //     final result = ApiResponse<void>(
    //       success: false,
    //       message: 'User not found',
    //       statusCode: HttpStatus.notFound,
    //     );
    //     return JsonResponseHelper.sendJsonResponse(
    //       statusCode: result.statusCode,
    //       res,
    //       result,
    //     );
    //   }
    // } else {
    //   final result = ApiResponse<void>(
    //     success: false,
    //     message: 'Invalid request',
    //   );
    //   return JsonResponseHelper.sendJsonResponse(
    //     statusCode: result.statusCode,
    //     res,
    //     result,
    //   );
    // }
  }
}
