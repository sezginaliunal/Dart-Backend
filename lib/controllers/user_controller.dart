import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';

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
      return ApiResponse(success: true, data: user);
    } else {
      return ApiResponse(
          data: null,
          message: 'Kullanıcı bulunamadı',
          statusCode: HttpStatus.notFound);
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
        return ApiResponse(success: true, data: user);
      } else {
        return ApiResponse(
            data: null,
            message: 'Kullanıcı bulunamadı',
            statusCode: HttpStatus.notFound);
      }
    } catch (e) {
      return ApiResponse(
          data: null,
          message: 'Bir hata oluştu: ${e.toString()}',
          statusCode: HttpStatus.internalServerError);
    }
  }

  Future<void> updateUser(String userId, String field, dynamic value) async {
    await _dbInstance.db
        .collection(_collectionPath)
        .updateOne(where.eq('_id', userId), modify.set(field, value));
  }
}
