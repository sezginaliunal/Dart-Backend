import 'dart:developer';

import 'package:project_base/controllers/user_controller.dart';
import 'package:project_base/services/db/db.dart';
import 'package:project_base/utils/enums/account.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final userContoller = UserController();

  final dbService = MongoDatabase();
  setUp(() async {
    await dbService.connectDb();
  });
  test('UpdateUser', () async {
    final result = await userContoller.updateUser(
      '3202215a-3d94-46f2-8475-980d8d72c851',
      'accountRole',
      AccountRole.supervisor.value,
    );
    expect(result.data, true);
  });
  test('Get User', () async {
    final result = await userContoller.getUserById(
      '3202215a-3d94-46f2-8475-980d8d72c851',
    );
    inspect(result);
    expect(result.success, true);
  });
  test('User is Admin', () async {
    final result = await userContoller.getUserById(
      '9334f348-eb6e-45ea-b8bc-91be5b261914',
    );
    final userRole = checkAccountRole(result.data!.accountRole);

    expect(userRole.isAdmin, true);
  });
}
