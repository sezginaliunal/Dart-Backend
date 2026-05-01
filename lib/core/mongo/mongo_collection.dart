import 'package:mongo_dart/mongo_dart.dart';

abstract class MongoCollection extends DbCollection {
  MongoCollection(super.db, super.collectionName);
}
