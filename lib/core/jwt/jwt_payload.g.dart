// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtPayload _$JwtPayloadFromJson(Map<String, dynamic> json) => JwtPayload(
  id: json['_id'] as String,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  tokenVersion: (json['tokenVersion'] as num).toInt(),
);

Map<String, dynamic> _$JwtPayloadToJson(JwtPayload instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'role': _$UserRoleEnumMap[instance.role]!,
      'tokenVersion': instance.tokenVersion,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 1,
  UserRole.moderator: 2,
  UserRole.customer: 3,
  UserRole.guest: 4,
};
