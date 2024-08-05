import 'package:json_annotation/json_annotation.dart';

part 'jwt.g.dart';

@JsonSerializable()
class JwtModel {
  @JsonKey(name: '_id')
  final String id;
  final String accessToken;
  final String userId;

  JwtModel({
    required this.id,
    required this.accessToken,
    required this.userId,
  });

  factory JwtModel.fromJson(Map<String, dynamic> json) =>
      _$JwtModelFromJson(json);

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);
}
