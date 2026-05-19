import 'package:json_annotation/json_annotation.dart';

part 'jwt_db_model.g.dart';

@JsonSerializable()
final class JwtDbModel {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final String refreshTokenHash;
  final int tokenVersion;
  final String createdAt;

  JwtDbModel({
    required this.id,
    required this.userId,
    required this.refreshTokenHash,
    required this.tokenVersion,
    required this.createdAt,
  });

  factory JwtDbModel.fromJson(Map<String, dynamic> json) =>
      _$JwtDbModelFromJson(json);

  Map<String, dynamic> toJson() => _$JwtDbModelToJson(this);
}
