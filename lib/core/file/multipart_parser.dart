import 'dart:async';
import 'dart:convert';

import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';

/// Multipart isteğinden parse edilen tek bir alan.
sealed class MultipartField {
  const MultipartField();
}

/// Düz metin alanı (name, email vb.)
final class TextField extends MultipartField {
  final String name;
  final String value;
  const TextField({required this.name, required this.value});
}

/// Dosya alanı
final class FileField extends MultipartField {
  final String name;

  /// Tarayıcının/client'ın gönderdiği orijinal dosya adı.
  final String? filename;

  /// Content-Type başlığından alınan MIME türü.
  final String mimeType;

  /// Dosyanın ham byte'ları.
  final List<int> bytes;

  const FileField({
    required this.name,
    required this.filename,
    required this.mimeType,
    required this.bytes,
  });
}

final class MultipartParser {
  const MultipartParser._();

  /// [request]'in body'sini parse eder ve alan listesi döner.
  ///
  /// Content-Type multipart/form-data değilse boş liste döner.
  /// Her alan sırasıyla işlenir; büyük dosyalar memory'e tamamen alınır
  /// (streaming yerine) — bu implementasyonda max boyut FileValidator'da sınırlanır.
  static Future<List<MultipartField>> parse(Request request) async {
    final contentType = request.headers['content-type'] ?? '';
    if (!contentType.contains('multipart/form-data')) return [];

    // Boundary değerini çıkar: multipart/form-data; boundary=----XYZ
    final boundary = _extractBoundary(contentType);
    if (boundary == null) return [];

    final bodyBytes = await request.read().expand((chunk) => chunk).toList();
    final transformer = MimeMultipartTransformer(boundary);
    final parts = await transformer.bind(Stream.value(bodyBytes)).toList();

    final fields = <MultipartField>[];

    for (final part in parts) {
      final disposition = part.headers['content-disposition'] ?? '';
      final fieldName = _extractParam(disposition, 'name');
      if (fieldName == null) continue;

      final bytes = await part.expand((chunk) => chunk).toList();
      final filename = _extractParam(disposition, 'filename');

      if (filename != null) {
        // Dosya alanı
        final mimeType =
            part.headers['content-type']?.trim() ?? 'application/octet-stream';
        fields.add(
          FileField(
            name: fieldName,
            filename: filename.isEmpty ? null : filename,
            mimeType: mimeType,
            bytes: bytes,
          ),
        );
      } else {
        // Metin alanı
        fields.add(
          TextField(name: fieldName, value: utf8.decode(bytes).trim()),
        );
      }
    }

    return fields;
  }

  static String? _extractBoundary(String contentType) {
    // "multipart/form-data; boundary=----WebKitFormBoundaryXYZ"
    for (final part in contentType.split(';')) {
      final trimmed = part.trim();
      if (trimmed.startsWith('boundary=')) {
        return trimmed.substring('boundary='.length).trim();
      }
    }
    return null;
  }

  static String? _extractParam(String header, String param) {
    // Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
    final pattern = RegExp('$param="([^"]*)"');
    return pattern.firstMatch(header)?.group(1);
  }
}
