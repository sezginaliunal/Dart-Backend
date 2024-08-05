// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['_id'] as String,
      pushNotificationId: json['pushNotificationId'] as String?,
      name: json['name'] as String,
      surname: json['surname'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      accountStatus:
          $enumDecodeNullable(_$AccountStatusEnumMap, json['accountStatus']) ??
              AccountStatus.active,
      accountRole:
          $enumDecodeNullable(_$AccountRoleEnumMap, json['accountRole']) ??
              AccountRole.user,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'pushNotificationId': instance.pushNotificationId,
      'name': instance.name,
      'surname': instance.surname,
      'email': instance.email,
      'password': instance.password,
      'accountStatus': _$AccountStatusEnumMap[instance.accountStatus]!,
      'accountRole': _$AccountRoleEnumMap[instance.accountRole]!,
    };

const _$AccountStatusEnumMap = {
  AccountStatus.active: 'active',
  AccountStatus.inactive: 'inactive',
  AccountStatus.suspended: 'suspended',
};

const _$AccountRoleEnumMap = {
  AccountRole.user: 'user',
  AccountRole.admin: 'admin',
  AccountRole.moderator: 'moderator',
};
