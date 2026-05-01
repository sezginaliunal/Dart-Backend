import 'dart:io';

import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/upload_config.dart';
import 'package:path/path.dart' as p;

/// Dosya kaydetme/silme işlemlerini soyutlayan interface.
/// Şu an local disk kullanıyor; S3/GCS için implement eden yeni sınıf yeterli.
abstract interface class FileStorage {
  /// Bytes'ı diske yazar, erişilebilir URL/path döner.
  Future<String> save({
    required List<int> bytes,
    required FileType fileType,
    required UploadConfig config,
  });

  /// Daha önce kaydedilen dosyayı siler. Hata fırlatmaz — best effort.
  Future<void> delete(String path);
}

/// Local dosya sistemi implementasyonu.
///
/// Dosyalar şu yapıya kaydedilir:
///   uploads/{folder}/{uuid}.{ext}
///
/// Production'da bu sınıfı S3FileStorage / GcsFileStorage ile değiştir,
/// [FileStorage] interface'i aynı kaldığı için başka hiçbir şey değişmez.
final class LocalFileStorage implements FileStorage {
  /// Tüm upload'ların kök klasörü (server.dart yanında oluşturulur).
  final String baseDir;

  const LocalFileStorage({this.baseDir = 'uploads'});

  @override
  Future<String> save({
    required List<int> bytes,
    required FileType fileType,
    required UploadConfig config,
  }) async {
    final dir = Directory(p.join(baseDir, config.folder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Dosya adı olarak UUID benzeri benzersiz isim üretiyoruz.
    // dart:core'da UUID yok; timestamp + random yeterince benzersiz.
    final uniqueName =
        '${DateTime.now().microsecondsSinceEpoch}'
        '_${_randomHex(8)}'
        '.${fileType.extension}';

    final file = File(p.join(dir.path, uniqueName));
    await file.writeAsBytes(bytes, flush: true);

    // Dönen path client'a verilecek veya DB'ye yazılacak
    return '${config.folder}/$uniqueName';
  }

  @override
  Future<void> delete(String path) async {
    try {
      final file = File(p.join(baseDir, path));
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Silme başarısız olursa sessizce geç — işlem kritik değil.
      // Production'da buraya bir log çağrısı ekle.
    }
  }

  String _randomHex(int length) {
    // dart:math kullanmadan platform-independent basit rastgelelik
    final now = DateTime.now().microsecondsSinceEpoch;
    return now.toRadixString(16).padLeft(length, '0').substring(0, length);
  }
}
