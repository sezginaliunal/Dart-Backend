import 'package:dart_backend/core/file/file_type.dart';

/// Bir upload noktasının kural kümesi.
/// Her feature kendi config'ini tanımlar → tek yerden kontrol.
///
/// Örnek — avatar:
///   const avatarConfig = UploadConfig(
///     maxSizeBytes: 2 * 1024 * 1024,          // 2 MB
///     allowedTypes: {FileType.jpeg, FileType.png, FileType.webp},
///     folder: 'avatars',
///   );
final class UploadConfig {
  /// Maksimum dosya boyutu (byte). Aşılırsa 400 döner.
  final int maxSizeBytes;

  /// İzin verilen MIME türleri. Dışındakiler 415 döner.
  final Set<FileType> allowedTypes;

  /// Dosyaların kaydedileceği alt klasör adı (örn. 'avatars', 'documents').
  final String folder;

  const UploadConfig({
    required this.maxSizeBytes,
    required this.allowedTypes,
    required this.folder,
  });

  /// Megabayt cinsinden okunabilir boyut limiti (log ve hata mesajları için).
  String get maxSizeMb =>
      '${(maxSizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
