import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/mongo/mongo_collection.dart';
import 'package:dart_backend/feature/product/models/product.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class ProductCollection extends MongoCollection {
  ProductCollection(Db db) : super(db, 'products');

  /// Ürün oluştur.
  Future<AppResponse<Product>> create(Product product) async {
    final res = await insertOne(product.toMap());
    if (!res.isSuccess) return AppResponse.failure(const DatabaseError());
    return AppResponse.success(product);
  }

  /// ID ile getir.
  Future<AppResponse<Product?>> getById(ObjectId id) async {
    final res = await findOne(where.id(id));
    if (res == null) return AppResponse.success(null);
    return AppResponse.success(Product.fromMap(res));
  }

  /// Kullanıcıya ait ürünleri sayfalı getir — en yeni önce.
  Future<AppResponse<List<Product>>> getByUserId(
    ObjectId userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final skip = (page - 1) * pageSize;
    final res = await find(
      where
          .eq('userId', userId)
          .sortBy('createdAt', descending: true)
          .skip(skip)
          .limit(pageSize),
    ).toList();
    return AppResponse.success(res.map(Product.fromMap).toList());
  }

  /// Tüm ürünler sayfalı — admin için.
  Future<AppResponse<List<Product>>> getAll({
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    bool descending = true,
  }) async {
    final skip = (page - 1) * pageSize;
    final res = await find(
      where
          .sortBy(sortBy, descending: descending)
          .skip(skip)
          .limit(pageSize),
    ).toList();
    return AppResponse.success(res.map(Product.fromMap).toList());
  }

  /// Ürünü sil.
  Future<AppResponse<bool>> delete(ObjectId id) async {
    final res = await deleteOne(where.id(id));
    if (res.nRemoved == 0) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(true);
  }

  /// Fotoğraf listesini güncelle.
  Future<AppResponse<bool>> updatePhotos(
    ObjectId id,
    List<String> photos,
  ) async {
    final res = await updateOne(
      where.id(id),
      modify.set('photos', photos),
    );
    if (res.nModified == 0) return AppResponse.failure(const NotFoundError());
    return AppResponse.success(true);
  }
}
