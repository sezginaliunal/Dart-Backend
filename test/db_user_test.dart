import 'package:dart_backend/core/enums/user.dart';
import 'package:dart_backend/core/env/env_service.dart';
import 'package:dart_backend/core/mongo/mongo_client.dart';
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
    final user = User(id: ObjectId().oid, name: 'TestUser_${DateTime.now().millisecondsSinceEpoch}');
    expect(user.role, UserRole.user);
    expect(user.permissions, PermissionSet.editor); // read + write

    final res = await userRepository.create(user);
    expect(res.isSuccess, true);
  });

  test('Get User by name', () async {
    final users = await userRepository.getAll();
    expect(users.isSuccess, true);
    final name = users.data!.first.name;

    final res = await userRepository.getByName(name);
    expect(res.isSuccess, true);
    expect(res.data?.name, name);
  });

  test('Update Role — permission otomatik guncellenmeli', () async {
    final users = await userRepository.getAll();
    final userId = users.data!.first.id;

    final res = await userRepository.updateRole(userId, UserRole.moderator);
    expect(res.isSuccess, true);

    final updated = await userRepository.getById(userId);
    expect(updated.data?.role, UserRole.moderator);
    expect(updated.data?.permissions, PermissionSet.moderator);
  });

  test('Grant Permission — bit OR ile ekleme', () async {
    final users = await userRepository.getAll();
    final user = users.data!.first;

    final res = await userRepository.grantPermission(user.id, UserPermission.delete);
    expect(res.isSuccess, true);

    final updated = await userRepository.getById(user.id);
    expect(updated.data?.permissions.has(UserPermission.delete), true);
    // Önceki permission'lar korunmali
    expect(updated.data?.permissions.has(UserPermission.read), true);
  });

  test('Revoke Permission — bit AND ile kaldirma', () async {
    final users = await userRepository.getAll();
    final user = users.data!.first;

    await userRepository.grantPermission(user.id, UserPermission.manage);
    final res = await userRepository.revokePermission(user.id, UserPermission.manage);
    expect(res.isSuccess, true);

    final updated = await userRepository.getById(user.id);
    expect(updated.data?.permissions.has(UserPermission.manage), false);
  });

  test('Get users by role', () async {
    final res = await userRepository.getByRole(UserRole.user);
    expect(res.isSuccess, true);
    for (final u in res.data!) {
      expect(u.role, UserRole.user);
    }
  });

  test('Get users by permission', () async {
    final res = await userRepository.getByPermission(UserPermission.read);
    expect(res.isSuccess, true);
    for (final u in res.data!) {
      expect(u.permissions.canRead, true);
    }
  });

  test('Update Status — ban user', () async {
    final users = await userRepository.getAll();
    final userId = users.data!.first.id;

    final res = await userRepository.updateStatus(userId, UserStatus.banned);
    expect(res.isSuccess, true);

    final updated = await userRepository.getById(userId);
    expect(updated.data?.status, UserStatus.banned);
    expect(updated.data?.status.canAccess, false);
  });

  test('Pagination list', () async {
    final res = await userRepository.paginationList(sortBy: '_id');
    expect(res.isSuccess, true);
    print('Toplam: ${res.data!.length} kullanici');
    for (final u in res.data!) {
      print('${u.name} | ${u.role.name} | ${u.permissions}');
    }
  });
}
