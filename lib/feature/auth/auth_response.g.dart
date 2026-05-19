// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  id: json['_id'] as String,
  role: (json['role'] as num).toInt(),
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'role': instance.role,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
