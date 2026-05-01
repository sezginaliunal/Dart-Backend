import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/upload_config.dart';

/// Kullanıcı avatarı için upload kuralları.
/// Tüm kısıtlamalar tek yerde — değiştirmek için başka dosyaya dokunmana gerek yok.
const avatarUploadConfig = UploadConfig(
  maxSizeBytes: 2 * 1024 * 1024, // 2 MB
  allowedTypes: {FileType.jpeg, FileType.png, FileType.webp},
  folder: 'avatars',
);
