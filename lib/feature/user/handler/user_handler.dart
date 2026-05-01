import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/utils/pagination.dart';
import 'package:dart_backend/core/utils/validate.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:dart_backend/server/middleware/jwt_auth_middleware.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

final class UserHandler {
  final UserRepository _userRepo;

  const UserHandler({required UserRepository userRepo})
      : _userRepo = userRepo;

  /// GET /users/me
  /// tokenVersion DB ile karşılaştırılır — şifre/status değişmişse 401.
  Future<Response> me(Request req) async {
    final payload = req.jwtPayload;

    final result = await _userRepo.getByHexId(payload.id);
    if (result.isFailure || result.data == null) {
      return ResponseHandler.notFound('Kullanıcı bulunamadı');
    }

    final user = result.data!;

    if (payload.tokenVersion != user.tokenVersion) {
      return ResponseHandler.unauthorized(
        'Oturum geçersiz. Lütfen tekrar giriş yapın.',
      );
    }

    if (!user.canAccess) {
      return ResponseHandler.forbidden('Hesabınız erişime kapalı');
    }

    return ResponseHandler.ok(_toJson(user));
  }

  /// GET /users?page=1&pageSize=20
  Future<Response> list(Request req) async {
    final params = PaginationParams.fromQuery(req.url.queryParameters);
    final result = await _userRepo.paginationList(
      page: params.page,
      pageSize: params.pageSize,
      sortBy: params.sortBy,
      descending: params.descending,
    );
    if (result.isFailure) return ResponseHandler.notFound('Kullanıcı bulunamadı');
    return ResponseHandler.ok(
      PaginationResponse.fromParams(result.data!, params)
          .toJson(_toJson),
    );
  }

  /// GET /users/<id>
  Future<Response> getById(Request req, String id) async {
    final result = await _userRepo.getByHexId(id);
    if (result.isFailure || result.data == null) {
      return ResponseHandler.notFound('Kullanıcı bulunamadı');
    }
    return ResponseHandler.ok(_toJson(result.data!));
  }

  /// POST /users/create
  /// Body: application/x-www-form-urlencoded — name, role
  Future<Response> create(Request req) async {
    final body = await req.readAsString();
    final params = Uri.splitQueryString(body);
    final name = params['name'];

    if (name == null || name.trim().isEmpty) {
      return ResponseHandler.badRequest('"name" alanı zorunlu');
    }

    final roleStr = params['role'] ?? 'customer';
    late UserRole role;
    try {
      role = UserRole.values.firstWhere((r) => r.name == roleStr);
    } catch (_) {
      return ResponseHandler.badRequest(
        'Geçersiz rol: $roleStr. Geçerli değerler: '
        '${UserRole.values.map((r) => r.name).join(', ')}',
      );
    }

    final user = User(name: name.trim(), role: role);
    final result = await _userRepo.create(user);
    if (result.isFailure) {
      return ResponseHandler.conflict('"$name" adında kullanıcı zaten mevcut');
    }

    return ResponseHandler.created({'name': user.name, 'role': user.role.name});
  }

  /// PATCH /users/<id>/status
  /// Body: { "status": 2 }
  /// tokenVersion artar → eski JWT'ler geçersiz olur.
  Future<Response> updateStatus(Request req, String id) async {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz JSON formatı');
    }

    final statusValue = json['status'] as int?;
    if (statusValue == null) {
      return ResponseHandler.badRequest('"status" alanı zorunlu (integer)');
    }

    late UserStatus newStatus;
    try {
      newStatus = UserStatus.fromValue(statusValue);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz status değeri: $statusValue');
    }

    late ObjectId oid;
    try {
      oid = ObjectId.fromHexString(id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final result = await _userRepo.updateStatus(oid, newStatus);
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok({
      'updated': true,
      'tokenInvalidated': true,
    }, message: 'Status güncellendi, oturumlar sonlandırıldı');
  }

  /// PATCH /users/<id>/password
  /// Body: { "newPassword": "..." }
  /// Admin veya kullanıcının kendisi çağırabilir.
  /// tokenVersion artar → eski JWT'ler geçersiz olur.
  Future<Response> updatePassword(Request req, String id) async {
    final payload = req.jwtPayload;

    final isSelf = payload.id == id;
    final isAdmin = payload.role.isStaff;
    if (!isSelf && !isAdmin) {
      return ResponseHandler.forbidden('Bu işlem için yetkiniz yok');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz JSON formatı');
    }

    final rawPassword = json['newPassword'];
    if (rawPassword is! String) {
      return ResponseHandler.badRequest('"newPassword" alanı zorunlu');
    }

    final error = Validators.validatePassword(rawPassword.trim(), minLength: 6);
    if (error != null) return ResponseHandler.badRequest(error.toBackendMessage());

    late ObjectId oid;
    try {
      oid = ObjectId.fromHexString(id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final userResult = await _userRepo.getById(oid);
    if (userResult.isFailure || userResult.data == null) {
      return ResponseHandler.notFound('Kullanıcı bulunamadı');
    }
    if (!userResult.data!.authType.isEmail) {
      return ResponseHandler.badRequest(
        'Bu kullanıcı email ile kayıtlı değil, şifre güncellenemez',
      );
    }

    final newHash = BCrypt.hashpw(rawPassword.trim(), BCrypt.gensalt());
    final result = await _userRepo.updatePassword(oid, newHash);
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok({
      'updated': true,
      'tokenInvalidated': true,
    }, message: 'Şifre güncellendi, tüm oturumlar sonlandırıldı');
  }

  // ── private ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toJson(User user) => {
        'id': user.id.oid,
        'name': user.name,
        'role': user.role.value,
        'status': user.status.value,
        'authType': user.authType.value,
      };
}
