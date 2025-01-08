// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
      collection: json['collection'] as String,
      message: json['message'] as String?,
      timestamp: json['timestamp'] as String?,
      level: json['level'] == null
          ? LogLevel.info
          : AuditLog._logLevelFromJson(json['level'] as String),
      createdBy: json['createdBy'] as String?,
    )..id = json['_id'] as String?;

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
      '_id': instance.id,
      'message': instance.message,
      'timestamp': instance.timestamp,
      'level': AuditLog._logLevelToJson(instance.level),
      'collection': instance.collection,
      'createdBy': instance.createdBy,
    };
