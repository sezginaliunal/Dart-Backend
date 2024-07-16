import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:minersy_lite/config/constants/collections.dart';
// import 'package:minersy_lite/model/user.dart';
import 'package:test/test.dart';
// import 'package:uuid/uuid.dart';

void main() {
  group('Database Tests', () {
    late IBaseDb db;
    setUp(() {
      db = MongoDatabase();
    });

    tearDown(() async {
      await db.closeDb();
    });

    test('Insert and Delete Data', () async {
      final CollectionPath collectionName = CollectionPath.users;
      // final user =
      //     User(id: Uuid().v4(), email: "seee@hotmail.com", password: "s");

      await db.connectDb();
      // final add = await db.insertData(
      //     collectionName, user.id.toString(), user.toJson());

      final delete = await db.deleteData(
          collectionName, "1b8fd603-b341-4fb4-9de1-fd4575bded89");
      // final update = await db.updateOneData(
      //     collectionName, "1b8fd603-b341-4fb4-9de1-fd4575bded89", "email", "s");

      // expect(add, true);
      // expect(update, true);
      expect(delete, true);
    });
  });
}
