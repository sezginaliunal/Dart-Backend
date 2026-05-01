import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/feature/auth/auth_service.dart';
import 'package:dart_backend/feature/auth/handler/auth_handler.dart';
import 'package:dart_backend/server/middleware/rate_limit_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Public endpoint'ler — JWT gerektirmez.
///
///   GET  /health
///   POST /auth/register  — rate limit: 5 istek / dakika
///   POST /auth/login     — rate limit: 5 istek / dakika
///   POST /auth/refresh   — rate limit: 10 istek / dakika
Router publicRouter({
  required AuthService authService,
  required FileStorage fileStorage,
}) {
  final handler = AuthHandler(authService: authService, fileStorage: fileStorage);

  // Brute-force koruması: 1 dakikada 5 başarısız deneme yeterli
  final authLimit = Pipeline().addMiddleware(
    rateLimitMiddleware(
      maxRequests: 5,
      window: const Duration(minutes: 1),
      message: 'Çok fazla istek. 1 dakika bekleyin.',
    ),
  );

  // Refresh biraz daha geniş — normal kullanımda sık çağrılabilir
  final refreshLimit = Pipeline().addMiddleware(
    rateLimitMiddleware(
      maxRequests: 10,
      window: const Duration(minutes: 1),
    ),
  );

  final router = Router();

  router.get('/health', handler.health);
  router.post('/auth/register', authLimit.addHandler(handler.register));
  router.post('/auth/login', authLimit.addHandler(handler.login));
  router.post('/auth/refresh', refreshLimit.addHandler(handler.refresh));

  return router;
}
