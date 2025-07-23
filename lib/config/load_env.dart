import 'package:dotenv/dotenv.dart';

class EnvConfig {
  EnvConfig({
    required this.host,
    required this.db,
    required this.port,
    required this.jwtIssuer,
    required this.jwtAccessSecretKey,
    required this.jwtRefreshSecretKey,
    required this.jwtAccessTokenExpirationSeconds,
    required this.jwtRefreshTokenExpirationSeconds,
    required this.smtpMail,
    required this.smtpPassword,
    required this.oneSignalAppId,
    required this.oneSignalRestApiKey,
  });
  final String host;
  final String db;
  final String port;
  final String jwtIssuer;
  final String jwtAccessSecretKey;
  final String jwtRefreshSecretKey;
  final String jwtAccessTokenExpirationSeconds;
  final String jwtRefreshTokenExpirationSeconds;
  final String smtpMail;
  final String smtpPassword;
  final String oneSignalAppId;
  final String oneSignalRestApiKey;
}

class Env {
  factory Env() => _instance;

  Env._init() {
    _env = DotEnv(includePlatformEnvironment: true)..load();
    _envConfig = EnvConfig(
      host: _env['HOST'].toString(),
      db: _env['DB'].toString(),
      port: _env['PORT'].toString(),
      jwtIssuer: env['JWT_ISSUER'].toString(),
      jwtAccessSecretKey: env['JWT_SECRET_KEY'].toString(),
      jwtRefreshSecretKey: env['JWT_REFRESH_SECRET_KEY'].toString(),
      jwtAccessTokenExpirationSeconds:
          env['JWT_ACCESS_TOKEN_EXPIRATION_SECONDS'].toString(),
      jwtRefreshTokenExpirationSeconds:
          env['JWT_REFRESH_TOKEN_EXPIRATION_SECONDS'].toString(),
      smtpMail: env['SMTP_MAIL'].toString(),
      smtpPassword: env['SMTP_PASSWORD'].toString(),
      oneSignalAppId: env['ONESIGNAL_APP_ID'].toString(),
      oneSignalRestApiKey: env['ONESIGNAL_REST_API_KEY'].toString(),
    );
  }
  late DotEnv _env;
  late EnvConfig _envConfig;
  DotEnv get env => _env;
  EnvConfig get envConfig => _envConfig;
  static final Env _instance = Env._init();
}
