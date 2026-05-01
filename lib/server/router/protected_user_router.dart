import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/feature/user/handler/user_handler.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/middleware/jwt_auth_middleware.dart';
import 'package:dart_backend/server/middleware/role_guard_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// JWT korumalı kullanıcı endpoint'leri.
///
///   GET    /users/me
///   GET    /users                  (admin/moderatör)
///   GET    /users/<id>             (admin/moderatör)
///   POST   /users/create           (sadece admin)
///   PATCH  /users/<id>/status      (admin)
///   PATCH  /users/<id>/password    (admin veya kendisi)
Handler protectedUserRouter({
  required UserRepository userRepo,
  required JwtService jwtService,
}) {
  final handler = UserHandler(userRepo: userRepo);

  final auth = Pipeline().addMiddleware(jwtAuthMiddleware(jwtService));

  final adminAuth = Pipeline()
      .addMiddleware(jwtAuthMiddleware(jwtService))
      .addMiddleware(requireRoles({UserRole.admin, UserRole.moderator}));

  final strictAdminAuth = Pipeline()
      .addMiddleware(jwtAuthMiddleware(jwtService))
      .addMiddleware(requireRoles({UserRole.admin}));

  final meRouter = Router()
    ..get('/users/me', handler.me)
    ..patch('/users/<id>/password', handler.updatePassword);

  final adminRouter = Router()
    ..get('/users', handler.list)
    ..get('/users/<id>', handler.getById)
    ..patch('/users/<id>/status', handler.updateStatus);

  final strictAdminRouter = Router()
    ..post('/users/create', handler.create);

  return Cascade()
      .add(auth.addHandler(meRouter.call))
      .add(adminAuth.addHandler(adminRouter.call))
      .add(strictAdminAuth.addHandler(strictAdminRouter.call))
      .handler;
}
