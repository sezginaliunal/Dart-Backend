import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/extensions/validators.dart';

class AuthController {
  final MongoDatabase _dbInstance = MongoDatabase();
  final String _collectionPath = CollectionPath.users.rawValue;
  Future<ApiResponse<User>> register(User user) async {
    if (!user.email.isValidEmail) {
      return ApiResponse<User>(
          success: false,
          message: 'Geçersiz email formatı',
          statusCode: HttpStatus.badRequest // Bad Request
          );
    }

    if (!user.password.isValidPassword) {
      return ApiResponse<User>(
          success: false,
          message:
              'Şifre en az 8 karakter uzunluğunda ve bir harf ile bir rakam içermelidir',
          statusCode: HttpStatus.badRequest // Bad Request
          );
    }

    final isUserExist = await _dbInstance.db
        .collection(_collectionPath)
        .findOne(where.eq('email', user.email));

    if (isUserExist != null) {
      return ApiResponse<User>(
        success: false,
        message: 'Bu emaile kayıtlı kullanıcı var',
        statusCode: HttpStatus.conflict, // Conflict
      );
    } else {
      // Şifreyi hashleyin
      user.password = user.password.toSha256();

      await _dbInstance.db.collection(_collectionPath).insert(user.toJson());
      return ApiResponse<User>(
          message: 'Kullanıcı kayıt oldu', statusCode: HttpStatus.created);
    }
  }

  Future<ApiResponse> login(String email, String password) async {
    if (!email.isValidEmail) {
      return ApiResponse(
          success: false,
          message: 'Geçersiz email formatı',
          statusCode: HttpStatus.badRequest);
    }

    final user = await _dbInstance.db
        .collection(_collectionPath)
        .findOne(where.eq('email', email));

    if (user != null) {
      final accountStatus = user['accountStatus'] as String;

      if (accountStatus == AccountStatus.suspended.name ||
          accountStatus == AccountStatus.inactive.name) {
        return ApiResponse(
          success: false,
          message: 'Hesap şüpheli veya aktif değil',
          statusCode: HttpStatus.badRequest,
        );
      }

      final hashedPassword = user['password'] as String;

      if (password.verifySha256(hashedPassword)) {
        return ApiResponse(
          success: true,
          message: 'Giriş başarılı',
          statusCode: HttpStatus.ok,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Şifre yanlış',
          statusCode: HttpStatus.badRequest, // Unauthorized
        );
      }
    } else {
      return ApiResponse(
        success: false,
        message: 'Kullanıcı bulunamadı',
        statusCode: HttpStatus.notFound, // Not Found
      );
    }
  }

  Future<void> replaceTokenInDb(JwtModel jwt) async {
    await _dbInstance.db
        .collection(CollectionPath.token.rawValue)
        .remove(where.eq('userId', jwt.userId));

    await _dbInstance.db
        .collection(CollectionPath.token.rawValue)
        .insert(jwt.toJson());
  }

  Future<ApiResponse> logout(String accessToken) async {
    await _dbInstance.db
        .collection(CollectionPath.token.rawValue)
        .deleteOne(where.eq('accessToken', accessToken));
    return ApiResponse(
        success: true, message: 'Çıkış yapıldı', statusCode: HttpStatus.ok);
  }
}
