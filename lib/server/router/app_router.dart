import 'dart:io';

import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/feature/auth/auth_service.dart';
import 'package:dart_backend/feature/product/product_repository.dart';
import 'package:dart_backend/feature/product/product_service.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:dart_backend/server/router/product_router.dart';
import 'package:dart_backend/server/router/protected_user_router.dart';
import 'package:dart_backend/server/router/public_router.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

/// Ana router — tüm sub-router'ları birleştirir.
///
/// Route yapısı:
///   GET    /files/*              → static dosya servisi (uploads klasörü)
///   GET    /health               → public
///   POST   /auth/register        → public
///   POST   /auth/login           → public
///   POST   /auth/refresh         → public
///   GET    /users/me             → JWT korumalı
///   GET    /users                → admin/moderatör
///   GET    /users/<id>           → admin/moderatör
///   PATCH  /users/<id>/status    → admin
///   PATCH  /users/<id>/password  → admin veya kendisi
///   POST   /products             → JWT korumalı
///   GET    /products/me          → JWT korumalı
///   GET    /products             → admin/moderatör
///   POST   /products/<id>/photos → JWT korumalı
///   DELETE /products/<id>        → JWT korumalı (sahibi veya admin)
Router buildAppRouter({
  required UserRepository userRepo,
  required JwtRepository jwtRepo,
  required JwtService jwtService,
  required FileStorage fileStorage,
  required ProductRepository productRepo,
}) {
  final app = Router();

  final authService = AuthService(userRepo: userRepo, jwtRepo: jwtRepo);
  final productService = ProductService(
    repo: productRepo,
    fileStorage: fileStorage,
  );

  // Static dosya servisi — uploads/ klasörünü /files/ prefix'i ile dışa açar
  final uploadsDir = p.join(
    File(Platform.script.toFilePath()).parent.parent.path,
    'uploads',
  );
  app.mount('/files/', createStaticHandler(uploadsDir, serveFilesOutsidePath: false));

  // Public router
  app.mount('/', publicRouter(authService: authService, fileStorage: fileStorage).call);

  // Korumalı user router
  app.mount('/', protectedUserRouter(userRepo: userRepo, jwtService: jwtService));

  // Korumalı product router
  app.mount('/', productRouter(productService: productService, jwtService: jwtService));

  app.all('/<ignored|.*>', _notFoundHandler);

  return app;
}

Response _notFoundHandler(Request req) {
  return ResponseHandler.notFound('Route bulunamadı: ${req.requestedUri.path}');
}
