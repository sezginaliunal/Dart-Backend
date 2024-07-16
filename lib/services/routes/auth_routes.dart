import 'package:alfred/alfred.dart';
import 'package:minersy_lite/controllers/auth_controller.dart';
import 'package:minersy_lite/middleware/auth_middleware.dart';
import 'package:minersy_lite/services/features/auth.dart';

class AuthRoute {
  final IAuthController authController = AuthController();
  final IAuthService userService = AuthService();
  final Middleware middleware = Middleware();

  Future<void> setupRoutes(NestedRoute app) async {
    app.post(
      '/auth/register',
      userService.register,
    );
    app.post('/auth/login', userService.login);
  }
}
