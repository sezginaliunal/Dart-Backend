import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/upload_config.dart';

/// Ürün fotoğrafları için upload kuralları.
const productPhotoUploadConfig = UploadConfig(
  maxSizeBytes: 5 * 1024 * 1024, // 5 MB — avatar'dan daha geniş
  allowedTypes: {FileType.jpeg, FileType.png, FileType.webp},
  folder: 'products',
);

/// Bir ürüne eklenebilecek maksimum fotoğraf sayısı.
const productMaxPhotos = 5;
