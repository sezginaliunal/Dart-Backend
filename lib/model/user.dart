import 'package:json_annotation/json_annotation.dart';
import 'package:minersy_lite/utils/extensions/hash_string.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String? id;
  String? email;
  String? password;
  String? avatar;

  User({this.id, this.email, this.password, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: password ?? this.avatar,
    );
  }
}
