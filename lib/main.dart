import 'package:logger/logger.dart';
import 'package:project_base/services/db/db.dart';

Logger logger = Logger();
Future<void> main() async {
  await logger.init;
  final dbInstance = MongoDatabase();
  await dbInstance.connectDb();

  // await ServerService().startServer();
}
