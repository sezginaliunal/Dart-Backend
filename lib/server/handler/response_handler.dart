import 'dart:convert';

import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:shelf/shelf.dart';

final class ResponseHandler {
  ResponseHandler._();

  static final _headers = {'Content-Type': 'application/json; charset=utf-8'};

  // ── AppResponse'dan otomatik HTTP yanıtı ─────────────────────────────────

  static Response fromAppResponse<T>(
    AppResponse<T> response, {
    int successStatus = 200,
    String successMessage = 'OK',
    Object? Function(T data)? toJson,
  }) {
    if (response.isSuccess) {
      final raw = response.data;
      final encoded = (toJson != null && raw != null) ? toJson(raw) : raw;
      return _success(successStatus, successMessage, encoded);
    }

    return _fromError(response.error!);
  }

  // ── Hata türüne göre HTTP kodu seç ───────────────────────────────────────

  static Response _fromError(AppError error) {
    final message = error.message;

    return switch (error) {
      UnauthorizedError() => unauthorized(message),
      ForbiddenError() => forbidden(message),
      NotFoundError() => notFound(message),
      DataNotFoundError() => notFound(message),
      ConflictError() => conflict(message),
      BadRequestError() => badRequest(message),
      ValidationError() => badRequest(message),
      NetworkError() => internalError(message),
      DatabaseError() => internalError(message),
      TimeoutError() => internalError(message),
      PermissionDeniedError() => forbidden(message),
      NotUpdated() => internalError(message),
      ServerError() => internalError(message),
      CustomError() => internalError(message),
      UnknownError() => internalError(message),
    };
  }

  // ── Başarılı yanıtlar ─────────────────────────────────────────────────────

  static Response ok(Object? data, {String message = 'OK'}) =>
      _success(200, message, data);

  static Response created(Object? data, {String message = 'Created'}) =>
      _success(201, message, data);

  // ── Hata yanıtları ────────────────────────────────────────────────────────

  static Response badRequest([String message = 'Bad request']) =>
      _error(400, message);

  static Response unauthorized([String message = 'Unauthorized']) =>
      _error(401, message);

  static Response forbidden([String message = 'Forbidden']) =>
      _error(403, message);

  static Response notFound([String message = 'Not found']) =>
      _error(404, message);

  static Response conflict([String message = 'Conflict']) =>
      _error(409, message);

  static Response tooManyRequests([String message = 'Too many requests']) =>
      _error(429, message);

  static Response internalError([String message = 'Internal server error']) =>
      _error(500, message);

  // ── Private builders ──────────────────────────────────────────────────────

  static Response _success(int status, String message, Object? data) {
    return Response(
      status,
      body: _encode({'success': true, 'message': message, 'data': data}),
      headers: _headers,
    );
  }

  static Response _error(int status, String message) {
    return Response(
      status,
      body: _encode({'success': false, 'message': message}),
      headers: _headers,
    );
  }

  static String _encode(Object? value) => jsonEncode(value);
}
