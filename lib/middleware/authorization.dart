import 'dart:async';

import 'package:alfred/alfred.dart';
import 'package:minersy_lite/services/auth/jwt_service.dart';
import 'package:minersy_lite/utils/helpers/response_handler.dart';

class Middleware {
  final JwtService jwtService = JwtService();

  FutureOr authorize(HttpRequest req, HttpResponse res) async {
    final authHeader = req.headers.value('Authorization');

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      await res
          .json(ResponseHandler(message: ResponseMessage.unauthorizedAccess));
      return;
    }

    final token = authHeader.substring(7);

    final response = await jwtService.checkJwt(token);

    if (!response.success) {
      await res.json(response);
      return;
    }
  }
}
