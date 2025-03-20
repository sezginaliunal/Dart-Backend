import 'package:flutter/foundation.dart';

enum LogLevel {
  error('🔥', '\x1B[31m'), // Kırmızı
  warning('⚠️', '\x1B[33m'), // Sarı
  info('ℹ️', '\x1B[32m'), // Yeşil
  debug('🐞', '\x1B[34m'); // Mavi

  final String emoji;
  final String color;
  const LogLevel(this.emoji, this.color);
}

class Logger {
  static const String _reset = '\x1B[0m';

  static void log(LogLevel level, String message) {
    if (kDebugMode) {
      print(
        '${level.color}${level.emoji} [${level.name.toUpperCase()}] $message$_reset',
      );
    }
  }
}
