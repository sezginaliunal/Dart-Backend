import 'package:project_base/config/constants/collections.dart';
import 'package:project_base/model/api_response.dart';
import 'package:project_base/model/audit_log.dart';
import 'package:project_base/services/db/db.dart';

class AuditLogController {
  factory AuditLogController() => _instance;

  AuditLogController._internal();
  static final AuditLogController _instance = AuditLogController._internal();
  final db = MongoDatabase();
  final collectionName = CollectionPath.audit_log.name;
  Future<void> insertLog(AuditLog auditLog) async {
    await db.getCollection(collectionName).insert(auditLog.toJson());
  }

  Future<ApiResponse<List<AuditLog>>> fetchAuditLogs(
    int page,
    int limit, {
    required bool descending,
  }) async {
    return db.paginateData<AuditLog>(
      collectionName,
      page: page,
      limit: limit,
      sort: 'timestamp', // Sıralama alanı
      fromJson: AuditLog.fromJson,
      descending: descending, // Dönüşüm fonksiyonu
    );
  }

  // Audit log'ları silerken belirli bir filtreyle de silme fonksiyonu ekledik.
  Future<void> deleteAuditLogs({String? levelFilter}) async {
    final query = levelFilter != null ? {'level': levelFilter} : {'': ''};
    await db.getCollection(collectionName).remove(query);
  }
}
