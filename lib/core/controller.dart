import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/services/db/db.dart';

abstract class BaseController<T> {
  BaseController({required this.fromJson});
  final MongoDatabase db = MongoDatabase();
  late final CollectionPath collectionName;
  T Function(Map<String, dynamic>) fromJson;

  // Tek bir alan ve değere göre dökümant bulma (ör: email, id vb.)
  Future<ApiResponse<T?>> findOneByField(String field, dynamic value) async {
    try {
      final result = await db
          .getCollection(collectionName.name)
          .findOne(where.eq(field, value));
      if (result != null) {
        return ApiResponse(data: fromJson(result));
      }
      return ApiResponse(
        success: false,
        message: ResponseMessages.notFound.message,
        statusCode: HttpStatus.notFound,
      );
    } catch (_) {
      return ApiResponse(
        success: false,
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  // Genel listeleme, filtreleme ve sayfalama
  Future<ApiResponse<List<T>>> paginate({
    int? page,
    int? limit,
    bool? descending,
    SelectorBuilder? selector,
  }) async {
    return db.paginateData<T>(
      collectionName.name,
      fromJson: fromJson,
      page: page,
      limit: limit,
      descending: descending,
      selector: selector,
    );
  }

  // Filtrelenmiş sayfalama (birden fazla alan ile)
  Future<ApiResponse<List<T>>> paginateByFields({
    required Map<String, dynamic> queryFields,
    int? page,
    int? limit,
    String? sort,
    bool? descending,
  }) async {
    return db.paginateDataByFields<T>(
      collectionName.name,
      fromJson: fromJson,
      queryFields: queryFields,
      page: page,
      limit: limit,
      sort: sort,
      descending: descending,
    );
  }

  // Id veya başka bir alan ile sayfalama
  Future<ApiResponse<List<T>>> paginateByField({
    required String queryField,
    required dynamic value,
    int? page,
    int? limit,
    String? sort,
    bool? descending,
  }) async {
    return db.paginateDataById<T>(
      collectionName.name,
      fromJson: fromJson,
      queryField: queryField,
      value: value,
      page: page,
      limit: limit,
      sort: sort,
      descending: descending,
    );
  }

  // Belgeye push ekleme
  Future<Map<String, dynamic>> addDocument(
    dynamic idValue,
    String pushField,
    dynamic documentId,
  ) async {
    return db.addDocument(collectionName, idValue, pushField, documentId);
  }

  // Belgeden push çıkarma
  Future<Map<String, dynamic>> deleteDocument(
    dynamic idValue,
    String pushField,
    dynamic documentId,
  ) async {
    return db.deleteDocument(collectionName, idValue, pushField, documentId);
  }

  // Güncelleme işlemi için yardımcı fonksiyon
  Future<bool> updateField(String id, String field, dynamic value) async {
    final result = await db.getCollection(collectionName.name).updateOne(
          where.eq('_id', id),
          modify.set(field, value),
        );
    return result.nModified > 0;
  }
}
