import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/i_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';

class UserController extends IController<User> {
  @override
  String get collectinName => CollectionPath.users.rawValue;

  @override
  Db get db => MongoDatabase().db;

  // Kullanıcıyı e-posta ile kontrol etme
  Future<ApiResponse<User?>> isUserExist(String id) async {
    final result =
        await db.collection(collectinName).findOne(where.eq('_id', id));
    if (result != null) {
      final user = User.fromJson(result);
      return ApiResponse(data: user);
    } else {
      return ApiResponse(
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
      );
    }
  }

  // Kullanıcıyı ID ile getirme
  Future<ApiResponse<User?>> getUserById(String id) async {
    try {
      final result =
          await db.collection(collectinName).findOne(where.eq('_id', id));

      if (result != null) {
        final user = User.fromJson(result);
        return ApiResponse(data: user);
      } else {
        return ApiResponse(
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } catch (e) {
      return ApiResponse(
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

// Kullanıcıyı güncelleme
  Future<void> updateUser(String userId, String field, dynamic value) async {
    await db
        .collection(collectinName)
        .updateOne(where.eq('_id', userId), modify.set(field, value));
  }
}
