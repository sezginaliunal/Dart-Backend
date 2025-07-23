// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => AuditLog(
      id: json['_id'] as String,
      collection: json['collection'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      level: json['level'] == null
          ? LogLevel.info
          : AuditLog._logLevelFromJson(json['level'] as String),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$AuditLogToJson(AuditLog instance) => <String, dynamic>{
      '_id': instance.id,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'level': AuditLog._logLevelToJson(instance.level),
      'collection': instance.collection,
      'createdBy': instance.createdBy,
    };
