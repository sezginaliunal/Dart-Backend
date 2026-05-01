import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/mongo/mongo_client.dart';
import 'package:test/test.dart';

void main() {
  final envService = EnvService();
  envService.loadEnv();
  final mongoClient = MongoClient(envService);
  test('connect to MongoDB', () async {
    final result = await mongoClient.connect();
    expect(result.isSuccess, true);
    print(result.toString());
  });

  test('Close Db', () async {
    final closeResult = await mongoClient.close();
    expect(closeResult.isSuccess, true);
    print(closeResult.toString());
  });
}
