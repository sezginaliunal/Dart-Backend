import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:shelf/shelf.dart';

/// Belirli bir route prefix'i için IP tabanlı rate limiting.
///
/// İstekler memory'de tutulur — tek instance için uygundur.
/// Çok instance'lı deploy'larda Redis gibi harici store gerekir.
///
/// Kullanım:
///   Pipeline().addMiddleware(
///     rateLimitMiddleware(maxRequests: 5, window: Duration(minutes: 1)),
///   )
Middleware rateLimitMiddleware({
  /// Pencere içinde izin verilen maksimum istek sayısı.
  int maxRequests = 10,

  /// Sayacın sıfırlanacağı zaman penceresi.
  Duration window = const Duration(minutes: 1),

  /// Rate limit aşıldığında dönecek mesaj.
  String message = 'Çok fazla istek. Lütfen biraz bekleyin.',
}) {
  // IP → (istek sayısı, pencere başlangıcı)
  final store = <String, _RateEntry>{};

  return (Handler inner) {
    return (Request request) async {
      final ip = _clientIp(request);
      final now = DateTime.now();

      final entry = store[ip];

      if (entry == null || now.difference(entry.windowStart) >= window) {
        // Yeni pencere başlat
        store[ip] = _RateEntry(count: 1, windowStart: now);
      } else if (entry.count >= maxRequests) {
        // Limit aşıldı
        AppLogger.warn(
          'Rate limit aşıldı',
          context: 'ip=$ip path=${request.requestedUri.path}',
        );
        return ResponseHandler.tooManyRequests(message);
      } else {
        // Pencere devam ediyor, sayacı artır
        store[ip] = _RateEntry(
          count: entry.count + 1,
          windowStart: entry.windowStart,
        );
      }

      // Eski kayıtları periyodik temizle (bellek sızıntısı önlemi)
      if (store.length > 10000) {
        store.removeWhere(
          (_, e) => now.difference(e.windowStart) >= window * 2,
        );
      }

      return inner(request);
    };
  };
}

/// İstemcinin IP adresini alır.
/// Reverse proxy arkasında çalışıyorsa X-Forwarded-For header'ı önceliklidir.
String _clientIp(Request request) {
  final forwarded = request.headers['x-forwarded-for'];
  if (forwarded != null && forwarded.isNotEmpty) {
    return forwarded.split(',').first.trim();
  }
  return request.headers['x-real-ip'] ??
      request.context['shelf.io.connection_info']
          .toString()
          .split(':')
          .first
          .trim();
}

final class _RateEntry {
  final int count;
  final DateTime windowStart;
  const _RateEntry({required this.count, required this.windowStart});
}
