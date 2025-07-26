import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/auth.dart';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/features/jwt.dart';
import 'package:project_base/services/server/smtp.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class AuthService {
  final AuthController authController = AuthController();
  final UserController userController = UserController();
  final StmpService smtpService = StmpService();
  final JwtService jwtService = JwtService();

  Future<void> register(HttpRequest req, HttpResponse res) async {
    final body = await req.bodyAsJsonMap;
    if (body.isNotEmpty) {
      final username = body['name'].toString();
      final email = body['email'].toString();
      final password = body['password'].toString();
      final pushNotificationId = body['pushNotificationId'].toString();
      final user = User(
        id: ObjectId().oid,
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
        final user = result.data;

        final jwt = ApiResponse(data: await jwtService.createJwt(user!));
        await authController.replaceTokenInDb(jwt.data!);

        return JsonResponseHelper.sendJsonResponse(
          statusCode: result.statusCode,
          res,
          jwt,
        );
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
    //       newPas
  }
}
