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
        await AuditLogController().insertLog(
          AuditLog(
            collection: 'Database',
            message: 'Database connection established.',
          ),
        );
      }
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
          collection: 'Database',
          message: 'Error connecting to database: $e',
          level: LogLevel.error,
        ),
      );
      rethrow;
    }
  }

  // Close to database
  Future<void> closeDb() async {
    try {
      await db.close();
      await AuditLogController().insertLog(
        AuditLog(
          collection: 'Database',
          message: 'Database connection closed.',
        ),
      );
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
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
            await AuditLogController().insertLog(
              AuditLog(
                collection: 'Database',
                message: 'Created collection: ${collectionName.name}',
              ),
            );
          }
        }
      }
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
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
    } catch (e) {
      await AuditLogController().insertLog(
        AuditLog(
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

  // Pagination method
  Future<ApiResponse<List<T>>> paginateData<T>(
    String collectionName, {
    required int page,
    required int limit,
    required String sort,
    required bool descending,
    required T Function(Map<String, dynamic>)
        fromJson, // JSON'dan T'ye dönüşüm fonksiyonu
  }) async {
    return handleDatabaseOperation(() async {
      final collection = db.collection(collectionName);

      final cursor = await collection
          .find(
            where
                .sortBy(
                  sort,
                  descending: descending,
                )
                .skip((page - 1) * limit)
                .limit(limit),
          )
          .toList();

      // JSON'dan model nesnesine dönüşüm
      final dataList = cursor.map(fromJson).toList();
      return dataList;
    });
  }

  DbCollection getCollection(String collectionPath) {
    return db.collection(collectionPath);
  }
}
