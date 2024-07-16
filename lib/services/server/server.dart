import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/config/load_env.dart';
import 'package:minersy_lite/services/routes/index.dart';

final _uploadDirectory = Directory('uploadedFiles');

class ServerConfig {
  late final String host;
  late final String port;

  ServerConfig({required this.host, required this.port});
}

class ServerService {
  late Alfred _app;
  Alfred get app => _app;
  static final ServerService _instance = ServerService._init();
  final _env = Env();
  late final ServerConfig _serverConfig;

  ServerService._init() {
    _serverConfig =
        ServerConfig(host: _env.envConfig.host, port: _env.envConfig.port);
    _app = Alfred();
    // Dosya yükleme işlemi için route tanımlaması
    _app.get('/files/*', (req, res) => _uploadDirectory);
  }

  factory ServerService() => _instance;

  Future<void> startServer() async {
    await IndexRoute.setupRoutes(app);
    await _app.listen(int.parse(_serverConfig.port), _serverConfig.host);
    print("Server ${_serverConfig.port} da çalışıyor");
  }
}
