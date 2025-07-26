import 'package:project_base/services/db/db.dart';

Future<void> main() async {
  await MongoDatabase().connectDb();
}
