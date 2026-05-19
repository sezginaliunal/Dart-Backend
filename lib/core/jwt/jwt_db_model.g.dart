// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_db_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtDbModel _$JwtDbModelFromJson(Map<String, dynamic> json) => JwtDbModel(
  id: json['_id'] as String,
  userId: json['userId'] as String,
  refreshTokenHash: json['refreshTokenHash'] as String,
  tokenVersion: (json['tokenVersion'] as num).toInt(),
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$JwtDbModelToJson(JwtDbModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'refreshTokenHash': instance.refreshTokenHash,
      'tokenVersion': instance.tokenVersion,
      'createdAt': instance.createdAt,
    };
