// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtToken _$JwtTokenFromJson(Map<String, dynamic> json) => JwtToken(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      token: json['token'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      expiresAt: (json['expiresAt'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JwtTokenToJson(JwtToken instance) => <String, dynamic>{
      '_id': Uuid().v4(),
      'userId': instance.userId,
      'token': instance.token,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
    };
