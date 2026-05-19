import 'package:dart_backend/core/enums/auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_dto.g.dart';

@JsonSerializable()
final class RegisterRequest {
  final String name;
  final AuthType authType;

  /// Email auth için zorunlu. Minimum 6 karakter.
  final String? password;

  /// Social auth (Google/Apple/Facebook) için zorunlu.
  /// Provider'dan gelen benzersiz kullanıcı tanımlayıcısı.
  final String? providerUid;

  const RegisterRequest({
    required this.name,
    required this.authType,
    this.password,
    this.providerUid,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);

  /// AuthType'a göre alan doğrulaması yapar.
  /// Hata varsa mesaj döner, geçerliyse null döner.
  String? validate() {
    if (name.trim().isEmpty) return '"name" alanı zorunlu';

    if (authType.isEmail) {
      if (password == null || password!.trim().length < 6) {
        return 'Email girişinde en az 6 karakterli şifre gerekli';
      }
    } else {
      if (providerUid == null || providerUid!.trim().isEmpty) {
        return '${authType.name} girişinde "providerUid" zorunlu';
      }
    }

    return null;
  }
}

@JsonSerializable()
final class LoginRequest {
  final String name;
  final AuthType authType;

  /// Email auth için zorunlu.
  final String? password;

  /// Social auth için zorunlu.
  final String? providerUid;

  const LoginRequest({
    required this.name,
    required this.authType,
    this.password,
    this.providerUid,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  String? validate() {
    if (name.trim().isEmpty) return '"name" alanı zorunlu';

    if (authType.isEmail) {
      if (password == null || password!.isEmpty) {
        return 'Email girişinde "password" zorunlu';
      }
    } else {
      if (providerUid == null || providerUid!.trim().isEmpty) {
        return '${authType.name} girişinde "providerUid" zorunlu';
      }
    }

    return null;
  }
}
