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
      final page = int.tryParse(params['page'] ?? '1') ?? 1; // Varsayılan: 1
      final limit =
          int.tryParse(params['limit'] ?? '10') ?? 10; // Varsayılan: 10
      final sort = params['sort'] ?? '_id'; // Varsayılan: '_id'
      final descending =
          params['descending']?.toLowerCase() == 'true'; // Varsayılan: false

      final result = await userController.getUsers(
        page,
        limit,
        sort,
        descending: descending,
      );
      return JsonResponseHelper.sendJsonResponse(
        statusCode: result.statusCode,
        res,
        result,
      );
    } catch (e) {
      // Hata durumunda uygun yanıt döndür
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
