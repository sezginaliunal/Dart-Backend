/// Desteklenen dosya türleri ve MIME → extension eşlemesi.
///
/// Yeni bir tür eklemek için sadece buraya bir değer eklemek yeterli —
/// [FileValidator] ve [FileStorage] otomatik destekler.
enum FileType {
  jpeg(mime: 'image/jpeg', extension: 'jpg'),
  png(mime: 'image/png', extension: 'png'),
  webp(mime: 'image/webp', extension: 'webp'),
  gif(mime: 'image/gif', extension: 'gif');

  final String mime;
  final String extension;

  const FileType({required this.mime, required this.extension});

  /// MIME string'den [FileType] döner, bilinmiyorsa null.
  static FileType? fromMime(String mime) {
    for (final type in FileType.values) {
      if (type.mime == mime.toLowerCase().trim()) return type;
    }
    return null;
  }
}
