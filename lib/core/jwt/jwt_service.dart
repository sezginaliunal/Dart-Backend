import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/jwt/jwt_config.dart';
import 'package:dart_backend/core/jwt/jwt_payload.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final class JwtService {
  final RSAPrivateKey _privateKey;
  final RSAPublicKey _publicKey;

  JwtService({
    required RSAPrivateKey privateKey,
    required RSAPublicKey publicKey,
  }) : _privateKey = privateKey,
       _publicKey = publicKey;

  String generateToken(JwtPayload payload, JwtConfig config) {
    return JWT(
      payload.toMap(),
      issuer: config.issuer,
      subject: config.subject,
    ).sign(
      _privateKey,
      algorithm: config.algorithm,
      expiresIn: config.expiresIn,
    );
  }

  AppResponse<JwtPayload> verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, _publicKey);
      return AppResponse.success(
        JwtPayload.fromMap(Map<String, dynamic>.from(jwt.payload as Map)),
      );
    } on JWTExpiredException {
      return AppResponse.failure(CustomError('Token süresi dolmuş'));
    } on JWTException catch (e) {
      return AppResponse.failure(CustomError('Geçersiz token: ${e.message}'));
    }
  }
}
