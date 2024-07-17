import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/config/constants/strings.dart';
import 'package:minersy_lite/config/load_env.dart';
import 'package:minersy_lite/services/routes/index.dart';

class ServerService {
  static final uploadDirectory = Directory(ProjectStrings.uploadDirectory);

  late Alfred _app;
  Alfred get app => _app;
  static final ServerService _instance = ServerService._init();
  late final Env _env;

  ServerService._init() {
    _env = Env();
    _app = Alfred();

    _setupFileUploadRoutes();
    _app.all('*', cors(origin: '*'));

    _setupRoutes();
  }

  factory ServerService() => _instance;

  Future<void> startServer() async {
    await _app.listen(int.parse(_env.envConfig.port), _env.envConfig.host);
    print("Server ${_env.envConfig.host + _env.envConfig.port} da çalışıyor");
  }

  void _setupRoutes() async {
    await IndexRoute.setupRoutes(app);
  }

  void _setupFileUploadRoutes() {
    app.get('/public/*', (req, res) => uploadDirectory);
  }
}
