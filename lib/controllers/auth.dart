import 'dart:io';
import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/utils/enums/account.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/core/controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/utils/extensions/hash_string.dart';
import 'package:project_base/utils/extensions/validators.dart';

class AuthController extends BaseController<User> {
  AuthController()
      : super(collectionPath: CollectionPath.users, fromJson: User.fromJson);

  final _userController = UserController();
  // Kayıt olma
  Future<ApiResponse<User>> register(User user) async {
    if (!user.email.isValidEmail) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.invalidEmail.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    if (!user.password.isValidPassword) {
      return ApiResponse(
        success: false,
        statusCode: HttpStatus.badRequest,
        message: ResponseMessages.invalidPassword.message,
      );
    }

    final existingUserResponse =
        await _userController.findUserByField('email', user.email);

    if (existingUserResponse.data != null) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.existUser.message,
        statusCode: HttpStatus.conflict,
      );
    }

    user.password = user.password.toSha256();

    await _userController.insertUser(user);
    return ApiResponse(
      message: ResponseMessages.successRegister.message,
      statusCode: HttpStatus.created,
    );
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

    final userResponse = await _userController.findUserByField('email', email);

    if (userResponse.data == null) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.userNotFound.message,
        statusCode: HttpStatus.notFound,
      );
    }

    final userJson = userResponse.data;

    final accountStatus = checkAccountStatus(userJson!.accountStatus);

    if (accountStatus != AccountStatus.active) {
      final message = {
        AccountStatus.banned: ResponseMessages.accountBanned.message,
        AccountStatus.suspended: ResponseMessages.accountSuspended.message,
        AccountStatus.deleted: ResponseMessages.accountInactive.message,
        AccountStatus.inactive: ResponseMessages.accountInactive.message,
      }[accountStatus];

      return ApiResponse(
        success: false,
        message: message,
        statusCode: HttpStatus.badRequest,
      );
    }

    if (!password.verifySha256(userJson.password)) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.wrongPassword.message,
        statusCode: HttpStatus.badRequest,
      );
    }

    return ApiResponse(
      data: userJson,
      message: ResponseMessages.successLogin.message,
      statusCode: HttpStatus.ok,
    );
  }

  Future<void> replaceTokenInDb(JwtModel jwt) async {
    await db
        .getCollection(CollectionPath.token.name)
        .remove(where.eq('userId', jwt.userId));
    await db.getCollection(CollectionPath.token.name).insert(jwt.toJson());
  }
}
