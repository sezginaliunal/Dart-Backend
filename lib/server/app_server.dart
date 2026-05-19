import 'dart:io';

import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/middleware/logger_middleware.dart';
import 'package:dart_backend/server/router/app_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<HttpServer> startServer({
  required EnvService env,
  required UserRepository userRepo,
  required JwtRepository jwtRepo,
  required JwtService jwtService,
  required FileStorage fileStorage,
}) async {
  final router = buildAppRouter(
    userRepo: userRepo,
    jwtRepo: jwtRepo,
    jwtService: jwtService,
    fileStorage: fileStorage,
  );

  final pipeline = Pipeline()
      .addMiddleware(loggerMiddleware())
      .addHandler(router.call);

  final server = await shelf_io.serve(pipeline, env.serverHost, env.serverPort);
  server.autoCompress = true;

  print('');
  print('┌─────────────────────────────────────────────────┐');
  print('│  🚀  Server başlatıldı                          │');
  print(
    '│  http://${env.serverHost}:${env.serverPort}                           │',
  );
  print('└─────────────────────────────────────────────────┘');
  print('');
  print('  PUBLIC');
  print('  GET    /health');
  print('  POST   /auth/register');
  print('  POST   /auth/login');
  print('  POST   /auth/refresh');
  print('');
  print('  USERS  (JWT korumalı)');
  print('  GET    /users/me');
  print('  GET    /users                  (admin/mod)');
  print('  GET    /users/<id>             (admin/mod)');
  print('  PATCH  /users/<id>/status      (admin)');
  print('  PATCH  /users/<id>/password    (admin/kendisi)');
  print('');
  print('  PRODUCTS  (JWT korumalı)');
  print('  POST   /products');
  print('  GET    /products/me');
  print('  GET    /products               (admin/mod)');
  print('  POST   /products/<id>/photos');
  print('  DELETE /products/<id>');
  print('');
  print('  STATIC');
  print('  GET    /files/<path>');
  print('');

  return server;
}
