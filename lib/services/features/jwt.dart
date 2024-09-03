import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:uuid/uuid.dart';

class JwtService {
  factory JwtService() => _instance;

  JwtService._init() {
    _env = Env();
  }
  static final JwtService _instance = JwtService._init();
  late final Env _env;
  final MongoDatabase _db = MongoDatabase();

  Future<JwtModel> createJwt(User user) async {
    final payloadAccessToken = {
      'sub': user.id,
      'name': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          int.parse(_env.envConfig.jwtAccessTokenExpirationSeconds),
    };
    final payloadRefreshToken = {
      'sub': user.id,
      'name': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          int.parse(_env.envConfig.jwtRefreshTokenExpirationSeconds),
    };

    final jwtAccess = JWT(
      payloadAccessToken,
      issuer: _env.envConfig.jwtIssuer,
    );
    final jwtRefresh = JWT(
      payloadRefreshToken,
      issuer: _env.envConfig.jwtIssuer,
    );
    final accessSecretKey = SecretKey(_env.envConfig.jwtAccessSecretKey);
    final accessToken = jwtAccess.sign(accessSecretKey);
    //Refresh token scretkey

    final refreshSecretKey = SecretKey(_env.envConfig.jwtRefreshSecretKey);
    //Refresh token sign
    final refreshToken = jwtRefresh.sign(refreshSecretKey);

    final jwtModel = JwtModel(
      id: const Uuid().v4(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id,
    );

    return jwtModel;
  }

  Future<bool> checkJwt(String token, String userId) async {
    try {
      final isTokenExist = await _db.db
          .collection(CollectionPath.token.rawValue)
          .findOne(where.eq('accessToken', token));

      if (isTokenExist != null) {
        final parsedJwt = JwtModel.fromJson(isTokenExist);

        if (parsedJwt.userId != userId) {
          return false;
        }

        JWT.verify(
          parsedJwt.accessToken,
          SecretKey(_env.envConfig.jwtAccessSecretKey),
        );
        return true;
      }

      return false;
    } on JWTExpiredException {
      // Burada uygun bir loglama yapılabilir
      return false;
    } on JWTException {
      // Burada uygun bir loglama yapılabilir
      return false;
    }
  }
}
