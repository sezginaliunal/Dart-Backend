import 'dart:io';

import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/feature/auth/auth_service.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:dart_backend/server/router/protected_user_router.dart';
import 'package:dart_backend/server/router/public_router.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

Router buildAppRouter({
  required UserRepository userRepo,
  required JwtRepository jwtRepo,
  required JwtService jwtService,
  required FileStorage fileStorage,
}) {
  final app = Router();

  final authService = AuthService(userRepo: userRepo, jwtRepo: jwtRepo);

  // Static dosya servisi — uploads/ klasörünü /files/ prefix'i ile dışa açar
  final uploadsDir = p.join(
    File(Platform.script.toFilePath()).parent.parent.path,
    'uploads',
  );
  app.mount(
    '/files/',
    createStaticHandler(uploadsDir, serveFilesOutsidePath: false),
  );

  // Public router
  app.mount(
    '/',
    publicRouter(authService: authService, fileStorage: fileStorage).call,
  );

  // Korumalı user router
  app.mount(
    '/',
    protectedUserRouter(userRepo: userRepo, jwtService: jwtService),
  );

  app.all('/<ignored|.*>', _notFoundHandler);

  return app;
}

Response _notFoundHandler(Request req) {
  return ResponseHandler.notFound('Route bulunamadı: ${req.requestedUri.path}');
}
