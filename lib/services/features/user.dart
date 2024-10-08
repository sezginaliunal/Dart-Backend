import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class UserService {
  final UserController userController = UserController();

  Future<void> getUserById(HttpRequest req, HttpResponse res) async {
    final params = req.params;
    if (params.isNotEmpty) {
      final id = params['id'].toString();

      final result = await userController.getUserById(id);

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
}
