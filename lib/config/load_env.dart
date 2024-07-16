import 'package:dotenv/dotenv.dart';

class EnvConfig {
  final String host;
  final String db;
  final String port;

  EnvConfig({
    required this.host,
    required this.db,
    required this.port,
  });
}

class Env {
  late DotEnv _env;
  late EnvConfig _envConfig;
  DotEnv get env => _env;
  EnvConfig get envConfig => _envConfig;
  static final Env _instance = Env._init();

  Env._init() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
    _envConfig = EnvConfig(
      host: _env['HOST'].toString(),
      db: _env['DB'].toString(),
      port: _env['PORT'].toString(),
    );
  }

  factory Env() => _instance;
}
