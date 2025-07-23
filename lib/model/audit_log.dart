import 'package:json_annotation/json_annotation.dart';

part 'audit_log.g.dart';

enum LogLevel {
  info,
  warning,
  error,
  fatal,
}

@JsonSerializable()
class AuditLog {
  AuditLog({
    required this.id,
    required this.collection,
    required this.message,
    required this.createdAt,
    this.level = LogLevel.info,
    this.createdBy,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);

  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'level', fromJson: _logLevelFromJson, toJson: _logLevelToJson)
  final LogLevel level;

  @JsonKey(name: 'collection')
  final String collection;

  @JsonKey(name: 'createdBy')
  final String? createdBy;

  Map<String, dynamic> toJson() => _$AuditLogToJson(this);

  static LogLevel _logLevelFromJson(String level) => LogLevel.values
      .firstWhere((e) => e.name == level, orElse: () => LogLevel.info);

  static String _logLevelToJson(LogLevel level) => level.name;
}
