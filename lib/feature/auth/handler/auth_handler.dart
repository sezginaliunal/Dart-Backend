import 'dart:convert';

import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/file_validator.dart';
import 'package:dart_backend/core/file/multipart_parser.dart';
import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:dart_backend/feature/auth/auth_service.dart';
import 'package:dart_backend/feature/auth/models/auth_dto.dart';
import 'package:dart_backend/feature/user/user_upload_config.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:shelf/shelf.dart';

final class AuthHandler {
  final AuthService _authService;
  final FileStorage _fileStorage;

  const AuthHandler({
    required AuthService authService,
    required FileStorage fileStorage,
  }) : _authService = authService,
       _fileStorage = fileStorage;

  Response health(Request req) {
    return ResponseHandler.ok({
      'status': 'up',
      'timestamp': DateTime.now().toIso8601String(),
    }, message: 'Server is running');
  }

  Future<Response> register(Request req) async {
    final fields = await MultipartParser.parse(req);
    if (fields.isEmpty) {
      return ResponseHandler.badRequest(
        'İstek multipart/form-data formatında olmalı',
      );
    }

    final textFields = {
      for (final f in fields.whereType<TextField>()) f.name: f.value,
    };

    late RegisterRequest registerReq;
    try {
      registerReq = RegisterRequest.fromJson({
        'name': textFields['name'],
        'authType': int.tryParse(textFields['authType'] ?? ''),
        if (textFields.containsKey('password'))
          'password': textFields['password'],
        if (textFields.containsKey('providerUid'))
          'providerUid': textFields['providerUid'],
      });
    } on FormatException catch (e) {
      return ResponseHandler.badRequest(e.message);
    }

    final validationError = registerReq.validate();
    if (validationError != null) {
      return ResponseHandler.badRequest(validationError);
    }

    String? avatarPath;
    final avatarField = fields
        .whereType<FileField>()
        .where((f) => f.name == 'avatar')
        .firstOrNull;

    if (avatarField != null) {
      final fileError = FileValidator.validate(
        bytes: avatarField.bytes,
        mimeType: avatarField.mimeType,
        config: avatarUploadConfig,
      );
      if (fileError != null) return ResponseHandler.badRequest(fileError);

      final fileType = FileType.fromMime(avatarField.mimeType)!;
      try {
        avatarPath = await _fileStorage.save(
          bytes: avatarField.bytes,
          fileType: fileType,
          config: avatarUploadConfig,
        );
      } catch (e, st) {
        AppLogger.error('Avatar kaydedilemedi', error: e, stackTrace: st);
        return ResponseHandler.internalError('Dosya kaydedilemedi');
      }
    }

    final result = await _authService.register(
      registerReq,
      avatarPath: avatarPath,
    );

    if (result.isFailure) {
      if (avatarPath != null) await _fileStorage.delete(avatarPath);
      return ResponseHandler.fromAppResponse(result);
    }

    return ResponseHandler.created({
      'name': registerReq.name.trim(),
      'avatarPath': ?avatarPath,
    }, message: 'Kayıt başarılı. Giriş yapmak için /auth/login kullanın.');
  }

  Future<Response> login(Request req) async {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz JSON formatı');
    }

    late LoginRequest loginReq;
    try {
      loginReq = LoginRequest.fromJson(json);
    } on FormatException catch (e) {
      return ResponseHandler.badRequest(e.message);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz istek formatı');
    }

    final validationError = loginReq.validate();
    if (validationError != null) {
      return ResponseHandler.badRequest(validationError);
    }

    final result = await _authService.login(loginReq);
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(result.data!.toJson(), message: 'Giriş başarılı');
  }

  Future<Response> refresh(Request req) async {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz JSON formatı');
    }

    final refreshToken = json['refresh_token'] as String?;
    final userId = json['id'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      return ResponseHandler.badRequest('"refresh_token" zorunlu');
    }
    if (userId == null || userId.isEmpty) {
      return ResponseHandler.badRequest('"id" zorunlu');
    }

    final result = await _authService.refresh(
      refreshToken: refreshToken,
      userId: userId,
    );
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(
      result.data!.toJson(),
      message: 'Token yenilendi',
    );
  }
}
