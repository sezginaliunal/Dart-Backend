import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:minersy_lite/config/load_env.dart';
import 'package:minersy_lite/model/user.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

class JwtService {
  static final JwtService _instance = JwtService._init();
  late final Env _env;
  JwtService._init() {
    _env = Env();
  }

  factory JwtService() => _instance;

  Future<ResponseHandler> createJwt(User user) async {
    final payload = {
      'sub': user.id,
      'name': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          int.parse(_env.envConfig.jwtExpirationSeconds),
    };

    final jwt = JWT(
      payload,
      issuer: _env.envConfig.jwtIssuer,
    );

    final secretKey = SecretKey(_env.envConfig.jwtSecretKey);
    final token = jwt.sign(secretKey);

    return ResponseHandler(
        success: true, data: token, message: ResponseMessage.userLogin);
  }

  Future<ResponseHandler> checkJwt(String token) async {
    try {
      JWT.verify(token, SecretKey(_env.envConfig.jwtSecretKey));

      return ResponseHandler(success: true);
    } on JWTExpiredException {
      return ResponseHandler(message: ResponseMessage.expiredToken);
    } on JWTException {
      return ResponseHandler(message: ResponseMessage.tokenInvalid);
    }
  }
}
