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

    final jwtAccess = JWT(
      payloadAccessToken,
      issuer: _env.envConfig.jwtIssuer,
    );

    final accessSecretKey = SecretKey(_env.envConfig.jwtAccessSecretKey);
    final accessToken = jwtAccess.sign(accessSecretKey);

    final jwtModel = JwtModel(
      accessToken: accessToken,
      userId: user.id,
    );

    // Log JWT oluşturma başarı durumu
    await AuditLogController().insertLog(
      AuditLog(
        createdBy: user.email,
        collection: _collectionPath,
        message: 'JWT created successfully for user: ${user.id}',
      ),
    );

    return jwtModel;
  }

  Future<bool> checkJwt(String token, String userId) async {
    // Log JWT kontrolü girişimi
    await AuditLogController().insertLog(
      AuditLog(
        createdBy: userId,
        collection: _collectionPath,
        message: 'Checking JWT for user: $userId',
      ),
    );

    try {
      final isTokenExist = await _db.db
          .collection(CollectionPath.token.name)
          .findOne(where.eq('accessToken', token));

      if (isTokenExist != null) {
        final parsedJwt = JwtModel.fromJson(isTokenExist);

        if (parsedJwt.userId != userId) {
          // Log: Kullanıcı ID eşleşmiyor
          await AuditLogController().insertLog(
            AuditLog(
              createdBy: userId,
              collection: _collectionPath,
              message:
                  'JWT validation failed: User ID mismatch for user: $userId',
              level: LogLevel.warning,
            ),
          );
          return false;
        }

        // JWT doğrulama
        JWT.verify(
          parsedJwt.accessToken,
          SecretKey(_env.envConfig.jwtAccessSecretKey),
        );

        // Log: Başarılı doğrulama
        await AuditLogController().insertLog(
          AuditLog(
            createdBy: userId,
            collection: _collectionPath,
            message: 'JWT validated successfully for user: $userId',
          ),
        );
        return true;
      }

      // Log: JWT bulunamadı
      await AuditLogController().insertLog(
        AuditLog(
          createdBy: userId,
          collection: _collectionPath,
          message: 'JWT not found for user: $userId',
          level: LogLevel.warning,
        ),
      );
      return false;
    } on JWTExpiredException {
      // Log: JWT süresi dolmuş
      await AuditLogController().insertLog(
        AuditLog(
          createdBy: userId,
          collection: _collectionPath,
          message: 'JWT expired for user: $userId',
          level: LogLevel.warning,
        ),
      );
      return false;
    } on JWTException {
      // Log: JWT hatası
      await AuditLogController().insertLog(
        AuditLog(
          createdBy: userId,
          collection: _collectionPath,
          message: 'JWT validation error for user: $userId',
          level: LogLevel.error,
        ),
      );
      return false;
    }
  }
}
