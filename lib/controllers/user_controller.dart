import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/core/controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/extensions/validators.dart';

class UserController extends MyController {
  UserController() {
    collectionName = CollectionPath.users;
  }
  Future<ApiResponse<User?>> isUserExistByEmail(String email) async {
    try {
      final result = await db
          .getCollection(collectionName.name)
          .findOne(where.eq('email', email));
      if (result != null) {
        final user = User.fromJson(result);

        return ApiResponse(data: user);
      } else {
        return ApiResponse(
          success: false,
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } on Exception catch (_) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  Future<ApiResponse<User?>> isUserExist(String id) async {
    try {
      final result = await db
          .getCollection(collectionName.name)
          .findOne(where.eq('_id', id));
      if (result != null) {
        final user = User.fromJson(result);

        return ApiResponse(data: user);
      } else {
        return ApiResponse(
          success: false,
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } on Exception catch (_) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  // Kullanıcıyı ID ile getirme
  Future<ApiResponse<User?>> getUserById(String id) async {
    try {
      final result = await db
          .getCollection(collectionName.name)
          .findOne(where.eq('_id', id));

      if (result != null) {
        final user = User.fromJson(result);

        return ApiResponse(data: user);
      } else {
        return ApiResponse(
          success: false,
          message: ResponseMessages.userNotFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  // Kullanıcıyı güncelleme
  Future<ApiResponse<bool>> updateUser(
    String userId,
    String field,
    dynamic value,
  ) async {
    try {
      final result = await db
          .getCollection(collectionName.name)
          .updateOne(where.eq('_id', userId), modify.set(field, value));
      if (result.nModified > 0) {
        return ApiResponse(
          data: true,
        );
      } else {
        return ApiResponse(
          statusCode: HttpStatus.notFound,
          success: false,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  //Şifre güncelleme
  Future<ApiResponse<bool>> updatePassword(
    String userId,
    String value,
  ) async {
    try {
      if (!value.isValidPassword) {
        return ApiResponse<bool>(
          success: false,
          statusCode: HttpStatus.badRequest,
          message: ResponseMessages.invalidPassword.message,
        );
      }
      final result = await db.getCollection(collectionName.name).updateOne(
            where.eq('_id', userId),
            modify.set(
              'password',
              value.toSha256(),
            ),
          );
      if (result.nModified > 0) {
        return ApiResponse(
          data: true,
        );
      } else {
        return ApiResponse(
          statusCode: HttpStatus.notFound,
          success: false,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<User>>> getUsers(
    int page,
    int limit, {
    required bool descending,
  }) async {
    try {
      final result = await db.paginateData(
        collectionName.name,
        page: page,
        limit: limit,
        descending: descending,
        fromJson: User.fromJson,
      );

      return result;
    } on Exception catch (_) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }
}
