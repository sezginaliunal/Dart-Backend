import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/mongo/mongo_db_feature_repository.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_collection.dart';

final class UserRepository extends MongoDBFeatureRepository<User> {
  final UserCollection _collection;
  UserRepository(this._collection);

  @override
  Future<AppResponse<bool>> create(User item) => _collection.create(item);
  @override
  Future<AppResponse<bool>> delete(String id) => _collection.delete(id);
  @override
  Future<AppResponse<List<User>>> getAll() => _collection.getAll();
  @override
  Future<AppResponse<User?>> getById(String id) => _collection.getById(id);
  @override
  Future<AppResponse<bool>> exists(String id) => _collection.exists(id);
  @override
  Future<AppResponse<bool>> existsByName(String name) =>
      _collection.existsByName(name);
  @override
  Future<AppResponse<User?>> getByName(String name) =>
      _collection.getByName(name);
  @override
  Future<AppResponse<bool>> updateField(String id, String key, dynamic value) =>
      _collection.updateField(id, key, value);
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

  Future<AppResponse<bool>> updateRole(String id, UserRole newRole) =>
      _collection.updateRole(id, newRole);
  Future<AppResponse<bool>> updateStatus(String id, UserStatus newStatus) =>
      _collection.updateStatus(id, newStatus);
  Future<AppResponse<bool>> updatePassword(String id, String newPasswordHash) =>
      _collection.updatePassword(id, newPasswordHash);
  Future<AppResponse<List<User>>> getByRole(UserRole role) =>
      _collection.getByRole(role);
  Future<AppResponse<List<User>>> getByStatus(UserStatus status) =>
      _collection.getByStatus(status);
}
