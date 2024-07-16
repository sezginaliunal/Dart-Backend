import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
import 'package:test/test.dart';

void main() {
  test('Connection', () async {
    final IBaseDb db = MongoDatabase();
    await db.connectDb();
    final result = await db.isDbOpen();

    expect(result, true);
  });
}
