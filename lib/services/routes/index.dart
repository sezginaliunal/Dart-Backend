import 'package:alfred/alfred.dart';
import 'package:hali_saha/services/routes/auth_routes.dart';
import 'package:hali_saha/services/routes/users.routes.dart';

class IndexRoute {
  static Future<void> setupRoutes(Alfred app) async {
    final api = app.route('/api');
    await UsersRoute().setupRoutes(api);
    await AuthRoute().setupRoutes(api);
  }
}
