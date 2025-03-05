import 'package:hali_saha/config/constants/collections.dart';
import 'package:hali_saha/services/db/db.dart';

abstract class MyController {
  final MongoDatabase db = MongoDatabase();
  late final CollectionPath collectionName;
}
