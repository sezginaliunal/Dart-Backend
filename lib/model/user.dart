// ignore_for_file: sort_constructors_first

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
  underReview, // New status for accounts being reviewed
  expired, // New status for expired accounts
  locked; // New status for accounts that are locked due to failed attempts

  int get value => index; // Enum sırasını int olarak döndüren getter
}

enum AccountRole {
  user, // Regular user with basic access
  supervisor, // User with supervisor privileges
  admin, // Administrator with full access
  guest,
  moderator,
  owner;

  int get value => index; // Enum sırasını int olarak döndüren getter
}

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

  static AccountStatus checkAccountStatus(int accountStatusValue) {
    return AccountStatus.values.firstWhere(
      (status) => status.value == accountStatusValue,
      orElse: () => AccountStatus.active,
    );
  }

  static AccountRole checkAccountRole(int accountRoleValue) {
    return AccountRole.values.firstWhere(
      (role) => role.value == accountRoleValue,
      orElse: () => AccountRole.user,
    );
  }
}
