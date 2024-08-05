import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/services/routes/index.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class ServerService {
  late Alfred _app;
  Alfred get app => _app;
  static final ServerService _instance = ServerService._init();
  late final Env _env;

  ServerService._init() {
    _env = Env();
    _app = Alfred(
      onInternalError: internalError,
      onNotFound: missingHandler,
    );

    // _setupFileUploadRoutes();

    _setupRoutes();
  }

  factory ServerService() => _instance;

  Future<void> startServer() async {
    await _app.listen(int.parse(_env.envConfig.port), _env.envConfig.host);
  }

  void _setupRoutes() async {
    await IndexRoute.setupRoutes(app);
  }

  FutureOr missingHandler(HttpRequest req, HttpResponse res) {
    return JsonResponseHelper.sendJsonResponse(
        statusCode: HttpStatus.notFound,
        res,
        ApiResponse(success: false, message: 'Not found'));
  }

  FutureOr internalError(HttpRequest req, HttpResponse res) {
    return JsonResponseHelper.sendJsonResponse(
        statusCode: HttpStatus.internalServerError,
        res,
        ApiResponse(success: false, message: 'Internal error'));
  }
}
