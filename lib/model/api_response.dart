import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  bool success;
  String? message;
  T? data;
  int statusCode;

  ApiResponse({
    this.success = true,
    this.message,
    this.data,
    int? statusCode,
  }) : statusCode = statusCode ?? 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(
    Object Function(T value) toJsonT,
  ) =>
      _$ApiResponseToJson(this, toJsonT);
}
