// ignore_for_file: sort_constructors_first

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({
    required this.username,
    required this.email,
    required this.password,
    String? id,
    this.pushNotificationId,
    this.accountStatus = 0, // Default olarak 'AccountStatus.active' (0)
    this.accountRole = 0, // Default olarak 'AccountRole.user' (0)
  })  : id = id ?? const Uuid().v4(),
        timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @JsonKey(name: '_id')
  final String id;
  final String? pushNotificationId;
  final String username;
  final String email;
  String password;
  @JsonKey(defaultValue: 0)
  final int accountStatus;
  @JsonKey(defaultValue: 0)
  final int accountRole;
  @JsonKey(name: 'timestamp')
  String timestamp;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
