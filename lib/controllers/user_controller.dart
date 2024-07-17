import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:minersy_lite/config/constants/collections.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

abstract class IUserController {
  Future<ResponseHandler> fetchUser(String id);
  Future<ResponseHandler> delete(String id);
  Future<ResponseHandler> deleteDocument(
      String id, String documentFieldName, String documentId);
  Future<ResponseHandler> updateUser(String id, String field, dynamic value);
  Future<ResponseHandler> fetchAllUser();
  Future<ResponseHandler> checkAllUserInfo();
}

class UserController extends IUserController {
  final IBaseDb _db = MongoDatabase();
  final CollectionPath collectionName = CollectionPath.users;

  @override
  Future<ResponseHandler> delete(String id) async {
    final result = await _db.deleteData(collectionName, id);
    if (result.success) {
      return ResponseHandler(
          success: true, message: ResponseMessage.itemDeleted);
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  @override
  Future<ResponseHandler> deleteDocument(
      String id, String documentFieldName, String documentId) async {
    final result = await _db.deleteDocument(
        collectionName, id, documentFieldName, documentId);
    if (result.success) {
      return ResponseHandler(
          success: true, message: ResponseMessage.itemDeleted);
    }
    return ResponseHandler(message: ResponseMessage.unexpectedError);
  }

  @override
  Future<ResponseHandler> fetchUser(String id) async {
    final result = await _db.fetchOneData(collectionName, '_id', id);

    if (result.success) {
      return ResponseHandler(success: true, data: result.data);
    }
    return ResponseHandler(message: ResponseMessage.itemNotFound);
  }

  @override
  Future<ResponseHandler> updateUser(
      String id, String field, dynamic value) async {
    final result = await _db.updateOneData(collectionName, id, field, value);
    if (result.success) {
      return ResponseHandler(success: true, data: result.data);
    }
    return ResponseHandler();
  }

  @override
  Future<ResponseHandler> fetchAllUser() async {
    final result = await _db.fetchAllData(collectionName);
    if (result.success) {
      return ResponseHandler(
        success: true,
        data: result.data,
      );
    }
    return ResponseHandler();
  }

  @override
  Future<ResponseHandler> checkAllUserInfo() async {
    final result = await fetchAllUser();
    if (result.success) {
      return ResponseHandler(
        success: true,
        data: result.data,
      );
    }
    return ResponseHandler();
  }
}
