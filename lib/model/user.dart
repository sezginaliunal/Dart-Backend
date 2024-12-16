import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum AccountStatus {
  @JsonValue(0)
  active,
  @JsonValue(1)
  inactive,
  @JsonValue(2)
  suspended,
  @JsonValue(3)
  pending,
  @JsonValue(4)
  banned,
  @JsonValue(5)
  deleted,
}

enum AccountRole {
  @JsonValue(0)
  user,
  @JsonValue(1)
  admin,
  @JsonValue(2)
  guest,
}

@JsonSerializable()
class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.pushNotificationId,
    this.accountStatus = AccountStatus.active,
    this.accountRole = AccountRole.user,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  @JsonKey(name: '_id')
  final String id;
  final String? pushNotificationId;
  final String username;
  final String email;
  String password;
  @JsonKey(defaultValue: AccountStatus.active)
  final AccountStatus accountStatus;
  @JsonKey(defaultValue: AccountRole.user)
  final AccountRole accountRole;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
