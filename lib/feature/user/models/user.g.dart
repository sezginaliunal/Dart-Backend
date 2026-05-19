// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String?,
  name: json['name'] as String,
  authType:
      $enumDecodeNullable(_$AuthTypeEnumMap, json['authType']) ??
      AuthType.email,
  status:
      $enumDecodeNullable(_$UserStatusEnumMap, json['status']) ??
      UserStatus.active,
  role:
      $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.customer,
  passwordHash: json['passwordHash'] as String?,
  providerUid: json['providerUid'] as String?,
  tokenVersion: (json['tokenVersion'] as num?)?.toInt() ?? 0,
  avatarPath: json['avatarPath'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'status': _$UserStatusEnumMap[instance.status]!,
  'role': _$UserRoleEnumMap[instance.role]!,
  'authType': _$AuthTypeEnumMap[instance.authType]!,
  'passwordHash': instance.passwordHash,
  'providerUid': instance.providerUid,
  'tokenVersion': instance.tokenVersion,
  'avatarPath': instance.avatarPath,
};

const _$AuthTypeEnumMap = {
  AuthType.email: 1,
  AuthType.google: 2,
  AuthType.apple: 3,
  AuthType.facebook: 4,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 1,
  UserStatus.inactive: 2,
  UserStatus.banned: 3,
  UserStatus.pendingVerification: 4,
  UserStatus.deleted: 5,
};

const _$UserRoleEnumMap = {
  UserRole.admin: 1,
  UserRole.moderator: 2,
  UserRole.customer: 3,
  UserRole.guest: 4,
};
