// int64_converter.dart
import 'package:fixnum/fixnum.dart';
import 'package:json_annotation/json_annotation.dart';

class Int64Converter implements JsonConverter<Int64, dynamic> {
  const Int64Converter();

  @override
  Int64 fromJson(dynamic json) {
    if (json is Int64) {
      return json;
    } else if (json is int) {
      return Int64(json);
    } else if (json is String) {
      return Int64.parseInt(json);
    } else {
      throw ArgumentError('Invalid Int64 input: $json');
    }
  }

  @override
  dynamic toJson(Int64 object) => object.toInt(); // int olarak yazmak güvenli
}
