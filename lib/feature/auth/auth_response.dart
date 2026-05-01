import 'package:dart_backend/feature/user/models/user.dart';

final class AuthResponse {
  final String id; // ✅ Client'a string gönderilir
  final int role;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.id,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromUser(
    User user, {
    required String accessToken,
    required String refreshToken,
  }) => AuthResponse(
    id: user.id.toHexString(), // ✅ ObjectId → hex string
    role: user.role.value,
    accessToken: accessToken,
    refreshToken: refreshToken,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}
