import 'package:project_base/services/db/db.dart';
import 'package:project_base/services/server/server.dart';

Future<void> main() async {
  final MongoDatabase dbInstance = MongoDatabase();
  await dbInstance.connectDb();
  await ServerService().startServer();
}
