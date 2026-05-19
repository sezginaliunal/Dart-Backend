import 'package:dart_backend/core/enums/auth.dart';
import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/jwt/jwt_collection.dart';
import 'package:dart_backend/core/jwt/jwt_repository.dart';
import 'package:dart_backend/core/jwt/jwt_service.dart';
import 'package:dart_backend/core/mongo/mongo_client.dart';
import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:dart_backend/feature/auth/auth_service.dart';
import 'package:dart_backend/feature/auth/models/auth_dto.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_collection.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:test/test.dart';

void main() {
  final envService = EnvService()..loadEnv();
  final mongoClient = MongoClient(envService);
  late final UserRepository userRepository;
  late final JwtRepository jwtRepository;
  late final JwtService jwtService;
  late final AuthService authService;

  setUp(() async {
    final connectResult = await mongoClient.connect();
    expect(connectResult.isSuccess, true);
    await envService.loadKeys();
    userRepository = UserRepository(UserCollection(connectResult.data!));
    jwtService = JwtService(
      privateKey: RSAPrivateKey(envService.jwtPrivateKey),
      publicKey: RSAPublicKey(envService.jwtPublicKey),
    );
    jwtRepository = JwtRepository(JwtCollection(mongoClient.db, jwtService));
    authService = AuthService(userRepo: userRepository, jwtRepo: jwtRepository);
  });

  test('Register ', () async {
    final user = User(name: 'Sezgin');
    final registerRequest = RegisterRequest(
      name: user.name,
      authType: AuthType.email,
      password: '123456',
    );
    final res = await authService.register(registerRequest);

    expect(res.isSuccess, true);
    // Test implementation
  });
  test('Login ', () async {
    // Test implementation
    final loginRequest = LoginRequest(
      name: 'Sezgin',
      authType: AuthType.email,
      password: '123456',
    );
    final res = await authService.login(loginRequest);
    expect(res.isSuccess, true);
    if (res.isSuccess) {
      AppLogger.info('Login successful, token: ${res.data?.refreshToken}');
    }
  });
}
