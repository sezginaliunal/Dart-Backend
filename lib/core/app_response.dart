import 'package:dart_backend/core/errors.dart';

final class AppResponse<T> {
  final T? data;
  final AppError? error;

  const AppResponse({this.data, this.error});

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  factory AppResponse.success(T? data) {
    return AppResponse(data: data);
  }

  factory AppResponse.failure(AppError error) {
    return AppResponse(error: error);
  }

  @override
  String toString() {
    return isSuccess
        ? 'Success: $data'
        : 'Failure: ${error?.message ?? 'Unknown error'}';
  }
}
