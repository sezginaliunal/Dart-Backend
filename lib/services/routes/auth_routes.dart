import 'package:alfred/alfred.dart';
import 'package:project_base/services/features/auth.dart';
// Assuming this is where your middleware is defined

class AuthRoute {
  final AuthService authService = AuthService();

  Future<void> setupRoutes(NestedRoute app) async {
    app
      ..post('/auth/register', authService.register)
      ..post('/auth/login', authService.login)
      ..post('/auth/logout', authService.logout)
      ..post('/auth/refresh_token', authService.refreshToken)
      ..post('/auth/reset_password', authService.resetPassword);
  }
}
