import 'package:project_base/config/load_env.dart';
import 'package:project_base/config/constants/collections.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  late Db _db;
  Db get db => _db;
  static final MongoDatabase _instance = MongoDatabase._init();
  final _env = Env();

  MongoDatabase._init() {
    _db = Db(_env.envConfig.db);
  }

  factory MongoDatabase() => _instance;

  // Connect to database
  Future<void> connectDb() async {
    await db.open();
    await autoMigrate();
  }

  // Close to database
  Future<void> closeDb() async {
    await db.close();
  }

  // Auto migrate for collections
  Future<void> autoMigrate() async {
    var collectionInfos = await db.getCollectionNames();
    for (var collectionInfo in collectionInfos) {
      for (var collectionName in CollectionPath.values) {
        if (!collectionInfo!.contains(collectionName.rawValue)) {
          await db.createCollection(collectionName.rawValue);
        }
      }
    }
  }

  // Return bool value for db status
  Future<bool> isDbOpen() async {
    return _db.isConnected;
  }
}
