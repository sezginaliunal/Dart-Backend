import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/file/file_type.dart';
import 'package:dart_backend/core/file/file_validator.dart';
import 'package:dart_backend/core/file/multipart_parser.dart';
import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:dart_backend/feature/product/models/product.dart';
import 'package:dart_backend/feature/product/product_repository.dart';
import 'package:dart_backend/feature/product/product_upload_config.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Ürün iş mantığı.
///
/// Sahiplik kuralı:
///   - Ürünü sadece sahibi silebilir veya fotoğraf ekleyebilir.
///   - Admin bu kısıtın dışındadır (router'da kontrol edilir).
final class ProductService {
  final ProductRepository _repo;
  final FileStorage _fileStorage;

  ProductService({
    required ProductRepository repo,
    required FileStorage fileStorage,
  }) : _repo = repo,
       _fileStorage = fileStorage;

  // ── Oluşturma ─────────────────────────────────────────────────────────────

  /// Multipart alanlarından ürün oluşturur ve fotoğrafları kaydeder.
  ///
  /// Zorunlu alan : `title` (TextField)
  /// Opsiyonel    : `photo` (FileField, birden fazla olabilir, max [productMaxPhotos])
  Future<AppResponse<Product>> create({
    required List<MultipartField> fields,
    required ObjectId userId,
  }) async {
    // 1. Title al
    final title = fields
        .whereType<TextField>()
        .where((f) => f.name == 'title')
        .firstOrNull
        ?.value
        .trim();

    if (title == null || title.isEmpty) {
      return AppResponse.failure(const BadRequestError());
    }

    // 2. Fotoğrafları işle
    final photoFields = fields
        .whereType<FileField>()
        .where((f) => f.name == 'photo')
        .toList();

    if (photoFields.length > productMaxPhotos) {
      return AppResponse.failure(
        CustomError('En fazla $productMaxPhotos fotoğraf yüklenebilir'),
      );
    }

    // 3. Her fotoğrafı doğrula
    for (final photo in photoFields) {
      final error = FileValidator.validate(
        bytes: photo.bytes,
        mimeType: photo.mimeType,
        config: productPhotoUploadConfig,
      );
      if (error != null) return AppResponse.failure(CustomError(error));
    }

    // 4. Geçerli fotoğrafları diske kaydet
    final savedPaths = <String>[];
    try {
      for (final photo in photoFields) {
        final fileType = FileType.fromMime(photo.mimeType)!;
        final path = await _fileStorage.save(
          bytes: photo.bytes,
          fileType: fileType,
          config: productPhotoUploadConfig,
        );
        savedPaths.add(path);
      }
    } catch (e, st) {
      AppLogger.error(
        'Ürün fotoğrafı kaydedilemedi',
        error: e,
        stackTrace: st,
        context: 'userId=$userId',
      );
      // Kısmen kaydedilenleri temizle (orphan önlemi)
      for (final path in savedPaths) {
        await _fileStorage.delete(path);
      }
      return AppResponse.failure(const DatabaseError());
    }

    // 5. DB'ye kaydet
    final product = Product(title: title, userId: userId, photos: savedPaths);

    final result = await _repo.create(product);
    if (result.isFailure) {
      AppLogger.error(
        'Ürün DB\'ye kaydedilemedi',
        context: 'userId=$userId title=$title',
      );
      // DB başarısız → dosyaları temizle
      for (final path in savedPaths) {
        await _fileStorage.delete(path);
      }
      return AppResponse.failure(result.error!);
    }

    return AppResponse.success(result.data!);
  }

  // ── Listeleme ─────────────────────────────────────────────────────────────

  /// Kullanıcıya ait ürünleri listeler.
  Future<AppResponse<List<Product>>> listByUser(
    ObjectId userId, {
    int page = 1,
    int pageSize = 20,
  }) => _repo.getByUserId(userId, page: page, pageSize: pageSize);

  /// Tüm ürünler (admin).
  Future<AppResponse<List<Product>>> listAll({
    int page = 1,
    int pageSize = 20,
    String sortBy = 'createdAt',
    bool descending = true,
  }) => _repo.getAll(
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        descending: descending,
      );

  // ── Fotoğraf ekleme ───────────────────────────────────────────────────────

