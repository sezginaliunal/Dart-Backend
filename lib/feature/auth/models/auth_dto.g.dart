// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      name: json['name'] as String,
      authType: $enumDecode(_$AuthTypeEnumMap, json['authType']),
      password: json['password'] as String?,
      providerUid: json['providerUid'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'authType': _$AuthTypeEnumMap[instance.authType]!,
      'password': instance.password,
      'providerUid': instance.providerUid,
    };

const _$AuthTypeEnumMap = {
  AuthType.email: 1,
  AuthType.google: 2,
  AuthType.apple: 3,
  AuthType.facebook: 4,
};

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  name: json['name'] as String,
  authType: $enumDecode(_$AuthTypeEnumMap, json['authType']),
  password: json['password'] as String?,
  providerUid: json['providerUid'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'authType': _$AuthTypeEnumMap[instance.authType]!,
      'password': instance.password,
      'providerUid': instance.providerUid,
    };
