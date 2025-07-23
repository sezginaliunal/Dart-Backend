import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/controllers/auditlog_controller.dart';
import 'package:project_base/model/audit_log.dart';
import 'package:project_base/model/jwt.dart';
import 'package:project_base/model/user.dart';
import 'package:project_base/services/db/db.dart';

class JwtService {
  factory JwtService() => _instance;

  JwtService._init() {
    _env = Env();
  }
  static final JwtService _instance = JwtService._init();
  late final Env _env;
  final MongoDatabase _db = MongoDatabase();
  final String _collectionPath = CollectionPath.token.name;

  Future<JwtModel> createJwt(User user) async {
    // Log JWT oluşturma girişimi
    await AuditLogController().insertLog(
      AuditLog(
        id: await _db.getNextStringSequenceId(CollectionPath.audit_log.name),
        createdAt: DateTime.now(),
        createdBy: user.email,
        collection: _collectionPath,
        message: 'Creating JWT for user: ${user.id}',
      ),
    );

    final payloadAccessToken = {
      'sub': user.id,
      'name': user.email,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) +
          int.parse(_env.envConfig.jwtAccessTokenExpirationSeconds),
    };

    final jwtAccess = JWT(payloadAccessToken, issuer: _env.envConfig.jwtIssuer);

    final accessSecretKey = SecretKey(_env.envConfig.jwtAccessSecretKey);
    final accessToken = jwtAccess.sign(accessSecretKey);

    final jwtModel = JwtModel(
      accessToken: accessToken,
      userId: user.id,
      id: await _db.getNextStringSequenceId(CollectionPath.token.name),
    );

    // Log JWT oluşturma başarı durumu
    await AuditLogController().insertLog(
      AuditLog(
        id: await _db.getNextStringSequenceId(CollectionPath.audit_log.name),
        createdAt: DateTime.now(),
        createdBy: user.email,
        collection: _collectionPath,
        message: 'JWT created successfully for user: ${user.id}',
      ),
    );

    return jwtModel;
  }

  Future<bool> checkJwt(String token, String userId) async {
    final now = DateTime.now();

    Future<void> log(String message, LogLevel level) async {
      await AuditLogController().insertLog(
        AuditLog(
          id: await _db.getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: now,
          createdBy: userId,
          collection: _collectionPath,
          message: message,
          level: level,
        ),
      );
    }

    await log('Checking JWT for user: $userId', LogLevel.info);

    if (token.trim().isEmpty) {
      await log(
        'JWT is empty or malformed for user: $userId',
        LogLevel.warning,
      );
      return false;
    }

    try {
      final tokenData = await _db.db
          .collection(_collectionPath)
          .findOne(where.eq('accessToken', token));

      if (tokenData == null) {
        await log(
          'JWT not found in database for user: $userId',
          LogLevel.warning,
        );
        return false;
      }

      final parsedJwt = JwtModel.fromJson(tokenData);

      if (parsedJwt.userId != userId) {
        await log(
          'JWT validation failed: User ID mismatch for user: $userId',
          LogLevel.warning,
        );
        return false;
      }

      // Token doğrulaması
      JWT.verify(
        parsedJwt.accessToken,
        SecretKey(_env.envConfig.jwtAccessSecretKey),
      );

      await log('JWT validated successfully for user: $userId', LogLevel.info);
      return true;
    } on JWTExpiredException {
      await log('JWT has expired for user: $userId', LogLevel.warning);
      return false;
    } on JWTInvalidException {
      await log(
        'JWT is invalid (tampered or malformed) for user: $userId',
        LogLevel.error,
      );
      return false;
    } on JWTException catch (e) {
      await log(
        'General JWT exception: ${e.message} for user: $userId',
        LogLevel.error,
      );
      return false;
    } on FormatException {
      await log('JWT format error for user: $userId', LogLevel.error);
      return false;
    } catch (e) {
      await log(
        'Unknown error during JWT validation for user: $userId — $e',
        LogLevel.error,
      );
      return false;
    }
  }
}
