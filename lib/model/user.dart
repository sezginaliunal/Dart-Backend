import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum AccountStatus {
  active,
  inactive,
  suspended,
}

enum AccountRole {
  user,
  admin,
  moderator,
}

@JsonSerializable()
class User {
  User({
    required this.id,
    required this.name,
    required this.surname,
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
  final String name;
  final String surname;
  final String email;
  String password;
  @JsonKey(defaultValue: AccountStatus.active)
  final AccountStatus accountStatus;
  @JsonKey(defaultValue: AccountRole.user)
  final AccountRole accountRole;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
