import 'package:alfred/alfred.dart';
import 'package:project_base/services/features/auth.dart';
// Assuming this is where your middleware is defined

class AuthRoute {
  final AuthService authService = AuthService();

  Future<void> setupRoutes(NestedRoute app) async {
    app.post('/auth/register', authService.register);

    app.post('/auth/login', authService.login);
    app.post('/auth/logout', authService.logout);
    app.post('/auth/reset_password', authService.logout);
  }
}
