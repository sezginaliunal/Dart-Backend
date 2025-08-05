import 'dart:io';
import 'dart:math';
import 'package:alfred/alfred.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/utils/enums/directory.dart';

class FileUploadController {
  final uploadDirectory = Directory('public');
  final allowedExtensions = ['jpg', 'jpeg', 'png'];
  final int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB

  Future<ApiResponse<String>> handleFileUpload(
    HttpRequest req,
    Map<String, dynamic> body,
    String bodyFieldName,
    AppDirectory dirPath,
  ) async {
    final uploadedFile = body[bodyFieldName] as HttpBodyFileUpload;

    final fileBytes = uploadedFile.content as List<int>;
    final extension = uploadedFile.filename.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      return ApiResponse(
        success: false,
        message: 'Sadece JPG, JPEG ve PNG dosyaları kabul edilmektedir.',
      );
    }

    if (fileBytes.length > maxFileSizeInBytes) {
      return ApiResponse(
        success: false,
        message: "Dosya boyutu 10 MB'ı geçemez.",
      );
    }

    // Alt klasörü oluştur
    final fullDirPath = '${uploadDirectory.path}/${dirPath.name}';
    final dir = Directory(fullDirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final savedFilePath = '$fullDirPath/${uploadedFile.filename}';
    await File(savedFilePath).writeAsBytes(fileBytes);

    // 🟡 Tam URL oluşturuluyor
    final ip =
        '${Env().envConfig.host}:${Env().envConfig.port}'; // sunucu IP:port
    final publicUrlPath = '/files/${dirPath.name}/${uploadedFile.filename}';
    final fullUrl = '$ip$publicUrlPath';

    return ApiResponse(
      data: fullUrl,
      message: 'Dosya başarıyla yüklendi.',
    );
  }

  Future<String> getRandomPngFile(String path) async {
    final directory = Directory('${uploadDirectory.absolute.path}/$path');
    if (!await directory.exists()) {
      throw Exception('Dizin bulunamadı: $path');
    }

    final pngFiles = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.png'))
        .cast<File>()
        .toList();

    if (pngFiles.isEmpty) return '';

    final random = Random();
    final selected = pngFiles[random.nextInt(pngFiles.length)];

    return selected.path.split(Platform.pathSeparator).last;
  }
}
