import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:json_annotation/json_annotation.dart';
part 'jwt_payload.g.dart';

@JsonSerializable()
final class JwtPayload {
  @JsonKey(name: '_id')
  final String id;

  final UserRole role;

  /// DB'deki tokenVersion ile eşleşmezse token geçersiz sayılır.
  final int tokenVersion;

  const JwtPayload({
    required this.id,
    required this.role,
    required this.tokenVersion,
  });

  factory JwtPayload.fromUser(User user) => JwtPayload(
    id: user.id ?? '',
    role: user.role,
    tokenVersion: user.tokenVersion,
  );

  factory JwtPayload.fromJson(Map<String, dynamic> json) =>
      _$JwtPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$JwtPayloadToJson(this);
}
