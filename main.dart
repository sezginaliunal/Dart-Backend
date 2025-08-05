import 'package:project_base/services/db/db.dart';
import 'package:project_base/services/server/server.dart';

Future<void> main() async {
  await MongoDatabase()
      .connectDb()
      .then((_) async => ServerService().startServer());
}
