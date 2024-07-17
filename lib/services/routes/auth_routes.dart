import 'package:alfred/alfred.dart';
import 'package:minersy_lite/controllers/auth_controller.dart';
import 'package:minersy_lite/services/features/auth.dart';
// Assuming this is where your middleware is defined

class AuthRoute {
  final IAuthController authController = AuthController();
  final IAuthService userService = AuthService();

  Future<void> setupRoutes(NestedRoute app) async {
    app.post('/auth/register', userService.register);

    app.post(
      '/auth/login',
      userService.login,
    );
  }
}
