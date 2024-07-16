import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/config/load_env.dart';
import 'package:minersy_lite/config/constants/collections.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase extends IBaseDb {
  late Db _db;
  @override
  Db get db => _db;
  static final MongoDatabase _instance = MongoDatabase._init();
  final _env = Env();

  MongoDatabase._init() {
    _db = Db(_env.envConfig.db);
  }

  factory MongoDatabase() => _instance;

  // Connect to database
  @override
  Future<void> connectDb() async {
    await db.open();
    await autoMigrate();
  }

  // Close to database
  @override
  Future<void> closeDb() async {
    await db.close();
  }

  // Auto migrate for collections
  @override
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
  @override
  Future<bool> isDbOpen() async {
    return _db.isConnected;
  }

  // Check exist data
  @override
  Future<ResponseHandler> isItemExist(
      CollectionPath collectionName, String queryName, dynamic field) async {
    var result = await _db
        .collection(collectionName.rawValue)
        .findOne(where.eq(queryName, field));
    if (result != null) {
      return ResponseHandler(
          success: true, message: ResponseMessage.dataAlreadyExists);
    }
    return ResponseHandler(
        success: false, message: ResponseMessage.itemNotFound);
  }

  // Add Data
  @override
  Future<ResponseHandler> insertData(CollectionPath collectionName, String id,
      Map<String, dynamic> document) async {
    await _db.collection(collectionName.rawValue).insert(document);
    return ResponseHandler(
        success: true, data: document, message: ResponseMessage.itemAdded);
  }

  // Delete data
  @override
  Future<ResponseHandler> deleteData(
      CollectionPath collectionName, String id) async {
    final ResponseHandler<dynamic> isItemExistSuccess =
        await isItemExist(collectionName, '_id', id);

    if (isItemExistSuccess.success) {
      await _db.collection(collectionName.rawValue).deleteOne({'_id': id});
      return ResponseHandler(
          success: true, message: ResponseMessage.itemDeleted);
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  @override
  Future<ResponseHandler> updateOneData(CollectionPath collectionName,
      String id, String field, dynamic value) async {
    final ResponseHandler<dynamic> isItemExistSuccess =
        await isItemExist(collectionName, '_id', id);
    if (isItemExistSuccess.success) {
      await _db
          .collection(collectionName.rawValue)
          .updateOne(where.eq('_id', id), modify.set(field, value));
      return ResponseHandler(
          success: true, message: ResponseMessage.itemUpdated);
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  // Get Data
  @override
  Future<ResponseHandler> fetchOneData(
      CollectionPath collectionName, String field, dynamic value) async {
    final data = await _db
        .collection(collectionName.rawValue)
        .findOne(where.eq(field, value));

    if (data != null) {
      return ResponseHandler(success: true, data: data);
    }
    return ResponseHandler(message: ResponseMessage.itemNotFound);
  }

  @override
  Future<ResponseHandler> addDocument(
    CollectionPath collectionName,
    dynamic value,
    String pushField,
    String documentId,
  ) async {
    await _db.collection(collectionName.rawValue).update(
          where.eq('_id', value),
          modify.push(pushField, documentId),
        );
    return ResponseHandler(success: true, message: ResponseMessage.itemAdded);
  }

  // Delete a document from the transactions array
  @override
  Future<ResponseHandler> deleteDocument(CollectionPath collectionName,
      String id, String documentFieldName, String documentId) async {
    final ResponseHandler<dynamic> isItemExistSuccess =
        await isItemExist(collectionName, '_id', id);

    if (isItemExistSuccess.success) {
      await _db.collection(collectionName.rawValue).update(
          where.eq('_id', id), modify.pull(documentFieldName, documentId));
      return ResponseHandler(
          success: true, message: ResponseMessage.itemDeleted);
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  @override
  Future<ResponseHandler> fetchAllData(CollectionPath collectionName) async {
    final result =
        await _db.collection(collectionName.rawValue).find().toList();
    return ResponseHandler(
      success: true,
      data: result,
    );
  }
}
