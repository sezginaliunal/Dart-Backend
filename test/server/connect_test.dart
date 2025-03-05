import 'package:project_base/services/server/server.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final serverService = ServerService();

  test('startServer initializes server', () async {
    expect(serverService.startServer, returnsNormally);
  });
}
