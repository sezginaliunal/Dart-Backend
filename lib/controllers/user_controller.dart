import 'dart:io';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserController {
  final MongoDatabase _dbInstance = MongoDatabase();
  final String _collectionPath = CollectionPath.users.rawValue;

  // Kullanıcıyı e-posta ile kontrol etme
  Future<ApiResponse<User?>> isUserExist(String email) async {
    final result = await _dbInstance.db
        .collection(_collectionPath)
        .findOne(where.eq('email', email));
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
      final result = await _dbInstance.db
          .collection(_collectionPath)
          .findOne(where.eq('_id', id));

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
    await _dbInstance.db
        .collection(_collectionPath)
        .updateOne(where.eq('_id', userId), modify.set(field, value));
  }
}
