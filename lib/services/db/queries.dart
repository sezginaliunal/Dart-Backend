import 'package:mongo_dart/mongo_dart.dart';

abstract class IDQueries {
  //variables
  late Db db;
  //Methods
  Future<void> isExist();
  Future<void> instert();
  Future<void> delete();
  Future<void> update();
  Future<void> read();
  Future<void> readList();
  Future<void> paginated();
  Future<void> createIndex();
}
