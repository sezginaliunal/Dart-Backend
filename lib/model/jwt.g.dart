// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtModel _$JwtModelFromJson(Map<String, dynamic> json) => JwtModel(
      accessToken: json['accessToken'] as String,
      userId: json['userId'] as String,
      id: json['_id'] as String?,
    );

Map<String, dynamic> _$JwtModelToJson(JwtModel instance) => <String, dynamic>{
      '_id': instance.id,
      'accessToken': instance.accessToken,
      'userId': instance.userId,
    };
