import 'dart:io';

/// Merkezi loglama servisi.
///
/// Kullanım:
///   AppLogger.error('Dosya kaydedilemedi', error: e, stackTrace: st);
///   AppLogger.warn('Token version uyuşmazlığı', context: 'userId: $id');
///   AppLogger.info('Sunucu başlatıldı');
abstract final class AppLogger {
  // ── Seviyeler ─────────────────────────────────────────────────────────────

  static void info(String message, {String? context}) {
    _log('INFO ', '\x1B[36m', message, context: context);
  }

  static void warn(String message, {String? context}) {
    _log('WARN ', '\x1B[33m', message, context: context);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
  }) {
    _log('ERROR', '\x1B[31m', message, context: context);
    if (error != null) {
      stderr.writeln('         ↳ ${error.runtimeType}: $error');
    }
    if (stackTrace != null) {
      // Sadece ilk 5 satırı bas — konsolu boğmamak için
      final lines = stackTrace.toString().split('\n').take(5).join('\n');
      stderr.writeln('         ↳ $lines');
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static void _log(
    String level,
    String color,
    String message, {
    String? context,
  }) {
    final now = DateTime.now()
        .toIso8601String()
        .replaceFirst('T', ' ')
        .substring(0, 23);
    final reset = '\x1B[0m';
    final ctx = context != null ? ' [$context]' : '';
    final out = level.startsWith('E') ? stderr : stdout;
    out.writeln('[$now] $color$level$reset$ctx $message');
  }
}
