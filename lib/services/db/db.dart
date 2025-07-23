import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/controllers/auditlog_controller.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/audit_log.dart';

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

  // Connect to database
  Future<void> connectDb() async {
    try {
      if (!db.isConnected) {
        await db.open();
        await autoMigrate();
      }
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'Database',
          message: 'Error connecting to database: $e',
          level: LogLevel.error,
        ),
      );
      rethrow;
    }
  }

  Future<void> dropAllIndexes(String collectionName) async {
    final collection = db.collection(collectionName);
    final existingIndexes = await collection.getIndexes();

    for (final index in existingIndexes) {
      final indexName = index['name'];
      if (indexName != '_id_') {
        // _id indexi MongoDB'nin default indexidir, silinemez
        await collection.dropIndexes(index['name'] as String);
      }
    }
  }

  // Close to database
  Future<void> closeDb() async {
    try {
      await db.close();
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'Database',
          message: 'Database connection closed.',
        ),
      );
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'Database',
          message: 'Error closing database connection: $e',
          level: LogLevel.error,
        ),
      );
      rethrow;
    }
  }

  // Auto migrate for collections
  Future<void> autoMigrate() async {
    try {
      final collectionInfos = await db.getCollectionNames();
      for (final collectionInfo in collectionInfos) {
        for (final collectionName in CollectionPath.values) {
          if (!collectionInfo!.contains(collectionName.name)) {
            await db.createCollection(collectionName.name);
          }
        }
      }
      for (final collectionName in CollectionPath.values) {
        await ensureCounterInitialized(collectionName.name);
      }
      await AuditLogController().insertLog(
        AuditLog(
          collection: 'Database',
          message: 'Created collections',
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'Database',
          message: 'Error during auto migration: $e',
          level: LogLevel.error,
        ),
      );
      rethrow;
    }
  }

  Future<ApiResponse<T>> handleDatabaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      // Eğer result bir liste ise ve boşsa
      if (result is List && result.isEmpty || result == null) {
        return ApiResponse<T>(
          message: ResponseMessages.notFound.message,
          statusCode: HttpStatus.notFound,
        );
      }
      return ApiResponse(data: result);
    } on Exception catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'Database',
          message: 'Error during database operation: $e',
          level: LogLevel.error,
        ),
      );
      return ApiResponse(
        message: ResponseMessages.somethingError.message,
        statusCode: HttpStatus.internalServerError,
      );
    }
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

      // Eğer hem page hem limit null ise tüm veriyi getir
      late List<Map<String, dynamic>> rawCursor;

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
        try {
          final item = fromJson(e);
          if (item != null) dataList.add(item);
        } catch (err) {
          print('⚠️ JSON parse hatası: $err\nVeri: $e');
          continue;
        }
      }

      return dataList;
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

      final currentPage = page ?? 1;
      final currentLimit = limit ?? 10;

      print('paginateDataById - page: $currentPage, limit: $currentLimit');

      // ID'ye göre filtreleme
      final query = where.eq(queryField, value);

      final cursor = await collection
          .find(
            query
                .sortBy(sort ?? '_id', descending: descending ?? false)
                .skip((currentPage - 1) * currentLimit)
                .limit(currentLimit),
          )
          .toList();

      print('Returned records count: ${cursor.length}');

      final dataList = cursor.map(fromJson).toList();

      return dataList;
    });
  }

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

  DbCollection getCollection(String collectionPath) {
    return db.collection(collectionPath);
  }

  Future<void> createIndexIfNotExists({
    required String collectionName,
    required Map<String, dynamic> keys,
    String? indexName,
    Map<String, dynamic>? partialFilterExpression,
  }) async {
    final collection = db.collection(collectionName);
    final existingIndexes = await collection.getIndexes();

    // Mevcut indexlerle birebir aynı olan var mı?
    final alreadyExists = existingIndexes.any((index) {
      // 'key' dinamik olduğu için Map<dynamic, dynamic> olarak işleyelim
      final indexKeys = index['key'] is Map
          ? Map<String, dynamic>.from(index['key'] as Map)
          : {'': ''}; // Eğer 'key' bir Map değilse boş bir Map

      final indexFilter =
          index['partialFilterExpression'] as Map<String, dynamic>?;

      // Aynı keys ve filter varsa
      final sameKeys = indexKeys == keys;
      final sameFilter = indexFilter == partialFilterExpression;

      return sameKeys && sameFilter;
    });

    if (alreadyExists) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          collection: collectionName,
          message: 'Index already exists with same keys & filter. Skipping.',
          createdAt: DateTime.now(),
        ),
      );
      return;
    }

    // Oluşturulacak index adı
    String generateIndexName(
      Map<String, dynamic> keys,
      Map<String, dynamic>? filter,
    ) {
      final keyString =
          keys.entries.map((e) => '${e.key}_${e.value}').join('_');

      if (filter != null && filter.isNotEmpty) {
        final filterString =
            filter.entries.map((e) => '${e.key}_${e.value}').join('_');
        return '${keyString}_filtered_${filterString.hashCode}';
      }

      return keyString;
    }

    final generatedName =
        indexName ?? generateIndexName(keys, partialFilterExpression);

    // Oluştur
    await collection.createIndex(
      keys: keys,
      name: generatedName,
      partialFilterExpression: partialFilterExpression,
      background: true,
    );
    await AuditLogController().insertLog(
      AuditLog(
        id: await getNextStringSequenceId(CollectionPath.audit_log.name),
        collection: collectionName,
        message: 'Created index: $generatedName',
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<String> getNextStringSequenceId(String collectionName) async {
    try {
      final counters = db.collection('counters');

      final result = await counters.findAndModify(
        query: where.eq('_id', collectionName),
        update: ModifierBuilder().inc('seq', 1),
        returnNew: true,
        upsert: true,
      );

      if (result == null || result['seq'] == null) {
        return '0';
      }

      return result['seq'].toString();
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'counters',
          message: 'Auto-increment ID error: $e',
          level: LogLevel.error,
        ),
      );
      // Hata olsa bile exception atmadan default '0' dön
      return '0';
    }
  }

  Future<void> ensureCounterInitialized(String collectionName) async {
    final counters = db.collection('counters');

    final exists = await counters.findOne(where.eq('_id', collectionName));

    if (exists == null) {
      await counters.insertOne({
        '_id': collectionName,
        'seq': 0,
      });

      await AuditLogController().insertLog(
        AuditLog(
          id: await getNextStringSequenceId(CollectionPath.audit_log.name),
          createdAt: DateTime.now(),
          collection: 'counters',
          message: 'Counter initialized for $collectionName',
        ),
      );
    }
  }
}
