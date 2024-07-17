import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:minersy_lite/services/server/server.dart';

Future<void> main() async {
  final IBaseDb db = MongoDatabase();
  await db.connectDb();
  await ServerService().startServer();
}
