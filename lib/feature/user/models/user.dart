import 'package:dart_backend/core/enums/auth.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Kullanıcı modeli.
///
/// ── tokenVersion ────────────────────────────────────────────────────────────
/// DB'de saklanan bir sayaçtır; başlangıç değeri 0'dır.
/// Login sırasında JWT payload'ına gömülür.
///
/// Admin şifreyi veya statusu değiştirdiğinde bu sayaç MongoDB'de atomik
/// olarak 1 artırılır. Kullanıcının elindeki eski JWT'nin payload'ındaki
/// tokenVersion artık DB'dekiyle uyuşmaz → 401 Unauthorized → yeniden giriş zorunlu.
///
/// Örnek akış:
///   1. Kullanıcı login olur → JWT(tokenVersion=0)
///   2. Admin şifreyi değiştirir → DB'de tokenVersion=1
///   3. Kullanıcı eski JWT ile istek atar → JWT(tokenVersion=0) ≠ DB(1) → 401
///   4. Kullanıcı tekrar login olur → JWT(tokenVersion=1)
///
/// ── AuthType & alanlar ───────────────────────────────────────────────────────
/// • email    → passwordHash dolu, providerUid null
/// • google   → passwordHash null, providerUid = Google sub (uid)
/// • apple    → passwordHash null, providerUid = Apple user identifier
/// • facebook → passwordHash null, providerUid = Facebook user id
class User {
  final ObjectId id;
  final String name;
  final UserStatus status;
  final UserRole role;
  final AuthType authType;

  /// Email auth için bcrypt hash'lenmiş şifre.
  /// Social auth kullanıcılarında null olur — şifre yoktur.
  final String? passwordHash;

  /// Social auth (Google/Apple/Facebook) için provider'dan gelen benzersiz uid.
  /// Email auth kullanıcılarında null olur.
  final String? providerUid;

  /// Şifre veya status her değiştiğinde 1 artar.
  /// JWT payload'ındaki değerle karşılaştırılarak token geçerliliği kontrol edilir.
  final int tokenVersion;
  final String? avatarPath;

  User({
    ObjectId? id,
    required this.name,
    this.authType = AuthType.email,
    this.status = UserStatus.active,
    this.role = UserRole.customer,
    this.passwordHash,
    this.providerUid,
    this.tokenVersion = 0,
    this.avatarPath,
  }) : id = id ?? ObjectId();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId,
      name: map['name'] as String,
      authType: AuthType.fromValue(
        map['authType'] as int? ?? AuthType.email.value,
      ),
      status: UserStatus.fromValue(
        map['status'] as int? ?? UserStatus.active.value,
      ),
      role: UserRole.fromValue(map['role'] as int? ?? UserRole.customer.value),
      passwordHash: map['passwordHash'] as String?,
      providerUid: map['providerUid'] as String?,
      tokenVersion: map['tokenVersion'] as int? ?? 0,
      avatarPath: map['avatarPath'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    '_id': id,
    'name': name,
    'status': status.value,
    'role': role.value,
    'authType': authType.value,
    if (passwordHash != null) 'passwordHash': passwordHash,
    if (providerUid != null) 'providerUid': providerUid,
    'tokenVersion': tokenVersion,
    if (avatarPath != null) 'avatarPath': avatarPath,
  };

  bool get canAccess => status.canAccess;
  bool get isStaff => role.isStaff;

  User copyWith({
    String? name,
    UserStatus? status,
    UserRole? role,
    AuthType? authType,
    String? passwordHash,
    String? providerUid,
    int? tokenVersion,
  }) => User(
    id: id,
    name: name ?? this.name,
    status: status ?? this.status,
    role: role ?? this.role,
    authType: authType ?? this.authType,
    passwordHash: passwordHash ?? this.passwordHash,
    providerUid: providerUid ?? this.providerUid,
    tokenVersion: tokenVersion ?? this.tokenVersion,
  );

  @override
  String toString() =>
      'User(id: $id, name: $name, role: ${role.name}, status: ${status.name}, authType: ${authType.name})';
}
