// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      id: json['_id'] as String,
      accountRole: (json['accountRole'] as num?)?.toInt() ?? 0,
      accountStatus: (json['accountStatus'] as num?)?.toInt() ?? 0,
      pushNotificationId: json['pushNotificationId'] as String? ?? '',
    )..createdAt = DateTime.parse(json['createdAt'] as String);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'pushNotificationId': instance.pushNotificationId,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'accountStatus': instance.accountStatus,
      'accountRole': instance.accountRole,
      'createdAt': instance.createdAt.toIso8601String(),
    };
