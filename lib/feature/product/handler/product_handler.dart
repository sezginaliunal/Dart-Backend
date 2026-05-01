import 'dart:convert';

import 'package:dart_backend/core/file/multipart_parser.dart';
import 'package:dart_backend/core/utils/pagination.dart';
import 'package:dart_backend/feature/product/product_service.dart';
import 'package:dart_backend/server/handler/response_handler.dart';
import 'package:dart_backend/server/middleware/jwt_auth_middleware.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';

final class ProductHandler {
  final ProductService _productService;

  const ProductHandler({required ProductService productService})
      : _productService = productService;

  /// POST /products
  /// Content-Type: multipart/form-data
  /// Alanlar: title (text, zorunlu), photo (file, opsiyonel, max 5)
  Future<Response> create(Request req) async {
    final payload = req.jwtPayload;

    final fields = await MultipartParser.parse(req);
    if (fields.isEmpty) {
      return ResponseHandler.badRequest(
        'İstek multipart/form-data formatında olmalı',
      );
    }

    late ObjectId userId;
    try {
      userId = ObjectId.fromHexString(payload.id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final result = await _productService.create(fields: fields, userId: userId);
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.created(
      result.data!.toJson(),
      message: 'Ürün oluşturuldu',
    );
  }

  /// GET /products/me?page=1&pageSize=20
  Future<Response> myProducts(Request req) async {
    final payload = req.jwtPayload;

    late ObjectId userId;
    try {
      userId = ObjectId.fromHexString(payload.id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final params = PaginationParams.fromQuery(req.url.queryParameters);
    final result = await _productService.listByUser(
      userId,
      page: params.page,
      pageSize: params.pageSize,
    );
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(
      PaginationResponse.fromParams(result.data!, params)
          .toJson((p) => p.toJson()),
    );
  }

  /// GET /products?page=1&pageSize=20&sortBy=createdAt&desc=true — admin/moderatör
  Future<Response> listAll(Request req) async {
    final params = PaginationParams.fromQuery(req.url.queryParameters);
    final result = await _productService.listAll(
      page: params.page,
      pageSize: params.pageSize,
      sortBy: params.sortBy,
      descending: params.descending,
    );
    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(
      PaginationResponse.fromParams(result.data!, params)
          .toJson((p) => p.toJson()),
    );
  }

  /// POST /products/<id>/photos
  /// Content-Type: multipart/form-data
  /// Alanlar: photo (file, birden fazla olabilir)
  Future<Response> addPhotos(Request req, String id) async {
    final payload = req.jwtPayload;

    late ObjectId productId;
    try {
      productId = ObjectId.fromHexString(id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz ürün ID');
    }

    late ObjectId requesterId;
    try {
      requesterId = ObjectId.fromHexString(payload.id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final fields = await MultipartParser.parse(req);
    final photoFields = fields
        .whereType<FileField>()
        .where((f) => f.name == 'photo')
        .toList();

    if (photoFields.isEmpty) {
      return ResponseHandler.badRequest('"photo" alanında en az bir dosya gerekli');
    }

    final result = await _productService.addPhotos(
      productId: productId,
      photoFields: photoFields,
      requesterId: requesterId,
      isAdmin: payload.role.isStaff,
    );

    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(result.data!.toJson(), message: 'Fotoğraflar eklendi');
  }

  /// DELETE /products/<id>/photos
  /// Body: { "photoPath": "products/1746123456789_ab12cd34.jpg" }
  Future<Response> removePhoto(Request req, String id) async {
    final payload = req.jwtPayload;

    late ObjectId productId;
    try {
      productId = ObjectId.fromHexString(id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz ürün ID');
    }

    late ObjectId requesterId;
    try {
      requesterId = ObjectId.fromHexString(payload.id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz JSON formatı');
    }

    final photoPath = json['photoPath'] as String?;
    if (photoPath == null || photoPath.trim().isEmpty) {
      return ResponseHandler.badRequest('"photoPath" zorunlu');
    }

    final result = await _productService.removePhoto(
      productId: productId,
      photoPath: photoPath.trim(),
      requesterId: requesterId,
      isAdmin: payload.role.isStaff,
    );

    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(result.data!.toJson(), message: 'Fotoğraf silindi');
  }

  /// DELETE /products/<id>
  Future<Response> delete(Request req, String id) async {
    final payload = req.jwtPayload;

    late ObjectId productId;
    try {
      productId = ObjectId.fromHexString(id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz ürün ID');
    }

    late ObjectId requesterId;
    try {
      requesterId = ObjectId.fromHexString(payload.id);
    } catch (_) {
      return ResponseHandler.badRequest('Geçersiz kullanıcı ID');
    }

    final result = await _productService.delete(
      productId: productId,
      requesterId: requesterId,
      isAdmin: payload.role.isStaff,
    );

    if (result.isFailure) return ResponseHandler.fromAppResponse(result);

    return ResponseHandler.ok(null, message: 'Ürün silindi');
  }
}
