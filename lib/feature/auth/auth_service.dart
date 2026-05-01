import 'package:bcrypt/bcrypt.dart';
import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/enums/auth.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/feature/auth/auth_response.dart';
import 'package:dart_backend/feature/auth/models/auth_request.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_repository.dart';

/// Auth iş mantığı katmanı.
///
/// ── tokenVersion nedir ve neden var? ────────────────────────────────────────
/// Her kullanıcı DB'de bir [tokenVersion] sayacı taşır (başlangıç: 0).
/// Login sırasında bu sayac JWT payload'ına gömülür.
///
/// Admin DB'den kullanıcının şifresini veya statusunu değiştirdiğinde
/// [UserCollection.updatePassword] / [UserCollection.updateStatus] çağrısı
/// DB'deki tokenVersion'ı atomik olarak 1 artırır (0 → 1, 1 → 2, ...).
///
/// Kullanıcı sonraki istekte (örn. /users/me) eski JWT'yi gönderdiğinde:
///   JWT'deki tokenVersion = 0
///   DB'deki  tokenVersion = 1   → UYUŞMAZLIK → 401 Unauthorized
///
/// Kullanıcı tekrar login olunca yeni JWT, DB'deki güncel tokenVersion'ı (1) taşır.
/// Bu sayede şifre değişince veya hesap askıya alınınca tüm aktif oturumlar
/// geçersiz olur; kullanıcı yeniden giriş yapmak zorunda kalır.
///
/// ── AuthType akışları ────────────────────────────────────────────────────────
/// • email    → şifre bcrypt ile hash'lenir, doğrulama BCrypt.checkpw ile yapılır
/// • google   → Google'dan gelen uid (sub) saklanır, doğrulama uid eşleşmesiyle yapılır
/// • apple    → Apple'dan gelen user identifier saklanır
/// • facebook → Facebook'tan gelen user id saklanır
///
/// NOT: Social akışlarda bu servis providerUid'i olduğu gibi kabul eder.
/// Gerçek bir uygulamada client'tan gelen provider token'ı (Google ID token,
/// Apple identity token, Facebook access token) burada harici bir servisle
/// doğrulanmalıdır. Bu proje o katmanı client'a bırakmaktadır.
final class AuthService {
  final UserRepository _userRepo;
  final JwtRepository _jwtRepo;

  AuthService({
    required UserRepository userRepo,
    required JwtRepository jwtRepo,
  }) : _userRepo = userRepo,
       _jwtRepo = jwtRepo;

  // ── Register ──────────────────────────────────────────────────────────────

  /// Kullanıcıyı kaydeder. JWT üretmez — giriş için [login] kullanılmalı.
  ///
  /// • Email: şifreyi bcrypt ile hash'leyip DB'ye yazar
  /// • Social: providerUid'i DB'ye yazar, şifre alanı null kalır
  Future<AppResponse<bool>> register(
    RegisterRequest req, {
    String? avatarPath, // opsiyonel — avatar yüklendiyse path gelir
  }) async {
    // ...
    final User user;

    if (req.authType.isEmail) {
      final hash = BCrypt.hashpw(req.password!, BCrypt.gensalt());
      user = User(
        name: req.name.trim(),
        authType: AuthType.email,
        passwordHash: hash,
        avatarPath: avatarPath,
      );
    } else {
      user = User(
        name: req.name.trim(),
        authType: req.authType,
        providerUid: req.providerUid,
        avatarPath: avatarPath,
      );
    }

    return _userRepo.create(user);
  }
  // ── Login ─────────────────────────────────────────────────────────────────

