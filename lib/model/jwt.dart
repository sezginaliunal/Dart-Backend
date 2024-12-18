import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'jwt.g.dart';

@JsonSerializable()
class JwtModel {
  JwtModel({
    required this.accessToken,
    required this.userId,
    this.id,
  });

  factory JwtModel.fromJson(Map<String, dynamic> json) =>
      _$JwtModelFromJson(json);
  @JsonKey(name: '_id')
  final String? id;
  final String accessToken;
  final String userId;

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);
}
