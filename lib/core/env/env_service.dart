import 'dart:io';

import 'package:dotenv/dotenv.dart';

final class _AppKeys {
  static const privateKey = 'assets/private.pem';
  static const publicKey = 'assets/public.pem';
}

enum Environment {
  host(name: 'DB_HOST'),
  port(name: 'DB_PORT'),
  dbName(name: 'DB_NAME'),
  jwtAccessTokenExpiresIn(name: 'JWT_ACCESS_TOKEN_EXPIRES_IN'),
  jwtRefreshTokenExpiresIn(name: 'JWT_REFRESH_TOKEN_EXPIRES_IN'),
  serverHost(name: 'SERVER_HOST'),
  serverPort(name: 'SERVER_PORT');

  final String name;
  const Environment({required this.name});
}

final class EnvService {
  late final DotEnv _dotenv;
  String? _privateKey;
  String? _publicKey;

  void loadEnv() {
    _dotenv = DotEnv()..load();
  }

  String? get(Environment key) => _dotenv[key.name.toUpperCase()];

  String get host => get(Environment.host) ?? 'localhost';
  int get dbPort => int.tryParse(get(Environment.port) ?? '27017') ?? 27017;
  String get dbName => get(Environment.dbName) ?? 'my_database';
  String get dbUri => 'mongodb://$host:$dbPort/$dbName';

  // HTTP Server ayarları
  String get serverHost => get(Environment.serverHost) ?? '0.0.0.0';
  int get serverPort =>
      int.tryParse(get(Environment.serverPort) ?? '8080') ?? 8080;

  // JWT süreleri env'den okunur, yoksa default değer kullanılır
  Duration get accessTokenExpiry => Duration(
    minutes:
        int.tryParse(get(Environment.jwtAccessTokenExpiresIn) ?? '15') ?? 15,
  );

  Duration get refreshTokenExpiry => Duration(
    days: int.tryParse(get(Environment.jwtRefreshTokenExpiresIn) ?? '7') ?? 7,
  );

  Future<String> _readFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Dosya bulunamadı: $filePath');
    }
    return file.readAsString();
  }

  Future<void> loadKeys() async {
    _privateKey = await _readFile(_AppKeys.privateKey);
    _publicKey = await _readFile(_AppKeys.publicKey);
  }

  String get jwtPrivateKey {
    if (_privateKey == null) {
      throw StateError('Private key yüklenmedi. Önce loadKeys() çağır.');
    }
    return _privateKey!;
  }

  String get jwtPublicKey {
    if (_publicKey == null) {
      throw StateError('Public key yüklenmedi. Önce loadKeys() çağır.');
    }
    return _publicKey!;
  }
}
