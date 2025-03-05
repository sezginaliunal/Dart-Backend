import 'package:project_base/services/db/db.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final dbService = MongoDatabase();

  test('connectDb initializes server', () async {
    await dbService.connectDb();
    expect(dbService.isOpen, true);
  });
}
