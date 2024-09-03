import 'package:alfred/alfred.dart';
import 'package:project_base/middleware/authorization.dart';
import 'package:project_base/services/features/user.dart';

class UsersRoute {
  final UserService userService = UserService();
  final Middleware middleware = Middleware();

  Future<void> setupRoutes(NestedRoute app) async {
    app.get(
      '/users/:id',
      userService.getUserById,
      middleware: [middleware.authenticate],
    );
  }
}
