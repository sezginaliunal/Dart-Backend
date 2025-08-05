import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';

class JwtService {
  factory JwtService() => _instance;
  JwtService._internal() {
    _env = Env();
  }
  static final JwtService _instance = JwtService._internal();

  late final Env _env;
  final _db = MongoDatabase();
  final String _collection = CollectionPath.token.name;

  Future<JwtModel> createJwt(User user) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final exp = now + int.parse(_env.envConfig.jwtAccessTokenExpirationSeconds);

    final jwt = JWT(
      {
        'sub': user.id,
        'name': user.email,
        'iat': now,
        'exp': exp,
      },
      issuer: _env.envConfig.jwtIssuer,
    );

    final accessToken = jwt.sign(SecretKey(_env.envConfig.jwtAccessSecretKey));

    return JwtModel(
      accessToken: accessToken,
      userId: user.id,
      id: ObjectId().oid,
    );
  }

  Future<bool> checkJwt(String token, String userId) async {
    if (token.trim().isEmpty) return false;

    try {
      final tokenData =
          await _db.db.collection(_collection).findOne({'accessToken': token});
      if (tokenData == null) return false;

      final parsedJwt = JwtModel.fromJson(tokenData);
      if (parsedJwt.userId != userId) return false;

      JWT.verify(
        parsedJwt.accessToken,
        SecretKey(_env.envConfig.jwtAccessSecretKey),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
