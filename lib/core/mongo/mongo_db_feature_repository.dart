import 'package:dart_backend/core/app_response.dart';
import 'package:mongo_dart/mongo_dart.dart';

// mongo_db_feature_repository.dart
abstract class MongoDBFeatureRepository<T> {
  Future<AppResponse<T?>> getById(ObjectId id);
  Future<AppResponse<T?>> getByName(String name);
  Future<AppResponse<List<T>>> getAll();
  Future<AppResponse<List<T>>> paginationList({
    int page = 1,
    int pageSize = 10,
    String sortBy = 'createdAt',
    bool descending = false,
  });
  Future<AppResponse<bool>> create(T item);
  Future<AppResponse<bool>> updateField(ObjectId id, String key, dynamic value);
  Future<AppResponse<bool>> delete(ObjectId id);
  Future<AppResponse<bool>> exists(ObjectId id);
  Future<AppResponse<bool>> existsByName(String name);
}
