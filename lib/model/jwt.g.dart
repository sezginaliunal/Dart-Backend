// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtModel _$JwtModelFromJson(Map<String, dynamic> json) => JwtModel(
      id: json['_id'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$JwtModelToJson(JwtModel instance) => <String, dynamic>{
      '_id': instance.id,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'userId': instance.userId,
    };
