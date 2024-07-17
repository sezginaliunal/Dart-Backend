import 'package:dotenv/dotenv.dart';

class EnvConfig {
  final String host;
  final String db;
  final String port;
  final String jwtIssuer;
  final String jwtSecretKey;
  final String jwtExpirationSeconds;

  EnvConfig(
      {required this.host,
      required this.db,
      required this.port,
      required this.jwtIssuer,
      required this.jwtSecretKey,
      required this.jwtExpirationSeconds});
}

class Env {
  late DotEnv _env;
  late EnvConfig _envConfig;
  DotEnv get env => _env;
  EnvConfig get envConfig => _envConfig;
  static final Env _instance = Env._init();

  Env._init() {
    print("Çalıştı");
    _env = DotEnv(includePlatformEnvironment: true)..load();
    _envConfig = EnvConfig(
      host: _env['HOST'].toString(),
      db: _env['DB'].toString(),
      port: _env['PORT'].toString(),
      jwtIssuer: env['JWT_ISSUER'].toString(),
      jwtSecretKey: env['JWT_SECRET_KEY'].toString(),
      jwtExpirationSeconds: env['JWT_EXPIRATION_SECONDS'].toString(),
    );
  }

  factory Env() => _instance;
}
