import 'dart:io';
import 'package:hali_saha/utils/enums/account.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:hali_saha/config/constants/collections.dart';
import 'package:hali_saha/config/constants/response_messages.dart';
import 'package:hali_saha/core/controller.dart';
import 'package:hali_saha/model/api_response.dart';
import 'package:hali_saha/model/jwt.dart';
import 'package:hali_saha/model/user.dart';
import 'package:hali_saha/utils/extensions/hash_string.dart';
import 'package:hali_saha/utils/extensions/validators.dart';

class AuthController extends MyController {
  AuthController() {
    collectionName = CollectionPath.users;
  }
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

    final isUserExist = await db
        .getCollection(collectionName.name)
        .findOne(where.eq('email', user.email));

    if (isUserExist != null) {
      return ApiResponse<User>(
        success: false,
        message: ResponseMessages.existUser.message,
        statusCode: HttpStatus.conflict,
      );
    } else {
      user.password = user.password.toSha256(); // Salt eklenebilir

      try {
        await db.getCollection(collectionName.name).insert(user.toJson());

        return ApiResponse<User>(
          message: ResponseMessages.successRegister.message,
          statusCode: HttpStatus.created,
        );
      } catch (e) {
        return ApiResponse<User>(
          success: false,
          message: 'Database error: $e',
          statusCode: HttpStatus.internalServerError,
        );
      }
    }
  }

  // Giriş yapma
  Future<ApiResponse<User>> login(String email, String password) async {
    if (!email.isValidEmail) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    final user = await db
        .getCollection(collectionName.name)
        .findOne(where.eq('email', email));

    if (user != null) {
      final accountStatusValue = user['accountStatus'];
      final accountStatus = checkAccountStatus(accountStatusValue as int);

      if (accountStatus != AccountStatus.active) {
        return ApiResponse(
          success: false,
          message: ResponseMessages.unauthorized.message,
          statusCode: HttpStatus.badRequest,
        );
      }

      final hashedPassword = user['password'].toString();

      if (password.verifySha256(hashedPassword)) {
        final parseUser = User.fromJson(user);
        return ApiResponse(
          data: parseUser,
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

  Future<void> replaceTokenInDb(JwtModel jwt) async {
    await db
        .getCollection(CollectionPath.token.name)
        .remove(where.eq('userId', jwt.userId));

    await db.getCollection(CollectionPath.token.name).insert(jwt.toJson());
  }
}
