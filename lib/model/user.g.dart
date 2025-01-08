// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      id: json['_id'] as String?,
      pushNotificationId: json['pushNotificationId'] as String?,
      accountStatus: (json['accountStatus'] as num?)?.toInt() ?? 0,
      accountRole: (json['accountRole'] as num?)?.toInt() ?? 0,
    )..timestamp = json['timestamp'] as String;

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      '_id': instance.id,
      'pushNotificationId': instance.pushNotificationId,
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'accountStatus': instance.accountStatus,
      'accountRole': instance.accountRole,
      'timestamp': instance.timestamp,
    };
