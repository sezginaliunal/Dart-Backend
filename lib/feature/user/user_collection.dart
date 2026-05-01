import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/mongo/mongo_collection.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class UserCollection extends MongoCollection {
  UserCollection(Db db) : super(db, 'users');

  Future<AppResponse<bool>> create(User item) async {
    final isExist = await existsByName(item.name);
    if (isExist.data == true) {
      return AppResponse.failure(const ConflictError());
    }
    final res = await insertOne(item.toMap());
    return AppResponse.success(res.isSuccess);
  }

  Future<AppResponse<bool>> delete(ObjectId id) async {
    final res = await deleteOne(where.id(id));
    return AppResponse.success(res.isSuccess);
  }

  Future<AppResponse<List<User>>> getAll() async {
    final res = await find().toList();
    if (res.isEmpty) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(res.map(User.fromMap).toList());
  }

  Future<AppResponse<User?>> getById(ObjectId id) async {
    final res = await findOne(where.id(id));
    if (res == null) return AppResponse.success(null);
    return AppResponse.success(User.fromMap(res));
  }

  Future<AppResponse<User?>> getByHexId(String hexId) async {
    late ObjectId oid;
    try {
      oid = ObjectId.fromHexString(hexId);
    } catch (_) {
      return AppResponse.failure(const BadRequestError());
    }
    return getById(oid);
  }

  Future<AppResponse<bool>> exists(ObjectId id) async {
    final res = await getById(id);
    return AppResponse.success(res.data != null);
  }

  Future<AppResponse<User?>> getByName(String name) async {
    final res = await findOne(where.eq('name', name));
    if (res == null) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(User.fromMap(res));
  }

  Future<AppResponse<bool>> existsByName(String name) async {
    final res = await findOne(where.eq('name', name));
    return AppResponse.success(res != null);
  }

  Future<AppResponse<bool>> updateField(
    ObjectId id,
    String key,
    dynamic value,
  ) async {
    final res = await updateOne(where.id(id), modify.set(key, value));
    if (res.nModified == 0) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(true);
  }

  Future<AppResponse<bool>> updateRole(ObjectId id, UserRole newRole) async {
    final res = await updateOne(
      where.id(id),
      modify.set('role', newRole.value),
    );
    if (res.nModified == 0) return AppResponse.failure(const NotUpdated());
    return AppResponse.success(true);
  }

  /// Status değişince tokenVersion arttırılır → eski JWT'ler geçersiz olur.
  Future<AppResponse<bool>> updateStatus(
    ObjectId id,
    UserStatus newStatus,
  ) async {
    final res = await updateOne(
      where.id(id),
      modify.set('status', newStatus.value).inc('tokenVersion', 1),
    );
    if (res.nModified == 0) return AppResponse.failure(const NotUpdated());
    return AppResponse.success(true);
  }

  /// Şifre değişince tokenVersion arttırılır → eski JWT'ler geçersiz olur.
  Future<AppResponse<bool>> updatePassword(
    ObjectId id,
    String newPasswordHash,
  ) async {
    final res = await updateOne(
      where.id(id),
      modify.set('passwordHash', newPasswordHash).inc('tokenVersion', 1),
    );
    if (res.nModified == 0) return AppResponse.failure(const NotUpdated());
    return AppResponse.success(true);
  }

  Future<AppResponse<List<User>>> getByRole(UserRole role) async {
    final res = await find(where.eq('role', role.value)).toList();
    if (res.isEmpty) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(res.map(User.fromMap).toList());
  }

  Future<AppResponse<List<User>>> getByStatus(UserStatus status) async {
    final res = await find(where.eq('status', status.value)).toList();
    if (res.isEmpty) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(res.map(User.fromMap).toList());
  }

  Future<AppResponse<List<User>>> paginationList({
    int page = 1,
    int pageSize = 10,
    String sortBy = 'createdAt',
    bool descending = false,
  }) async {
    final skip = (page - 1) * pageSize;
    final res = await find(
      where.sortBy(sortBy, descending: descending).skip(skip).limit(pageSize),
    ).toList();
    if (res.isEmpty) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(res.map(User.fromMap).toList());
  }
}
