import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/upload_config.dart';

/// Yüklenen dosyanın kurallara uygunluğunu kontrol eder.
/// İş mantığı değil — saf doğrulama katmanı.
final class FileValidator {
  const FileValidator._();

  /// [bytes] ve [mimeType] değerlerini [config] kurallarıyla doğrular.
  ///
  /// Dönen değer:
  ///   • null       → geçerli
  ///   • String     → hata mesajı (400 veya 415 için kullanılır)
  static String? validate({
    required List<int> bytes,
    required String mimeType,
    required UploadConfig config,
  }) {
    // 1. Boyut kontrolü
    if (bytes.length > config.maxSizeBytes) {
      return 'Dosya boyutu ${config.maxSizeMb} limitini aşıyor '
          '(gelen: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB)';
    }

    // 2. MIME türü kontrolü
    final fileType = FileType.fromMime(mimeType);
    if (fileType == null) {
      return 'Desteklenmeyen dosya türü: $mimeType';
    }

    // 3. Config whitelist kontrolü
    if (!config.allowedTypes.contains(fileType)) {
      final allowed = config.allowedTypes.map((t) => t.mime).join(', ');
      return 'Bu alan için izin verilen türler: $allowed';
    }

    // 4. Magic bytes doğrulaması — MIME spoofing'e karşı
    // Birisi jpeg uzantısıyla farklı bir dosya göndermeye çalışırsa yakalarız.
    final magicError = _checkMagicBytes(bytes, fileType);
    if (magicError != null) return magicError;

    return null; // geçerli
  }

  /// Dosyanın ilk byte'larını (magic bytes) kontrol eder.
  /// Content-Type başlığı taklit edilebilir; magic bytes daha güvenilirdir.
  static String? _checkMagicBytes(List<int> bytes, FileType type) {
    if (bytes.length < 4) return 'Dosya çok küçük veya bozuk';

    switch (type) {
      case FileType.jpeg:
        // JPEG: FF D8 FF
        if (bytes[0] != 0xFF || bytes[1] != 0xD8 || bytes[2] != 0xFF) {
          return 'Dosya içeriği JPEG formatıyla uyuşmuyor';
        }
      case FileType.png:
        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if (bytes[0] != 0x89 ||
            bytes[1] != 0x50 ||
            bytes[2] != 0x4E ||
            bytes[3] != 0x47) {
          return 'Dosya içeriği PNG formatıyla uyuşmuyor';
        }
      case FileType.webp:
        // WebP: RIFF????WEBP — byte 0-3: RIFF, byte 8-11: WEBP
        if (bytes.length < 12) return 'Dosya çok küçük veya bozuk';
        final riff = String.fromCharCodes(bytes.sublist(0, 4));
        final webp = String.fromCharCodes(bytes.sublist(8, 12));
        if (riff != 'RIFF' || webp != 'WEBP') {
          return 'Dosya içeriği WebP formatıyla uyuşmuyor';
        }
      case FileType.gif:
        // GIF: GIF87a veya GIF89a
        if (bytes.length < 6) return 'Dosya çok küçük veya bozuk';
        final header = String.fromCharCodes(bytes.sublist(0, 6));
        if (header != 'GIF87a' && header != 'GIF89a') {
          return 'Dosya içeriği GIF formatıyla uyuşmuyor';
        }
    }
    return null;
  }
}
