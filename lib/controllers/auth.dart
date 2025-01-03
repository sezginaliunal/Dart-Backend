import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/extensions/validators.dart';

class AuthController {
  final MongoDatabase _dbInstance = MongoDatabase();
  final String _collectionPath = CollectionPath.users.rawValue;
  // Kayıt olma
  Future<ApiResponse<User>> register(User user) async {
    if (!user.email.isValidEmail) {
      return ApiResponse<User>(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    if (!user.password.isValidPassword) {
      return ApiResponse<User>(
        success: false,
        statusCode: HttpStatus.badRequest,
        message: ResponseMessages.invalidPassword.message,
      );
    }

    final isUserExist = await _dbInstance.db
        .collection(_collectionPath)
        .findOne(where.eq('email', user.email));

    if (isUserExist != null) {
      return ApiResponse<User>(
        success: false,
        message: ResponseMessages.existUser.message,
        statusCode: HttpStatus.conflict, // Conflict
      );
    } else {
      // Şifreyi hashleyin
      user.password = user.password.toSha256();

      await _dbInstance.db.collection(_collectionPath).insert(user.toJson());
      return ApiResponse<User>(
        message: ResponseMessages.successRegister.message,
        statusCode: HttpStatus.created,
      );
    }
  }

  //Giriş yapma
  Future<ApiResponse<void>> login(String email, String password) async {
    if (!email.isValidEmail) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    final user = await _dbInstance.db
        .collection(_collectionPath)
        .findOne(where.eq('email', email));

    if (user != null) {
      final accountStatusValue = user['accountStatus'];
      final accountStatus = _checkAccountStatus(accountStatusValue as int);

      if (accountStatus == AccountStatus.suspended ||
          accountStatus == AccountStatus.inactive) {
        return ApiResponse(
          success: false,
          message: ResponseMessages.suspendUser.message,
          statusCode: HttpStatus.badRequest,
        );
      }

      final hashedPassword = user['password'].toString();

      if (password.verifySha256(hashedPassword)) {
        return ApiResponse(
          message: ResponseMessages.successLogin.message,
          statusCode: HttpStatus.ok,
        );
      } else {
        return ApiResponse(
          success: false,
          message: ResponseMessages.wrongPassword.message,
          statusCode: HttpStatus.badRequest, // Unauthorized
        );
      }
    } else {
      return ApiResponse(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.unauthorized, // Not Found
      );
    }
  }

  AccountStatus _checkAccountStatus(int accountStatusValue) {
    final accountStatus = AccountStatus.values.firstWhere(
      (status) => status.index == accountStatusValue,
      orElse: () => AccountStatus.active,
    );
    return accountStatus;
  }
}
