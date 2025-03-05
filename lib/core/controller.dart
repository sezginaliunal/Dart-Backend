import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/services/db/db.dart';

abstract class MyController {
  final MongoDatabase db = MongoDatabase();
  late final CollectionPath collectionName;
}
