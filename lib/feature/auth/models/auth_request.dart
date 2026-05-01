import 'package:dart_backend/core/enums/auth.dart';

/// Kayıt isteği modeli.
///
/// AuthType'a göre farklı alanlar zorunludur:
///
/// ─── Email (authType: 1) ────────────────────────────────────────────────────
/// Kullanıcı adı + şifre ile klasik kayıt.
/// Şifre bcrypt ile hash'lenerek DB'ye kaydedilir, düz metin asla saklanmaz.
///
///   POST /auth/register
///   {
///     "name": "ali",
///     "authType": 1,
///     "password": "gizli123"
///   }
///
/// ─── Google (authType: 2) ───────────────────────────────────────────────────
/// Google Sign-In sonrası client'tan gelen Google UID (sub claim) ile kayıt.
/// Şifre kullanılmaz; kimlik doğrulama providerUid eşleşmesiyle yapılır.
/// NOT: Gerçek bir uygulamada client'tan gelen Google ID token sunucuda
/// google-auth kütüphanesiyle doğrulanmalıdır. Burada sadece UID saklanıyor.
///
///   POST /auth/register
///   {
///     "name": "ali",
///     "authType": 2,
///     "providerUid": "109876543210123456789"
///   }
///
/// ─── Apple (authType: 3) ────────────────────────────────────────────────────
/// Apple Sign In'den gelen user identifier (sub) ile kayıt.
/// Apple sadece ilk girişte kullanıcı adı verir; sonraki girişlerde sub kullanılır.
/// NOT: Gerçek uygulamada Apple'ın identity token'ı JWT olarak doğrulanmalıdır.
///
///   POST /auth/register
///   {
///     "name": "ali",
///     "authType": 3,
///     "providerUid": "000123.abcdef1234567890abcdef.1234"
///   }
///
/// ─── Facebook (authType: 4) ─────────────────────────────────────────────────
/// Facebook Login'den gelen Facebook User ID ile kayıt.
/// NOT: Gerçek uygulamada Facebook access token, Graph API ile doğrulanmalıdır.
///
///   POST /auth/register
///   {
///     "name": "ali",
///     "authType": 4,
///     "providerUid": "1234567890123456"
///   }
///
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

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    final authTypeValue = json['authType'] as int?;
    if (authTypeValue == null) {
      throw const FormatException('authType zorunlu');
    }
    return RegisterRequest(
      name: json['name'] as String? ?? '',
      authType: AuthType.fromValue(authTypeValue),
      password: json['password'] as String?,
      providerUid: json['providerUid'] as String?,
    );
  }

  /// AuthType'a göre alan doğrulaması yapar.
  /// Hata varsa mesaj döner, geçerliyse null döner.
  String? validate() {
    if (name.trim().isEmpty) return '"name" alanı zorunlu';

    if (authType.isEmail) {
      // Email girişinde şifre zorunlu ve en az 6 karakter olmalı
      if (password == null || password!.trim().length < 6) {
        return 'Email girişinde en az 6 karakterli şifre gerekli';
      }
    } else {
      // Social girişlerde provider'dan gelen uid zorunlu
      if (providerUid == null || providerUid!.trim().isEmpty) {
        return '${authType.name} girişinde "providerUid" zorunlu';
      }
    }
    return null;
  }
}

/// Giriş isteği modeli.
///
/// Kayıt ile aynı authType/alan kuralları geçerlidir.
/// Kullanıcı hangi authType ile kaydolduysa aynısıyla giriş yapmalıdır;
/// aksi hâlde AuthService hata döner.
///
/// ─── Email girişi ────────────────────────────────────────────────────────────
///   { "name": "ali", "authType": 1, "password": "gizli123" }
///
/// ─── Google girişi ───────────────────────────────────────────────────────────
///   { "name": "ali", "authType": 2, "providerUid": "109876543210123456789" }
///
/// ─── Apple girişi ────────────────────────────────────────────────────────────
///   { "name": "ali", "authType": 3, "providerUid": "000123.abcdef..." }
///
/// ─── Facebook girişi ─────────────────────────────────────────────────────────
///   { "name": "ali", "authType": 4, "providerUid": "1234567890123456" }
///
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

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    final authTypeValue = json['authType'] as int?;
    if (authTypeValue == null) {
      throw const FormatException('authType zorunlu');
    }
    return LoginRequest(
      name: json['name'] as String? ?? '',
      authType: AuthType.fromValue(authTypeValue),
      password: json['password'] as String?,
      providerUid: json['providerUid'] as String?,
    );
  }

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
