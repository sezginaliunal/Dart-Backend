import 'dart:developer';

import 'package:project_base/services/server/server.dart';
import 'package:test/test.dart';

final _server = ServerService();

void main() {
  test('Connect to server', _connect);
}

Future<void> _connect() async {
  await _server.startServer();
  log('message');
}
