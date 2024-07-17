import 'package:minersy_lite/services/auth/jwt_service.dart';
import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:minersy_lite/config/constants/collections.dart';
import 'package:minersy_lite/utils/extensions/hash_string.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';
import 'package:minersy_lite/model/user.dart';

abstract class IAuthController {
  Future<ResponseHandler> register(User user);
  Future<ResponseHandler> login(String email, String password);
}

class AuthController extends IAuthController {
  final IBaseDb _dbInstance = MongoDatabase();
  final CollectionPath collectionName = CollectionPath.users;

  @override
  Future<ResponseHandler> register(User user) async {
    final isItemExistSuccess =
        await _dbInstance.isItemExist(collectionName, 'email', user.email);
    if (!isItemExistSuccess.success) {
      final result = await _dbInstance.insertData(
          collectionName, user.id.toString(), user.toJson());
      if (result.success) {
        return ResponseHandler(
            success: true,
            message: ResponseMessage.itemAdded,
            data: result.data);
      }
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  @override
  Future<ResponseHandler> login(String email, String password) async {
    final userJson =
        await _dbInstance.fetchOneData(collectionName, 'email', email);

    if (userJson.success) {
      final user = User.fromJson(userJson.data);
      if (password.verifySha256(user.password.toString())) {
        final jwt = JwtService();
        final generateToken = await jwt.createJwt(user);

        return generateToken;
      } else {
        return ResponseHandler(message: ResponseMessage.invalidCredentials);
      }
    }
    return ResponseHandler(message: ResponseMessage.userNotFound);
  }
}
