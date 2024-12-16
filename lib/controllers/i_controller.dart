import 'package:mongo_dart/mongo_dart.dart';

abstract class IController<T> {
  Db get db;
  String get collectinName;
}
