import 'package:alfred/alfred.dart';
import 'package:minersy_lite/controllers/user_controller.dart';

abstract class IUserService {
  Future<void> getAllUsers(HttpRequest req, HttpResponse res);
  Future<void> getUserById(HttpRequest req, HttpResponse res);
}

class UserService extends IUserService {
  final IUserController userController = UserController();

  @override
  Future<void> getAllUsers(HttpRequest req, HttpResponse res) async {
    final result = await userController.fetchAllUser();

    await res.json(result);
  }

  @override
  Future<void> getUserById(HttpRequest req, HttpResponse res) async {
    String userId = req.params['id'];

    final result = await userController.fetchUser(userId);

    await res.json(result);
  }
}
