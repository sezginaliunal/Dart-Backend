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

      final result = await userController.findUserByField('_id', id);

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
          statusCode: HttpStatus.badRequest,
          success: false,
          message: ResponseMessages.invalidBody.message,
        ),
      );
    }
  }

  Future<void> getUsers(HttpRequest req, HttpResponse res) async {
    final params = req.uri.queryParameters;

    try {
      // Parametreleri al ve varsayılan değer ata
      final page =
          params.containsKey('page') ? int.tryParse(params['page']!) : null;
      final limit =
          params.containsKey('limit') ? int.tryParse(params['limit']!) : null;

      final descending =
          params['descending']?.toLowerCase() == 'true'; // Varsayılan: false

      final result = await userController.getUsers(
        page: page,
        limit: limit,
        descending: descending,
      );
      return JsonResponseHelper.sendJsonResponse(
        statusCode: result.statusCode,
        res,
        result,
      );
    } on Exception catch (e) {
      return JsonResponseHelper.sendJsonResponse(
        statusCode: HttpStatus.badRequest,
        res,
        ApiResponse(
          success: false,
          statusCode: HttpStatus.badRequest,
          message: 'Invalid query parameters: $e',
        ),
      );
    }
  }

  Future<void> updateUser(HttpRequest req, HttpResponse res) async {
    final params = req.params;
    final body = await req.bodyAsJsonMap;
    if (params.isNotEmpty || body.isNotEmpty) {
      final id = params['id'].toString();
      final field = body['field'].toString();
      final value = body['value'].toString();

      final result = await userController.updateUser(id, field, value);

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
          statusCode: HttpStatus.badRequest,
          success: false,
          message: ResponseMessages.invalidBody.message,
        ),
      );
    }
  }
}