  /// Kullanıcıyı doğrular ve JWT çifti (access + refresh) üretir.
  ///
  /// Kontroller sırası:
  ///   1. Kullanıcı adı DB'de var mı?
  ///   2. Hesap erişime açık mı? (status: active veya pendingVerification)
  ///   3. Gelen authType, kayıttaki authType ile uyuşuyor mu?
  ///   4. Kimlik bilgisi doğru mu? (şifre veya providerUid)
  Future<AppResponse<AuthResponse>> login(LoginRequest req) async {
    // 1. Kullanıcıyı bul
    final userResult = await _userRepo.getByName(req.name.trim());
    if (userResult.isFailure || userResult.data == null) {
      // Güvenlik: kullanıcı yok ile yanlış şifre aynı hata mesajını verir
      return AppResponse.failure(const UnauthorizedError());
    }

    final user = userResult.data!;

    // 2. Hesap erişim kontrolü
    // banned, inactive veya deleted kullanıcılar giriş yapamaz
    if (!user.canAccess) {
      return AppResponse.failure(const ForbiddenError());
    }

    // 3. AuthType uyumu — örn. Google ile kayıtlı kullanıcı email ile giriş yapamaz
    if (user.authType != req.authType) {
      return AppResponse.failure(
        CustomError(
          'Bu hesap ${user.authType.name} ile kayıtlı. '
          'Lütfen ${user.authType.name} ile giriş yapın.',
        ),
      );
    }

    // 4. Kimlik doğrulama
    if (!_authenticate(user, req)) {
      return AppResponse.failure(const UnauthorizedError());
    }

    // JWT üret — tokenVersion DB'den alınarak payload'a gömülür
    return _jwtRepo.generateToken(user);
  }

  // ── Token Yenileme ────────────────────────────────────────────────────────

  /// Refresh token ile yeni access + refresh token çifti üretir.
  ///
  /// tokenVersion kontrolü burada yapılır:
  ///   JWT payload'ındaki tokenVersion ≠ DB'deki tokenVersion → 401
  /// Bu, şifre veya status değişikliğinden sonra eski refresh token'larının
  /// çalışmamasını garanti eder.
  Future<AppResponse<AuthResponse>> refresh({
    required String refreshToken,
    required String userId,
  }) async {
    // JWT imzasını doğrula (DB'ye gitmez — sadece RSA verify)
    final verifyResult = _jwtRepo.verifyToken(refreshToken);
    if (verifyResult.isFailure) {
      return AppResponse.failure(verifyResult.error!);
    }

    // Güncel kullanıcıyı DB'den getir — tokenVersion'ın değişip değişmediğini
    // öğrenmek için her seferinde DB'ye gidiyoruz
    final userResult = await _userRepo.getByHexId(userId);
    if (userResult.isFailure || userResult.data == null) {
      return AppResponse.failure(const UnauthorizedError());
    }

    final user = userResult.data!;
    final payload = verifyResult.data!;

    // tokenVersion eşleşmesi: şifre/status değişmişse bu kontrol başarısız olur
    if (payload.tokenVersion != user.tokenVersion) {
      return AppResponse.failure(
        const CustomError('Token geçersiz. Lütfen tekrar giriş yapın.'),
      );
    }

    if (!user.canAccess) {
      return AppResponse.failure(const ForbiddenError());
    }

    return _jwtRepo.refreshToken(refreshToken, user);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// AuthType'a göre kimlik doğrulaması yapar.
  ///
  /// Email: BCrypt.checkpw — hash'i çözmeden şifrenin doğru olup olmadığını kontrol eder.
  /// Social: providerUid eşleşmesi — provider'dan gelen uid DB'dekiyle aynı mı?
  bool _authenticate(User user, LoginRequest req) {
    if (req.authType.isEmail) {
      if (user.passwordHash == null || req.password == null) return false;
      // BCrypt.checkpw: gelen şifreyi DB'deki hash ile güvenli biçimde karşılaştırır.
      // Timing-safe karşılaştırma yapar → brute-force'a karşı daha dirençli.
      return BCrypt.checkpw(req.password!, user.passwordHash!);
    } else {
      // Social auth: client'ın gönderdiği uid, kayıttaki uid ile eşleşmeli.
      // Bu uid'nin gerçekten Google/Apple/Facebook'tan geldiğini doğrulamak
      // için provider token'ının sunucu tarafında verify edilmesi gerekir
      // (bu sorumluluk bu katmanın dışındadır).
      return user.providerUid != null &&
          user.providerUid == req.providerUid?.trim();
    }
  }
}
