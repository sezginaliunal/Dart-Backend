import 'package:dart_backend/core/enums/auth.dart';
import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/mongo/mongo_client.dart';
import 'package:dart_backend/core/utils/app_logger.dart';
import 'package:dart_backend/feature/user/models/user.dart';
import 'package:dart_backend/feature/user/user_collection.dart';
import 'package:dart_backend/feature/user/user_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:test/test.dart';

void main() {
  final envService = EnvService()..loadEnv();
  final mongoClient = MongoClient(envService);
  late UserRepository userRepository;

  setUp(() async {
    final connectResult = await mongoClient.connect();
    expect(connectResult.isSuccess, true);
    userRepository = UserRepository(UserCollection(connectResult.data!));
  });

  test('Create User — varsayılan role user, permission editor', () async {
    final user = User(
      id: ObjectId().oid,
      name: 'TestUser_${DateTime.now().millisecondsSinceEpoch}',
      passwordHash: '123456',
      authType: AuthType.email,
    );
    expect(user.role, UserRole.customer);

    final res = await userRepository.create(user);
    expect(res.isSuccess, true);
  });

  test('Get User by name', () async {
    final users = await userRepository.getAll();
    if (users.isSuccess) {
      expect(users.data, isNotEmpty);
      for (var data in users.data!) {
        AppLogger.info('Kullanıcı: ${data.name} | Role: ${data.role.name}');
      }
    } else {
      fail('No users found to test getByName');
    }
    expect(users.isSuccess, true);
    final name = users.data!.first.name;

    final res = await userRepository.getByName(name);
    AppLogger.info(
      'GetByName Result: ${res.data?.name} | ${res.data?.role.name}',
    );
    expect(res.isSuccess, true);
    expect(res.data?.name, name);
  });

  test('Get users by role', () async {
    final res = await userRepository.getByRole(UserRole.customer);
    expect(res.isSuccess, true);
    for (final u in res.data!) {
      expect(u.role, UserRole.customer);
    }
  });

  test('Update Status — ban user', () async {
    final users = await userRepository.getAll();
    final userId = users.data!.first.id;

    final res = await userRepository.updateStatus(
      userId ?? '',
      UserStatus.deleted,
    );
    expect(res.isSuccess, true);

    final updated = await userRepository.getById(userId!);
    expect(updated.data?.status, UserStatus.deleted);
    expect(updated.data?.status.canAccess, false);
  });

  test('Pagination list', () async {
    final res = await userRepository.paginationList(sortBy: '_id');
    expect(res.isSuccess, true);
    AppLogger.info('Toplam: ${res.data!.length} kullanici');
    for (final u in res.data!) {
      AppLogger.info('${u.name} | ${u.role.name}');
    }
  });
}
