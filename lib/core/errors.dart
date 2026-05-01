sealed class AppError {
  const AppError();

  String get message => switch (this) {
    NetworkError() => 'Network error occurred',
    ValidationError() => 'Validation error occurred',
    DatabaseError() => 'Database error occurred',
    DataNotFoundError() => 'Data not found error occurred',
    PermissionDeniedError() => 'Permission denied error occurred',
    TimeoutError() => 'Timeout error occurred',
    UnknownError() => 'Unknown error occurred',
    ServerError() => 'An error occurred',
    BadRequestError() => 'Bad request error occurred',
    UnauthorizedError() => 'Unauthorized error occurred',
    ForbiddenError() => 'Forbidden error occurred',
    NotFoundError() => 'Not found error occurred',
    ConflictError() => 'Conflict error occurred',
    CustomError(:final customMessage) => customMessage,
    NotUpdated() => 'Not updated error occurred',
  };
}

final class NetworkError extends AppError {
  const NetworkError();
}

final class ValidationError extends AppError {
  const ValidationError();
}

final class DatabaseError extends AppError {
  const DatabaseError();
}

final class DataNotFoundError extends AppError {
  const DataNotFoundError();
}

final class PermissionDeniedError extends AppError {
  const PermissionDeniedError();
}

final class TimeoutError extends AppError {
  const TimeoutError();
}

final class ServerError extends AppError {
  const ServerError();
}

final class BadRequestError extends AppError {
  const BadRequestError();
}

final class UnauthorizedError extends AppError {
  const UnauthorizedError();
}

final class ForbiddenError extends AppError {
  const ForbiddenError();
}

final class NotFoundError extends AppError {
  const NotFoundError();
}

final class ConflictError extends AppError {
  const ConflictError();
}

final class UnknownError extends AppError {
  const UnknownError();
}

final class NotUpdated extends AppError {
  const NotUpdated();
}

final class CustomError extends AppError {
  final String customMessage;

  const CustomError(this.customMessage);

  @override
  String get message => customMessage;
}
