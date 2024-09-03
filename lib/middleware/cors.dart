import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred.dart';

class Cors {
  FutureOr<dynamic> cors({required String origin}) {
    return (HttpRequest req, HttpResponse res) async {
      res.headers.add('Access-Control-Allow-Origin', origin);
      res.headers.add(
        'Access-Control-Allow-Methods',
        'GET, POST, OPTIONS, DELETE, PUT',
      );
      res.headers.add(
        'Access-Control-Allow-Headers',
        'Origin, Content-Type, X-Auth-Token',
      );
      if (req.method == 'OPTIONS') {
        // res.statusCode = 44;
        await res.close();
      } else {
        //  res.statusCode = 44;
        await req.response.close();
      }
    };
  }
}
