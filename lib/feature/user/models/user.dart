import 'package:dart_backend/core/enums/auth.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final UserStatus status;
  final UserRole role;
  final AuthType authType;

  /// Email auth için bcrypt hash'lenmiş şifre.
  final String? passwordHash;

  /// Social auth provider uid.
  final String? providerUid;

  /// JWT invalidate sistemi için version.
  final int tokenVersion;

  final String? avatarPath;

  const User({
    this.id,
    required this.name,
    this.authType = AuthType.email,
    this.status = UserStatus.active,
    this.role = UserRole.customer,
    this.passwordHash,
    this.providerUid,
    this.tokenVersion = 0,
    this.avatarPath,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get canAccess => status.canAccess;
  bool get isStaff => role.isStaff;

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: ${role.name}, status: ${status.name}, authType: ${authType.name})';
  }
}
