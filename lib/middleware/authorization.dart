import 'dart:async';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/services/auth/jwt_service.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

class AuthMiddleware {
  final JwtService jwtService = JwtService();

  FutureOr authorize(HttpRequest req, HttpResponse res) async {
    final authHeader = req.headers.value('Authorization');

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      res.statusCode = 401;
      await res.json(
        ResponseHandler(
          message: ResponseMessage.unauthorizedAccess,
        ),
      );
    }

    final token = authHeader?.substring(7);
    final isAuth = await jwtService.checkJwt(token.toString());

    if (!isAuth.success) {
      res.statusCode = 401;
      await res
          .json(ResponseHandler(message: ResponseMessage.unauthorizedAccess));
    }
  }
}
