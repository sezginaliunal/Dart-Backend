import 'package:mongo_dart/mongo_dart.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/main.dart';

class MongoDatabase {
  factory MongoDatabase() => _instance;

  MongoDatabase._init() {
    _db = Db(_env.envConfig.db);
  }
  late Db _db;
  Db get db => _db;
  bool get isOpen => _db.isConnected;
  static final MongoDatabase _instance = MongoDatabase._init();
  final _env = Env();

  // Connect to database
  Future<void> connectDb() async {
    try {
      if (!db.isConnected) {
        await db.open();
        await autoMigrate();
        logger.i('Db açıldı');
      }
    } catch (e) {
      logger.e(e);
    }
  }

  // Close to database
  Future<void> closeDb() async {
    await db.close();
  }

  // Auto migrate for collections
  Future<void> autoMigrate() async {
    final collectionInfos = await db.getCollectionNames();
    for (final collectionInfo in collectionInfos) {
      for (final collectionName in CollectionPath.values) {
        if (!collectionInfo!.contains(collectionName.rawValue)) {
          await db.createCollection(collectionName.rawValue);
        }
      }
    }
  }
}
