import 'package:alfred/alfred.dart';
import 'package:minersy_lite/controllers/auth_controller.dart';
import 'package:minersy_lite/model/user.dart';
import 'package:minersy_lite/utils/extensions/body_parser.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';
import 'package:uuid/uuid.dart';

abstract class IAuthService {
  Future<void> register(HttpRequest req, HttpResponse res);
  Future<void> login(HttpRequest req, HttpResponse res);
}

class AuthService extends IAuthService {
  final IAuthController authController = AuthController();

  @override
  Future<void> register(HttpRequest req, HttpResponse res) async {
    try {
      final jsonData = await req.parseBodyJson();
      if (jsonData != null) {
        final String email = jsonData['email'];
        final String password = jsonData['password'];

        if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
          final user = User(id: Uuid().v4(), email: email, password: password);
          final result = await authController.register(user);
          await res.json(result);
        } else {
          await res
              .json(ResponseHandler(message: ResponseMessage.requiredField));
        }
      } else {
        await res.json(ResponseHandler(message: ResponseMessage.dataNotFound));
      }
    } catch (e) {
      await res.json(ResponseHandler());
    }
  }

  @override
  Future<void> login(HttpRequest req, HttpResponse res) async {
    try {
      final jsonData = await req.parseBodyJson();

      if (jsonData != null) {
        final String email = jsonData['email'];
        final String password = jsonData['password'];

        if (email.trim().isNotEmpty && password.trim().isNotEmpty) {
          final result = await authController.login(email, password);
          await res.json(result);
        } else {
          await res
              .json(ResponseHandler(message: ResponseMessage.requiredField));
        }
      } else {
        await res.json(ResponseHandler(message: ResponseMessage.dataNotFound));
      }
    } catch (e) {
      await res.json(ResponseHandler());
    }
  }
}
