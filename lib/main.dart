import 'package:project_base/services/db/db.dart';

Future<void> main() async {
  final dbInstance = MongoDatabase();
  await dbInstance.connectDb();
  // await ServerService().startServer();
}
