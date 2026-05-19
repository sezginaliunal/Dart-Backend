import 'package:dart_backend/feature/user/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
final class AuthResponse {
  @JsonKey(name: '_id')
  final String id;
  final int role;

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
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
  }) {
    return AuthResponse(
      id: user.id ?? '',
      role: user.role.value,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
