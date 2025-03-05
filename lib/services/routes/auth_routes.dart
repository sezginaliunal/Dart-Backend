import 'package:alfred/alfred.dart';
import 'package:hali_saha/services/features/auth.dart';
// Assuming this is where your middleware is defined

class AuthRoute {
  final AuthService authService = AuthService();

  Future<void> setupRoutes(NestedRoute app) async {
    app
      ..post('/auth/register', authService.register)
      ..post('/auth/login', authService.login)
      ..post('/auth/reset_password', authService.resetPassword);
  }
}
