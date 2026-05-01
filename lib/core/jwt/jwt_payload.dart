import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/feature/user/models/user.dart';

final class JwtPayload {
  final String id;
  final UserRole role;

  /// DB'deki tokenVersion ile eşleşmezse token geçersiz sayılır.
  final int tokenVersion;

  const JwtPayload({
    required this.id,
    required this.role,
    required this.tokenVersion,
  });

  factory JwtPayload.fromUser(User user) => JwtPayload(
    id: user.id.oid,
    role: user.role,
    tokenVersion: user.tokenVersion,
  );

  factory JwtPayload.fromMap(Map<String, dynamic> map) => JwtPayload(
    id: map['id'] as String,
    role: UserRole.values.firstWhere((r) => r.name == map['role']),
    tokenVersion: map['tokenVersion'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'role': role.name,
    'tokenVersion': tokenVersion,
  };
}