  /// Var olan ürüne yeni fotoğraflar ekler.
  ///
  /// [requesterId] : isteği yapan kullanıcı (JWT'den)
  /// [isAdmin]     : admin ise sahiplik kontrolü atlanır
  Future<AppResponse<Product>> addPhotos({
    required ObjectId productId,
    required List<FileField> photoFields,
    required ObjectId requesterId,
    bool isAdmin = false,
  }) async {
    // Ürünü getir
    final productResult = await _repo.getById(productId);
    if (productResult.isFailure || productResult.data == null) {
      return AppResponse.failure(const NotFoundError());
    }

    final product = productResult.data!;

    // Sahiplik kontrolü
    if (!isAdmin && product.userId != requesterId) {
      return AppResponse.failure(const ForbiddenError());
    }

    // Toplam fotoğraf limiti
    final remaining = productMaxPhotos - product.photos.length;
    if (remaining <= 0) {
      return AppResponse.failure(
        CustomError('Ürün zaten $productMaxPhotos fotoğrafa ulaştı'),
      );
    }

    final toAdd = photoFields.take(remaining).toList();

    // Doğrula
    for (final photo in toAdd) {
      final error = FileValidator.validate(
        bytes: photo.bytes,
        mimeType: photo.mimeType,
        config: productPhotoUploadConfig,
      );
      if (error != null) return AppResponse.failure(CustomError(error));
    }

    // Kaydet
    final newPaths = <String>[];
    try {
      for (final photo in toAdd) {
        final fileType = FileType.fromMime(photo.mimeType)!;
        final path = await _fileStorage.save(
          bytes: photo.bytes,
          fileType: fileType,
          config: productPhotoUploadConfig,
        );
        newPaths.add(path);
      }
    } catch (_) {
      for (final path in newPaths) {
        await _fileStorage.delete(path);
      }
      return AppResponse.failure(const DatabaseError());
    }

    final updatedPhotos = [...product.photos, ...newPaths];
    final updateResult = await _repo.updatePhotos(productId, updatedPhotos);
    if (updateResult.isFailure) {
      for (final path in newPaths) {
        await _fileStorage.delete(path);
      }
      return AppResponse.failure(updateResult.error!);
    }

    final updated = Product(
      id: product.id,
      title: product.title,
      userId: product.userId,
      photos: updatedPhotos,
      createdAt: product.createdAt,
    );

    return AppResponse.success(updated);
  }

  // ── Silme ─────────────────────────────────────────────────────────────────

  /// Ürünü ve tüm fotoğraflarını siler.
  Future<AppResponse<bool>> delete({
    required ObjectId productId,
    required ObjectId requesterId,
    bool isAdmin = false,
  }) async {
    final productResult = await _repo.getById(productId);
    if (productResult.isFailure || productResult.data == null) {
      return AppResponse.failure(const NotFoundError());
    }

    final product = productResult.data!;

    if (!isAdmin && product.userId != requesterId) {
      return AppResponse.failure(const ForbiddenError());
    }

    // Önce DB'den sil
    final deleteResult = await _repo.delete(productId);
    if (deleteResult.isFailure) return deleteResult;

    // Sonra dosyaları temizle (best effort)
    for (final path in product.photos) {
      await _fileStorage.delete(path);
    }

    return AppResponse.success(true);
  }

  /// Üründen tek bir fotoğrafı siler.
  /// [photoPath] : photos listesindeki değer (örn. "products/1746_ab12.jpg")
  Future<AppResponse<Product>> removePhoto({
    required ObjectId productId,
    required String photoPath,
    required ObjectId requesterId,
    bool isAdmin = false,
  }) async {
    final productResult = await _repo.getById(productId);
    if (productResult.isFailure || productResult.data == null) {
      return AppResponse.failure(const NotFoundError());
    }

    final product = productResult.data!;

    // Sahiplik kontrolü
    if (!isAdmin && product.userId != requesterId) {
      return AppResponse.failure(const ForbiddenError());
    }

    // Listede var mı?
    if (!product.photos.contains(photoPath)) {
      return AppResponse.failure(const NotFoundError());
    }

    final updatedPhotos = product.photos.where((p) => p != photoPath).toList();

    final updateResult = await _repo.updatePhotos(productId, updatedPhotos);
    if (updateResult.isFailure) {
      return AppResponse.failure(updateResult.error!);
    }

    // Dosyayı diskten sil
    await _fileStorage.delete(photoPath);

    final updated = Product(
      id: product.id,
      title: product.title,
      userId: product.userId,
      photos: updatedPhotos,
      createdAt: product.createdAt,
    );

    return AppResponse.success(updated);
  }
}
