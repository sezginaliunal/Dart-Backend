import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:minersy_lite/config/constants/collections.dart';
import 'package:minersy_lite/config/load_env.dart';
import 'package:minersy_lite/model/jwt.dart';
import 'package:minersy_lite/model/user.dart';
import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

class JwtService {
  static final JwtService _instance = JwtService._init();
  late final Env _env;
  final IBaseDb _db = MongoDatabase();
  JwtService._init() {
    _env = Env();
  }

  factory JwtService() => _instance;
  Future<ResponseHandler> createJwt(User user) async {
    final payload = {
      'sub': user.id,
      'name': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          int.parse(_env.envConfig.jwtExpirationSeconds)
    };

    final jwt = JWT(
      payload,
      issuer: _env.envConfig.jwtIssuer,
    );

    final secretKey = SecretKey(_env.envConfig.jwtSecretKey);
    final token = jwt.sign(secretKey);
    final jwtToken = JwtToken(
        token: token,
        userId: user.id,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        expiresAt: (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
            int.parse(_env.envConfig.jwtExpirationSeconds));
    final isUserExist =
        await _db.isItemExist(CollectionPath.tokens, 'userId', user.id);
    if (isUserExist.success) {
      await _db.updateAll(CollectionPath.tokens, 'token', jwtToken.token);
      await _db.updateAll(
          CollectionPath.tokens, 'createdAt', jwtToken.createdAt);
      await _db.updateAll(
          CollectionPath.tokens, 'expiresAt', jwtToken.expiresAt);
    } else {
      await _db.insertData(
          CollectionPath.tokens, user.id.toString(), jwtToken.toJson());
    }

    return ResponseHandler(success: true, data: token);
  }

  Future<ResponseHandler> checkJwt(String token) async {
    try {
      final isTokenExist =
          await _db.isItemExist(CollectionPath.tokens, 'token', token);
      if (isTokenExist.success) {
        final lastToken = isTokenExist.data['token'];
        JWT.verify(lastToken, SecretKey(_env.envConfig.jwtSecretKey));
        return ResponseHandler(success: true);
      } else {
        return ResponseHandler(message: ResponseMessage.tokenInvalid);
      }
    } on JWTExpiredException {
      return ResponseHandler(message: ResponseMessage.expiredToken);
    } on JWTException {
      return ResponseHandler(message: ResponseMessage.tokenInvalid);
    }
  }
}
