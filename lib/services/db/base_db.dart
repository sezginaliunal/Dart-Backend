import 'package:minersy_lite/config/constants/collections.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';
import 'package:mongo_dart/mongo_dart.dart';

abstract class IBaseDb {
  late Db db;
  Future<void> connectDb();
  Future<void> closeDb();
  Future<void> autoMigrate();
  Future<bool> isDbOpen();
  Future<ResponseHandler> isItemExist(
    CollectionPath collectionName,
    String queryName,
    dynamic field,
  );
  Future<ResponseHandler> insertData(
    CollectionPath collectionName,
    String id,
    Map<String, dynamic> document,
  );
  Future<ResponseHandler> deleteData(
    CollectionPath collectionName,
    String id,
  );
  Future<ResponseHandler> updateOneData(
    CollectionPath collectionName,
    String id,
    String field,
    dynamic value,
  );
  Future<ResponseHandler> fetchOneData(
    CollectionPath collectionName,
    String field,
    dynamic value,
  );
  Future<ResponseHandler> addDocument(
    CollectionPath collectionName,
    dynamic value,
    String pushField,
    String documentId,
  );
  Future<ResponseHandler> deleteDocument(CollectionPath collectionName,
      String id, String documentFieldName, String documentId);
  Future<ResponseHandler> fetchAllData(CollectionPath collectionName);
}
