import 'dart:io';

import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/file/file_storage.dart';
import 'package:dart_backend/core/jwt/jwt_collection.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/core/mongo/mongo_client.dart';
import 'package:dart_backend/core/mongo/mongo_indexes.dart';
import 'package:dart_backend/feature/product/product_collection.dart';
import 'package:dart_backend/feature/product/product_repository.dart';
import 'package:dart_backend/feature/user/user_collection.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_backend/server/app_server.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  // ── 1. Ortam değişkenleri ──────────────────────────────────────────────────
  final env = EnvService()..loadEnv();
  await env.loadKeys();

  // ── 2. Veritabanı bağlantısı ───────────────────────────────────────────────
  final mongo = MongoClient(env);
  final connectResult = await mongo.connect();

  if (connectResult.isFailure) {
    stderr.writeln('❌  DB bağlantısı kurulamadı: ${connectResult.error?.message}');
    exitCode = 1;
    return;
  }

  print('✅  MongoDB bağlandı → ${env.dbUri}');
  final db = mongo.db;

  // ── 3. MongoDB index'leri ──────────────────────────────────────────────────
  await ensureIndexes(db);

  // ── 4. Servisler ───────────────────────────────────────────────────────────
  final jwtService = JwtService(
    privateKey: RSAPrivateKey(env.jwtPrivateKey),
    publicKey: RSAPublicKey(env.jwtPublicKey),
  );

  // ── 5. Repository'ler ──────────────────────────────────────────────────────
  final userRepo = UserRepository(UserCollection(db));
  final jwtRepo = JwtRepository(JwtCollection(db, jwtService));
  final productRepo = ProductRepository(ProductCollection(db));

  // ── 6. File storage ────────────────────────────────────────────────────────
  final uploadsDir = p.join(
    File(Platform.script.toFilePath()).parent.parent.path,
    'uploads',
  );
  final fileStorage = LocalFileStorage(baseDir: uploadsDir);

  // ── 7. HTTP sunucusu ───────────────────────────────────────────────────────
  final server = await startServer(
    env: env,
    userRepo: userRepo,
    jwtRepo: jwtRepo,
    jwtService: jwtService,
    fileStorage: fileStorage,
    productRepo: productRepo,
  );

  // ── 8. Graceful shutdown ───────────────────────────────────────────────────
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑  Sunucu kapatılıyor...');
    await server.close(force: false);
    await mongo.close();
    print('👋  Bağlantılar kapatıldı. Çıkılıyor.');
    exit(0);
  });
}
