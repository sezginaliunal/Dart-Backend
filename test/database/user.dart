import 'package:minersy_lite/services/db/base_db.dart';
import 'package:minersy_lite/services/db/db.dart';
// import 'package:minersy_lite/controllers/auth_controller.dart';
import 'package:minersy_lite/controllers/user_controller.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final IBaseDb db = MongoDatabase();
  // final AuthController authController = AuthController();
  final IUserController userController = UserController();

  await db.connectDb();

  //!Register
  // test('Register', () async {
  //   final user = User(email: "Sezgin@hotmail.com", password: "123");

  //   await db.connectDb();

  //   final result = await authController.register(user);

  //   expect(result.success, true);
  // });
  //!Login
  // test('Login', () async {
  //   final email = 'Sezgin@hotmail.com';
  //   final password = '123';
  //   final result = await authController.login(email, password);
  //   expect(result.message, ResponseMessage.userLogin);
  // });
  //!Fetch Data
  // test('Fetch User', () async {
  //   final result =
  //       await userController.fetchUser("13613abe-6a74-4ea7-88a5-1c080c4c107a");
  //   expect(result.success, false);
  // });
  //!Fetch Transaction By User  Data
  // test('Fetch User', () async {
  //   final result = await userController
  //       .fetchTransactionByUser("13613abe-6a74-4ea7-88a5-1c080c4c107a");
  //   print(result.data);
  //   expect(result.success, true);
  // });
  //!Delete
  // test('Delete', () async {
  //   final result =
  //       await userController.delete("bae5e5f7-f193-44df-9c09-acca47efc620");
  //   expect(result.message, ResponseMessage.itemDeleted);
  // });
  //!Delete
  test('Update', () async {
    final result = await userController.updateUser(
        "13613abe-6a74-4ea7-88a5-1c080c4c107a", "email", "sss");
    expect(result.success, true);
  });
  //!Add document
  // test('Add Document', () async {
  //   final transaction = Transaction(
  //     id: Uuid().v4(),
  //     userId: "13613abe-6a74-4ea7-88a5-1c080c4c107a",
  //     startTime: DateTime.now().microsecondsSinceEpoch,
  //     endTime: DateTime.now().microsecondsSinceEpoch,
  //   );
  //   final result = await transactionController.addTransaction(transaction);
  //   expect(result.message, ResponseMessage.itemAdded);
  // });
  //!Delete document
  // test('Delete Document', () async {
  //   final result = await userController.deleteDocument(
  //       "13613abe-6a74-4ea7-88a5-1c080c4c107a",
  //       'transactions',
  //       "8d26b47d-d323-4fd9-8755-9fad81314ffc");
  //   expect(result.message, ResponseMessage.itemDeleted);
  // });
}
