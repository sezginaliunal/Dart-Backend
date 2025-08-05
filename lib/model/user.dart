import 'package:fixnum/fixnum.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:project_base/utils/helpers/int64_converter.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.accountRole = 0,
    this.accountStatus = 0,
    this.pushNotificationId = '',
    Int64? createdAt,
  }) : createdAt = createdAt ?? Int64(DateTime.now().millisecondsSinceEpoch);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @JsonKey(name: '_id')
  final String id;
  final String? pushNotificationId;
  final String username;
  final String email;
  String password;
  final int accountStatus;
  final int accountRole;

  @Int64Converter()
  final Int64 createdAt;
}
