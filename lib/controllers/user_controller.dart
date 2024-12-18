import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/auditlog_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/audit_log.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';

class UserController {
  final db = MongoDatabase();
  final collectionName = CollectionPath.users.name;

  // Kullanıcıyı e-posta ile kontrol etme
  Future<ApiResponse<User?>> isUserExist(String id) async {
    await AuditLogController().insertLog(
      AuditLog(
        collection: collectionName,
        message: 'Checking if user exists with ID: $id',
      ),
    );

    try {
      final result =
          await db.getCollection(collectionName).findOne(where.eq('_id', id));
      if (result != null) {
        final user = User.fromJson(result);
        await AuditLogController().insertLog(
          AuditLog(
            collection: collectionName,
            message: 'User exists with ID: $id',
          ),
        );
        return ApiResponse(data: user);
      } else {
        return ApiResponse(
          success: false,
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: collectionName,
          message: 'Error checking user with ID: $id - $e',
          level: LogLevel.error,
        ),
      );
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  // Kullanıcıyı ID ile getirme
  Future<ApiResponse<User?>> getUserById(String id) async {
    await AuditLogController().insertLog(
      AuditLog(
        collection: collectionName,
        message: 'Fetching user with ID: $id',
      ),
    );

    try {
      final result =
          await db.getCollection(collectionName).findOne(where.eq('_id', id));

      if (result != null) {
        final user = User.fromJson(result);
        await AuditLogController().insertLog(
          AuditLog(
            collection: collectionName,
            message: 'Successfully fetched user with ID: $id',
          ),
        );
        return ApiResponse(data: user);
      } else {
        await AuditLogController().insertLog(
          AuditLog(
            collection: collectionName,
            message: 'User not found with ID: $id',
            level: LogLevel.warning,
          ),
        );
        return ApiResponse(
          success: false,
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: collectionName,
          message: 'Error fetching user with ID: $id - $e',
          level: LogLevel.error,
        ),
      );
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  // Kullanıcıyı güncelleme
  Future<void> updateUser(String userId, String field, dynamic value) async {
    await AuditLogController().insertLog(
      AuditLog(
        collection: collectionName,
        message:
            'Attempting to update user: $userId - Field: $field, Value: $value',
      ),
    );

    try {
      await db
          .getCollection(collectionName)
          .updateOne(where.eq('_id', userId), modify.set(field, value));

      await AuditLogController().insertLog(
        AuditLog(
          collection: collectionName,
          message: 'Successfully updated user: $userId - Field: $field',
        ),
      );
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: collectionName,
          message: 'Error updating user: $userId - Field: $field, Error: $e',
          level: LogLevel.error,
        ),
      );
      rethrow;
    }
  }
}
