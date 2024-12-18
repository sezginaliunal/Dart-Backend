import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/auditlog_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/audit_log.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/extensions/validators.dart';

class AuthController {
  final MongoDatabase db = MongoDatabase();
  final String _collectionPath = CollectionPath.users.name;

  // Kayıt olma
  Future<ApiResponse<User>> register(User user) async {
    if (!user.email.isValidEmail) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: _collectionPath,
          message: '${user.email} - ${ResponseMessages.invalidEmail.message}',
          level: LogLevel.error,
        ),
      );
      return ApiResponse<User>(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    if (!user.password.isValidPassword) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: _collectionPath,
          message:
              '${user.email} - ${ResponseMessages.invalidPassword.message}',
          level: LogLevel.error,
        ),
      );

      return ApiResponse<User>(
        success: false,
        statusCode: HttpStatus.badRequest,
        message: ResponseMessages.invalidPassword.message,
      );
    }

    final isUserExist = await db
        .getCollection(_collectionPath)
        .findOne(where.eq('email', user.email));

    if (isUserExist != null) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: _collectionPath,
          message: '${user.email} - ${ResponseMessages.existUser.message}',
          level: LogLevel.warning,
        ),
      );
      return ApiResponse<User>(
        success: false,
        message: ResponseMessages.existUser.message,
        statusCode: HttpStatus.conflict,
      );
    } else {
      user.password = user.password.toSha256(); // Salt eklenebilir

      try {
        await db.getCollection(_collectionPath).insert(user.toJson());
        await AuditLogController().insertLog(
          AuditLog(
            collection: _collectionPath,
            message:
                '${user.email} - ${ResponseMessages.successRegister.message}',
          ),
        );
        return ApiResponse<User>(
          message: ResponseMessages.successRegister.message,
          statusCode: HttpStatus.created,
        );
      } catch (e) {
        await AuditLogController().insertLog(
          AuditLog(
            collection: _collectionPath,
            message: '${user.email} - Database error: $e',
            level: LogLevel.error,
          ),
        );
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
      await AuditLogController().insertLog(
        AuditLog(
          collection: _collectionPath,
          message: '$email - ${ResponseMessages.invalidEmail.message}',
          level: LogLevel.error,
        ),
      );
      return ApiResponse(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    final user = await db
        .getCollection(_collectionPath)
        .findOne(where.eq('email', email));

    if (user != null) {
      final accountStatusValue = user['accountStatus'];
      final accountStatus =
          User.checkAccountStatus(accountStatusValue as String);

      if (accountStatus != AccountStatus.active) {
        await AuditLogController().insertLog(
          AuditLog(
            collection: _collectionPath,
            message: '$email - ${accountStatus.name}',
            level: LogLevel.warning,
          ),
        );
        return ApiResponse(
          success: false,
          message: ResponseMessages.unauthorized.message,
          statusCode: HttpStatus.badRequest,
        );
      }

      final hashedPassword = user['password'].toString();

      if (password.verifySha256(hashedPassword)) {
        await AuditLogController().insertLog(
          AuditLog(
            collection: _collectionPath,
            message: '$email - ${ResponseMessages.successLogin.message}',
          ),
        );
        final parseUser = User.fromJson(user);
        return ApiResponse(
          data: parseUser,
          message: ResponseMessages.successLogin.message,
          statusCode: HttpStatus.ok,
        );
      } else {
        await AuditLogController().insertLog(
          AuditLog(
            collection: _collectionPath,
            message: '$email - ${ResponseMessages.wrongPassword.message}',
            level: LogLevel.error,
          ),
        );
        return ApiResponse(
          success: false,
          message: ResponseMessages.wrongPassword.message,
          statusCode: HttpStatus.badRequest, // Unauthorized
        );
      }
    } else {
      await AuditLogController().insertLog(
        AuditLog(
          collection: _collectionPath,
          message: '$email - ${ResponseMessages.userNotFound.message}',
          level: LogLevel.warning,
        ),
      );
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
