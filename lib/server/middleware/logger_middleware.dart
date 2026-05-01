import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:shelf/shelf.dart';

/// Her HTTP isteğini ve yanıtını loglar.
/// Uygulama hataları (5xx) AppLogger.error ile ayrıca işaretlenir.
Middleware loggerMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      final start = DateTime.now();
      final method = request.method;
      final path = request.requestedUri.path;

      Response response;
      try {
        response = await inner(request);
      } catch (e, st) {
        final ms = DateTime.now().difference(start).inMilliseconds;
        AppLogger.error(
          '$method $path → 500 (${ms}ms)',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }

      final ms = DateTime.now().difference(start).inMilliseconds;
      final status = response.statusCode;

      if (status >= 500) {
        AppLogger.error('$method $path → $status (${ms}ms)');
      } else if (status >= 400) {
        AppLogger.warn('$method $path → $status (${ms}ms)');
      } else {
        AppLogger.info('$method $path → $status (${ms}ms)');
      }

      return response;
    };
  };
}
