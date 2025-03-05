import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/controllers/auth.dart';
import 'package:project_base/services/db/db.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'user/user_mock.dart';

void main() {
  final authController = AuthController();
  final userMock = UserMock();
  final dbService = MongoDatabase();

  test('Register', () async {
    await dbService.connectDb();
    final result = await authController.register(userMock.onlyOneUser);
    if (result.message == ResponseMessages.invalidEmail.message) {
      expect(result.success, false);
    } else if (result.message == ResponseMessages.invalidPassword.message) {
      expect(result.success, false);
    } else if (result.message == ResponseMessages.existUser.message) {
      expect(result.success, false);
    } else {
      expect(result.success, true);
    }
  });
  test('Login', () async {
    await dbService.connectDb();
    final result = await authController.login(
      userMock.onlyOneUser.email,
      userMock.onlyOneUser.password,
    );
    if (result.message == ResponseMessages.invalidEmail.message) {
      expect(result.success, false);
    } else if (result.message == ResponseMessages.invalidPassword.message) {
      expect(result.success, false);
    } else if (result.message == ResponseMessages.existUser.message) {
      expect(result.success, false);
    } else {
      expect(result.success, true);
    }
  });
}
