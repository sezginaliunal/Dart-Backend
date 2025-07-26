import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'jwt.g.dart';

@JsonSerializable()
class JwtModel {
  JwtModel({
    required this.accessToken,
    required this.userId,
    required this.id,
  });

  factory JwtModel.fromJson(Map<String, dynamic> json) =>
      _$JwtModelFromJson(json);
  @JsonKey(name: '_id')
  final String id;
  final String accessToken;
  final String userId;

  Map<String, dynamic> toJson() => _$JwtModelToJson(this);
}
