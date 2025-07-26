// ignore_for_file: sort_constructors_first

import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({
    required this.username,
    required this.email,
    required this.password,
    required this.id,
    this.accountRole = 0,
    this.accountStatus = 0,
    this.pushNotificationId = '',
  }) : createdAt = DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @JsonKey(name: '_id')
  final String id;
  final String? pushNotificationId;
  final String username;
  final String email;
  String password;
  final int accountStatus;
  final int accountRole;
  DateTime createdAt;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
