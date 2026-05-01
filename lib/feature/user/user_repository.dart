import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/mongo/mongo_db_feature_repository.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_collection.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class UserRepository extends MongoDBFeatureRepository<User> {
  final UserCollection _collection;
  UserRepository(this._collection);

  @override
  Future<AppResponse<bool>> create(User item) => _collection.create(item);
  @override
  Future<AppResponse<bool>> delete(ObjectId id) => _collection.delete(id);
  @override
  Future<AppResponse<List<User>>> getAll() => _collection.getAll();
  @override
  Future<AppResponse<User?>> getById(ObjectId id) => _collection.getById(id);
  @override
  Future<AppResponse<bool>> exists(ObjectId id) => _collection.exists(id);
  @override
  Future<AppResponse<bool>> existsByName(String name) =>
      _collection.existsByName(name);
  @override
  Future<AppResponse<User?>> getByName(String name) =>
      _collection.getByName(name);
  @override
  Future<AppResponse<bool>> updateField(
    ObjectId id,
    String key,
    dynamic value,
  ) => _collection.updateField(id, key, value);
  @override
  Future<AppResponse<List<User>>> paginationList({
    int page = 1,
    int pageSize = 10,
    String sortBy = 'createdAt',
    bool descending = false,
  }) => _collection.paginationList(
    page: page,
    pageSize: pageSize,
    sortBy: sortBy,
    descending: descending,
  );

  Future<AppResponse<User?>> getByHexId(String hexId) =>
      _collection.getByHexId(hexId);
  Future<AppResponse<bool>> updateRole(ObjectId id, UserRole newRole) =>
      _collection.updateRole(id, newRole);
  Future<AppResponse<bool>> updateStatus(ObjectId id, UserStatus newStatus) =>
      _collection.updateStatus(id, newStatus);
  Future<AppResponse<bool>> updatePassword(ObjectId id, String newPasswordHash) =>
      _collection.updatePassword(id, newPasswordHash);
  Future<AppResponse<List<User>>> getByRole(UserRole role) =>
      _collection.getByRole(role);
  Future<AppResponse<List<User>>> getByStatus(UserStatus status) =>
      _collection.getByStatus(status);
}
