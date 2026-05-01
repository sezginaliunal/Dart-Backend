import 'package:dart_backend/core/jwt/jwt_payload.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:shelf/shelf.dart';

const _payloadKey = 'jwtPayload';

/// Request'ten JWT'yi doğrular ve payload'ı context'e ekler.
/// tokenVersion DB kontrolü AuthService.refresh veya route handler'ında yapılır.
Middleware jwtAuthMiddleware(JwtService jwtService) {
  return (Handler inner) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'] ?? '';
      if (!authHeader.startsWith('Bearer ')) {
        return ResponseHandler.unauthorized('Authorization header eksik veya geçersiz');
      }

      final token = authHeader.substring(7).trim();
      final result = jwtService.verifyToken(token);

      if (result.isFailure) {
        return ResponseHandler.unauthorized(result.error!.message);
      }

      final updated = request.change(context: {_payloadKey: result.data!});
      return inner(updated);
    };
  };
}

extension JwtRequestExtension on Request {
  JwtPayload get jwtPayload => context[_payloadKey] as JwtPayload;
}
