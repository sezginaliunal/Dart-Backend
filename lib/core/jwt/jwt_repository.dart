import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/jwt/jwt_collection.dart';
import 'package:dart_backend/core/jwt/jwt_payload.dart';
import 'package:dart_backend/feature/auth/auth_response.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class JwtRepository {
  final JwtCollection _collection;

  JwtRepository(this._collection);

  Future<AppResponse<AuthResponse>> generateToken(User user) {
    return _collection.create(user);
  }

  /// JWT imzasını doğrular (DB'ye gitmez). tokenVersion kontrolü için
  /// kullanıcı verisi ile karşılaştırma route handler'ında yapılır.
  AppResponse<JwtPayload> verifyToken(String token) {
    return _collection.verifyToken(token);
  }

  Future<AppResponse<AuthResponse>> refreshToken(
    String refreshToken,
    User user,
  ) {
    return _collection.refresh(refreshToken, user);
  }

  Future<AppResponse<bool>> deleteToken(ObjectId userId) {
    return _collection.deleteByUserId(userId);
  }
}
