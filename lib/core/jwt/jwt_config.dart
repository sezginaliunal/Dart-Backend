import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

final class JwtConfig {
  final String issuer;
  final String subject;
  final Duration expiresIn;
  final JWTAlgorithm algorithm;

  const JwtConfig({
    this.issuer = 'your-app',
    this.subject = 'auth',
    this.expiresIn = const Duration(minutes: 15),
    this.algorithm = JWTAlgorithm.RS256,
  });

  static const access = JwtConfig(
    subject: 'access',
    expiresIn: Duration(minutes: 15),
  );

  static const refresh = JwtConfig(
    subject: 'refresh',
    expiresIn: Duration(days: 7),
  );
}
