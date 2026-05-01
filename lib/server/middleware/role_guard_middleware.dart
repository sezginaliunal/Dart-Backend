import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:dart_backend/server/middleware/jwt_auth_middleware.dart';
import 'package:shelf/shelf.dart';

/// JWT auth'dan sonra çalışır — payload'daki role'e göre erişimi kısıtlar.
///
/// Kullanım:
/// ```dart
/// final pipeline = Pipeline()
///     .addMiddleware(jwtAuthMiddleware(jwtService))
///     .addMiddleware(requireRoles({UserRole.admin}))
///     .addHandler(adminHandler);
/// ```
Middleware requireRoles(Set<UserRole> allowedRoles) {
  return (Handler inner) {
    return (Request request) async {
      final payload = request.jwtPayload;

      if (!allowedRoles.contains(payload.role)) {
        return ResponseHandler.forbidden(
          'Bu işlem için yetkiniz yok. Gerekli rol: '
          '${allowedRoles.map((r) => r.name).join(', ')}',
        );
      }

      return inner(request);
    };
  };
}
