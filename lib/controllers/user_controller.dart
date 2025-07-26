import 'dart:io';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/core/controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/user.dart';

class UserController extends BaseController<User> {
  UserController() : super(fromJson: User.fromJson) {
    collectionName = CollectionPath.users;
  }

  Future<ApiResponse<User?>> isUserExistByEmail(String email) =>
      findOneByField('email', email);

  Future<ApiResponse<User?>> getUserById(String id) =>
      findOneByField('_id', id);

  Future<ApiResponse<List<User>>> getUsers({
    int? page,
    int? limit,
    bool descending = false,
  }) {
    return paginate(page: page, limit: limit, descending: descending);
  }

  Future<ApiResponse<List<User>>> getUsersByUsername(
      {required String username,
      int? page,
      int? limit,
      bool descending = false}) {
    return paginateByField(
      queryField: 'username',
      value: username,
      page: page,
      limit: limit,
      sort: 'createdAt',
      descending: descending,
    );
  }

  Future<ApiResponse<List<User>>> getUsersByUsernameAndEmail({
    required String username,
    required String email,
    int? page,
    int? limit,
    bool descending = false,
  }) {
    return paginateByFields(
      queryFields: {
        'username': username,
        'email': email,
      },
      page: page,
      limit: limit,
      sort: 'email',
      descending: descending,
    );
  }

  Future<ApiResponse<bool>> updateUser(
      String userId, String field, dynamic value) async {
    try {
      final success = await updateField(userId, field, value);
      return ApiResponse(
          data: success,
          success: success,
          statusCode: success ? HttpStatus.ok : HttpStatus.notFound);
    } catch (e) {
      return ApiResponse(
          success: false,
          message: ResponseMessages.somethingError.message,
          statusCode: HttpStatus.internalServerError);
    }
  }
}
