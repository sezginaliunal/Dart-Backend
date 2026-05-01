import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Uygulama başlarken gerekli MongoDB index'lerini oluşturur.
///
/// `createIndex` var olan bir index'i tekrar oluşturmaz — idempotent.
/// Her yeni collection/field için buraya ekleme yap.
Future<void> ensureIndexes(Db db) async {
  try {
    // ── users ──────────────────────────────────────────────────────────────
    final users = db.collection('users');

    // Login sorgusu: where.eq('name', name) → unique + hızlı arama
    await users.createIndex(keys: {'name': 1}, unique: true);

    // Status + role bazlı filtreleme (admin paneli için)
    await users.createIndex(keys: {'status': 1});
    await users.createIndex(keys: {'role': 1});

    // ── tokens ─────────────────────────────────────────────────────────────
    final tokens = db.collection('tokens');

    // Refresh token hash arama
    await tokens.createIndex(keys: {'refreshTokenHash': 1}, unique: true);

    // Kullanıcının tokenlarını temizleme (logout)
    await tokens.createIndex(keys: {'userId': 1});

    // ── products ───────────────────────────────────────────────────────────
    final products = db.collection('products');

    // Kullanıcının ürünlerini listeleme — en çok çalışan sorgu
    await products.createIndex(keys: {'userId': 1, 'createdAt': -1});

    // Admin: tüm ürünler en yeni önce
    await products.createIndex(keys: {'createdAt': -1});

    AppLogger.info('MongoDB index\'leri hazır');
  } catch (e, st) {
    // Index oluşturma başarısız olursa sunucuyu durdurma — warn yeterli
    AppLogger.error('Index oluşturma hatası', error: e, stackTrace: st);
  }
}
