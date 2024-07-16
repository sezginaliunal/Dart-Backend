import 'package:alfred/alfred.dart';
import 'package:minersy_lite/controllers/user_controller.dart';
import 'package:minersy_lite/middleware/auth_middleware.dart';
import 'package:minersy_lite/services/features/user.dart';

class UsersRoute {
  final IUserController userController = UserController();
  final IUserService userService = UserService();
  final Middleware middleware = Middleware();

  Future<void> setupRoutes(NestedRoute app) async {
    app.get('/users', userService.getAllUsers,
        middleware: [middleware.authorization]);
    app.get('/users/:id', userService.getUserById);
  }
}
