import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
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
    required this.collection,
    this.message,
    String? timestamp,
    this.level = LogLevel.info,
    this.createdBy, // The new optional field
  })  : timestamp = timestamp ?? DateTime.now().toIso8601String(),
        id = const Uuid().v4();

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);

  @JsonKey(name: '_id')
  String? id;

  @JsonKey(name: 'message')
  String? message;

  @JsonKey(name: 'timestamp')
  String timestamp;

  @JsonKey(name: 'level', fromJson: _logLevelFromJson, toJson: _logLevelToJson)
  LogLevel level;

  @JsonKey(name: 'collection')
  String collection; // collection artık String türünde

  @JsonKey(name: 'createdBy') // Add this annotation for createdBy field
  String? createdBy; // This is the new nullable field

  Map<String, dynamic> toJson() => _$AuditLogToJson(this);

  // Custom methods to handle LogLevel serialization
  static LogLevel _logLevelFromJson(String level) => LogLevel.values
      .firstWhere((e) => e.name == level, orElse: () => LogLevel.info);

  static String _logLevelToJson(LogLevel level) => level.name;

  // Collection serileştirme işlemleri artık String olarak yapılıyor
}
