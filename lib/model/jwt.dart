import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
part 'jwt.g.dart';

@JsonSerializable()
class JwtToken {
  String? id;
  String? userId;
  String? token;
  int? createdAt;
  int? expiresAt;

  JwtToken({
    this.id,
    this.userId,
    this.token,
    this.createdAt,
    this.expiresAt,
  });

  factory JwtToken.fromJson(Map<String, dynamic> json) =>
      _$JwtTokenFromJson(json);

  Map<String, dynamic> toJson() => _$JwtTokenToJson(this);

  JwtToken copyWith({
    String? userId,
    String? token,
    int? createdAt,
    int? expiresAt,
  }) {
    return JwtToken(
      id: id ?? id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
