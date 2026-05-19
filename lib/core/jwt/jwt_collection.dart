import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/jwt/jwt_config.dart';
import 'package:dart_backend/core/jwt/jwt_db_model.dart';
import 'package:dart_backend/core/jwt/jwt_payload.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/core/mongo/mongo_collection.dart';
import 'package:dart_backend/feature/auth/auth_response.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class JwtCollection extends MongoCollection {
  final JwtService _jwtService;

  JwtCollection(Db db, this._jwtService) : super(db, 'tokens');

  String _hashToken(String token) {
    return sha256.convert(utf8.encode(token)).toString();
  }

  Future<AppResponse<AuthResponse>> create(User user) async {
    final payload = JwtPayload.fromUser(user);

    final accessToken = _jwtService.generateToken(payload, JwtConfig.access);
    final refreshToken = _jwtService.generateToken(payload, JwtConfig.refresh);

    // Kullanıcının eski token'larını temizle
    await deleteMany({'userId': user.id});
    final jwtDbModel = JwtDbModel(
      id: ObjectId().oid,
      userId: user.id!,
      refreshTokenHash: _hashToken(refreshToken),
      tokenVersion: user.tokenVersion,
      createdAt: DateTime.now().toIso8601String(),
    );
    await insertOne(jwtDbModel.toJson());

    return AppResponse.success(
      AuthResponse.fromUser(
        user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  /// Sadece JWT imzasını doğrular — DB'ye gitmez.
  AppResponse<JwtPayload> verifyToken(String token) {
    return _jwtService.verifyToken(token);
  }

  Future<AppResponse<AuthResponse>> refresh(
    String refreshToken,
    User user,
  ) async {
    final tokenHash = _hashToken(refreshToken);
    final dbRes = await findOne({'refreshTokenHash': tokenHash});
    if (dbRes == null) {
      return AppResponse.failure(const NotFoundError());
    }

    // DB'deki tokenVersion ile kullanıcının güncel tokenVersion'ını karşılaştır
    final storedVersion = dbRes['tokenVersion'] as int? ?? 0;
    if (storedVersion != user.tokenVersion) {
      // Şifre veya status değişmiş — bu token artık geçersiz
      await deleteOne({'refreshTokenHash': tokenHash});
      return AppResponse.failure(
        const CustomError('Token geçersiz. Lütfen tekrar giriş yapın.'),
      );
    }

    final verifyResult = _jwtService.verifyToken(refreshToken);
    if (verifyResult.isFailure) {
      await deleteOne({'refreshTokenHash': tokenHash});
      return AppResponse.failure(verifyResult.error!);
    }

    // Payload'daki tokenVersion da kontrol et
    final payload = verifyResult.data!;
    if (payload.tokenVersion != user.tokenVersion) {
      await deleteOne({'refreshTokenHash': tokenHash});
      return AppResponse.failure(
        const CustomError('Token geçersiz. Lütfen tekrar giriş yapın.'),
      );
    }

    await deleteOne({'refreshTokenHash': tokenHash});
    return create(user);
  }

  Future<AppResponse<bool>> deleteByUserId(String userId) async {
    final res = await deleteMany({'userId': userId});
    return AppResponse.success(res.nRemoved > 0);
  }
}
