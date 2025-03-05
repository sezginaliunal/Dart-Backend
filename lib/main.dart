import 'package:hali_saha/services/db/db.dart';
import 'package:hali_saha/services/server/server.dart';

Future<void> main() async {
  final dbInstance = MongoDatabase();
  await dbInstance.connectDb();
  await ServerService().startServer();
}
