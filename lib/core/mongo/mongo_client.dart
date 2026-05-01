import 'package:dart_backend/core/app_response.dart';
import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/errors.dart';
import 'package:mongo_dart/mongo_dart.dart';

final class MongoClient {
  MongoClient._(this._env);

  static MongoClient? _instance;
  factory MongoClient(EnvService env) {
    _instance ??= MongoClient._(env);
    return _instance!;
  }

  late final EnvService _env;
  Db? _db; // tek bağlantı burada saklanır

  Future<AppResponse<Db>> connect() async {
    if (_db != null && _db!.isConnected) {
      return AppResponse.success(_db!); // zaten açıksa tekrar açma
    }
    final db = Db(_env.dbUri);
    try {
      await db.open();
      _db = db;
      return AppResponse.success(_db!);
    } catch (e) {
      throw AppResponse.failure(DatabaseError());
    }
  }

  Db get db {
    assert(_db != null && _db!.isConnected, 'connect() önce çağrılmalı');
    return _db!;
  }

  Future<AppResponse> close() async {
    try {
      await _db?.close();
      _db = null;
      return AppResponse.success('MongoDB connection closed');
    } catch (e) {
      throw AppResponse.failure(DatabaseError());
    }
  }
}
