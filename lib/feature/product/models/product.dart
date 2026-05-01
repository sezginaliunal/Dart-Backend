import 'package:mongo_dart/mongo_dart.dart';

/// Kullanıcıya ait ürün.
///
/// Alanlar kasıtlı olarak minimal tutuldu (test amaçlı):
///   - title  : ürün adı
///   - userId : sahibinin ObjectId'si (foreign key)
///   - photos : birden fazla fotoğraf path'i (uploads/products/...)
///   - createdAt : oluşturulma zamanı (sıralama için)
final class Product {
  final ObjectId id;
  final String title;

  /// Ürünün sahibi — JWT payload'ından alınır.
  final ObjectId userId;

  /// Birden fazla fotoğraf desteklenir.
  /// Her eleman LocalFileStorage'dan dönen relative path'tir:
  ///   "products/1746123456789_ab12cd34.jpg"
  final List<String> photos;

  final DateTime createdAt;

  Product({
    ObjectId? id,
    required this.title,
    required this.userId,
    List<String>? photos,
    DateTime? createdAt,
  })  : id = id ?? ObjectId(),
        photos = photos ?? [],
        createdAt = createdAt ?? DateTime.now().toUtc();

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] as ObjectId,
      title: map['title'] as String,
      userId: map['userId'] as ObjectId,
      photos: List<String>.from(map['photos'] as List? ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        '_id': id,
        'title': title,
        'userId': userId,
        'photos': photos,
        'createdAt': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => {
        'id': id.oid,
        'title': title,
        'userId': userId.oid,
        'photos': photos,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'Product(id: $id, title: $title, userId: $userId, photos: ${photos.length})';
}
