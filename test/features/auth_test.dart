import 'package:hali_saha/config/constants/response_messages.dart';
import 'package:hali_saha/controllers/auth.dart';
import 'package:hali_saha/services/db/db.dart';
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
    final result =
        await authController.login('email@hotmail.com', '12345678Aa.');
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
