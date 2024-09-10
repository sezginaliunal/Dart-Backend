import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:project_base/config/constants/response_messages.dart';
import 'package:project_base/config/load_env.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/services/routes/index.dart';
import 'package:project_base/utils/helpers/json_helper.dart';

class ServerService {
  factory ServerService() => _instance;

  ServerService._init() {
    _env = Env();
    _app = Alfred(
      onInternalError: internalError,
      onNotFound: missingHandler,
    );

    // _setupFileUploadRoutes();

    _setupRoutes();
  }
  late Alfred _app;
  Alfred get app => _app;
  static final ServerService _instance = ServerService._init();
  late final Env _env;

  Future<void> startServer() async {
    await _app.listen(int.parse(_env.envConfig.port), _env.envConfig.host);
  }

  Future<void> _setupRoutes() async {
    await IndexRoute.setupRoutes(app);
  }

  FutureOr<dynamic> missingHandler(HttpRequest req, HttpResponse res) async {
    return await JsonResponseHelper.sendJsonResponse(
      statusCode: HttpStatus.notFound,
      res,
      ApiResponse(
        success: false,
        message: ResponseMessages.notFound.message,
        statusCode: HttpStatus.notFound,
      ),
    );
  }

  FutureOr<dynamic> internalError(HttpRequest req, HttpResponse res) async {
    return await JsonResponseHelper.sendJsonResponse(
      statusCode: HttpStatus.internalServerError,
      res,
      ApiResponse(
        success: false,
        message: ResponseMessages.notFound.message,
        statusCode: HttpStatus.internalServerError,
      ),
    );
  }
}
