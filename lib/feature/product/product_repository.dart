import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/feature/product/models/product.dart';
import 'package:dart_backend/feature/product/product_collection.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class ProductRepository {
  final ProductCollection _collection;
  ProductRepository(this._collection);

  Future<AppResponse<Product>> create(Product product) =>
      _collection.create(product);

  Future<AppResponse<Product?>> getById(ObjectId id) =>
      _collection.getById(id);

  Future<AppResponse<List<Product>>> getByUserId(
    ObjectId userId, {
    int page = 1,
    int pageSize = 20,
  }) => _collection.getByUserId(userId, page: page, pageSize: pageSize);

  Future<AppResponse<List<Product>>> getAll({
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    bool descending = true,
  }) => _collection.getAll(
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        descending: descending,
      );

  Future<AppResponse<bool>> delete(ObjectId id) => _collection.delete(id);

  Future<AppResponse<bool>> updatePhotos(ObjectId id, List<String> photos) =>
      _collection.updatePhotos(id, photos);
}
