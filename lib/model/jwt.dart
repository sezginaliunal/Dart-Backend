import 'package:json_annotation/json_annotation.dart';

part 'jwt.g.dart';

@JsonSerializable()
class JwtModel {
  JwtModel({
    required this.id,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
  });

  factory JwtModel.fromJson(Map<String, dynamic> json) =>
      _$JwtModelFromJson(json);
  @JsonKey(name: '_id')
  final String id;
  final String accessToken;
  final String refreshToken;
  final String userId;

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);
}
