import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

enum AccountStatus {
  active,
  inactive,
  suspended,
  pending,
  banned,
  deleted,
}

enum AccountRole {
  user,
  admin,
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

  static AccountStatus checkAccountStatus(String accountStatusValue) {
    final accountStatus = AccountStatus.values.firstWhere(
      (status) => status.name == accountStatusValue,
      orElse: () => AccountStatus.active,
    );
    return accountStatus;
  }
}
