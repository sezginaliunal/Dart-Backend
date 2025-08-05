import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/api_response.dart';

class MongoDatabase {
  factory MongoDatabase() => _instance;

  MongoDatabase._init() {
    _db = Db(_env.envConfig.db);
  }
  late Db _db;
  Db get db => _db;
  bool get isOpen => _db.isConnected;
  static final MongoDatabase _instance = MongoDatabase._init();
  final _env = Env();
  DbCollection getCollection(String collectionName) {
    return db.collection(collectionName);
  }

  // Connect to database
  Future<void> connectDb() async {
    if (!db.isConnected) {
      await db.open();
      await autoMigrate();
    }
  }

  // Close to database
  Future<void> closeDb() async {
    await db.close();
  }

  // Auto migrate for collections
  Future<void> autoMigrate() async {
    final collectionInfos = await db.getCollectionNames();
    for (final collectionInfo in collectionInfos) {
      for (final collectionName in CollectionPath.values) {
        if (!collectionInfo!.contains(collectionName.name)) {
          await db.createCollection(collectionName.name);
        }
      }
    }
  }

  Future<ApiResponse<T>> handleDatabaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      if (result is List && result.isEmpty || result == null) {
        return ApiResponse<T>(
          message: ResponseMessages.notFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
      return ApiResponse(data: result);
    } on Exception catch (_) {
      return ApiResponse(
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

//Queries
  Future<ApiResponse<T?>> findOneByField<T>({
    required CollectionPath collectionPath,
    required String field,
    required dynamic value,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final result = await getCollection(collectionPath.name)
        .findOne(where.eq(field, value));
    if (result != null) {
      final data = fromJson(result);
      return ApiResponse<T?>(data: data);
    }
    return ApiResponse<T?>(
      success: false,
      message: ResponseMessages.notFound.message,
      statusCode: HttpStatus.notFound,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> insert({
    required CollectionPath collectionPath,
    required Map<String, dynamic> document,
  }) async {
    final result = await getCollection(collectionPath.name).insert(document);

    return ApiResponse<Map<String, dynamic>>(data: result);
  }

// Pagination method
  Future<ApiResponse<List<T>>> paginateData<T>(
    String collectionName, {
    required T Function(Map<String, dynamic>) fromJson,
    int? page,
    int? limit,
    bool? descending,
    SelectorBuilder? selector,
  }) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);
      final filter = selector ?? where;

      List<Map<String, dynamic>> rawCursor;

      // page ve limit verilmemiş ise tüm kayıtları getir
      if (page == null && limit == null) {
        rawCursor = await collection
            .find(filter.sortBy('_id', descending: descending ?? false))
            .toList();
      } else {
        final currentPage = page ?? 1;
        final currentLimit = limit ?? 10;

        rawCursor = await collection
            .find(
              filter
                  .sortBy('_id', descending: descending ?? false)
                  .skip((currentPage - 1) * currentLimit)
                  .limit(currentLimit),
            )
            .toList();
      }

      final dataList = <T>[];
      for (final e in rawCursor) {
        final item = fromJson(e);
        if (item != null) dataList.add(item);
      }

      return dataList;
    });
  }

  Future<ApiResponse<List<T>>> paginateDataByFields<T>(
    String collectionName, {
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> queryFields,
    int? page,
    int? limit,
    String? sort,
    bool? descending,
  }) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      final currentPage = page ?? 1;
      final currentLimit = limit ?? 10;

      // Doğru filtre zincirleme
      var query = where;
      queryFields.forEach((key, value) {
        if (value != null && value.toString().trim().isNotEmpty) {
          query = query.eq(key, value); // <- ZİNCİRLE!
        }
      });

      final cursor = await collection
          .find(
            query
                .sortBy(sort ?? '_id', descending: descending ?? false)
                .skip((currentPage - 1) * currentLimit)
                .limit(currentLimit),
          )
          .toList();

      final dataList = cursor.map(fromJson).toList();

      return dataList;
    });
  }

//Bulk Operations
  Future<ApiResponse<void>> bulkInsert(
    String collectionName,
    List<Map<String, dynamic>> documents,
  ) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      // insertMany bulk işlemi bekler, her belge Map olmalı
      await collection.bulkWrite(
        documents
            .map((doc) => {
                  'insertOne': {'document': doc}
                })
            .toList(),
      );
    });
  }

  Future<ApiResponse<void>> bulkDelete(
    String collectionName,
    List<Map<String, dynamic>> filters,
  ) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      // deleteOne bulk işlemi için filtre listesi ile
      await collection.bulkWrite(
        filters
            .map((filter) => {
                  'deleteOne': {'filter': filter}
                })
            .toList(),
      );
    });
  }

  Future<ApiResponse<void>> bulkUpdate(
    String collectionName,
    List<Map<String, dynamic>> updates,
  ) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      // bulkWrite için formatlama yapıyoruz:
      final bulkOperations = updates.map((updateMap) {
        return {
          'updateOne': {
            'filter': updateMap['filter'] as Map<String, dynamic>,
            'update': updateMap['update'] as Map<String, dynamic>,
            if (updateMap.containsKey('upsert')) 'upsert': updateMap['upsert'],
          }
        };
      }).toList();

      await collection.bulkWrite(bulkOperations);
    });
  }

  Future<ApiResponse<List<T>>> paginateDataById<T>(
    String collectionName, {
    required T Function(Map<String, dynamic>) fromJson,
    required dynamic value,
    required String queryField,
    int? page,
    int? limit,
    String? sort,
    bool? descending,
  }) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      // ID'ye göre filtreleme
      final query = where.eq(queryField, value);

      // Eğer page ve limit verilmemişse, tüm sonuçları getir
      List<Map<String, dynamic>> cursor;
      if (page == null && limit == null) {
        cursor = await collection
            .find(query.sortBy(sort ?? '_id', descending: descending ?? false))
            .toList();
      } else {
        final currentPage = page ?? 1;
        final currentLimit = limit ?? 10;

        cursor = await collection
            .find(
              query
                  .sortBy(sort ?? '_id', descending: descending ?? false)
                  .skip((currentPage - 1) * currentLimit)
                  .limit(currentLimit),
            )
            .toList();
      }

      final dataList = cursor.map(fromJson).toList();

      return dataList;
    });
  }

//Document Operations
  Future<Map<String, dynamic>> addDocument(
    CollectionPath collectionName,
    dynamic value,
    String pushField,
    dynamic documentId,
  ) async {
    return getCollection(collectionName.name).update(
      where.eq('_id', value),
      modify.push(pushField, documentId),
    );
  }

  Future<Map<String, dynamic>> deleteDocument(
    CollectionPath collectionName,
    dynamic value,
    String pushField,
    dynamic documentId,
  ) async {
    return getCollection(collectionName.name).update(
      where.eq('_id', value),
      modify.pull(pushField, documentId),
    );
  }
}
