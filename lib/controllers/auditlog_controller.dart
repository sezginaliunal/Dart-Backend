import 'package:hali_saha/config/constants/collections.dart';
import 'package:hali_saha/core/controller.dart';
import 'package:hali_saha/model/api_response.dart';
import 'package:hali_saha/model/audit_log.dart';

class AuditLogController extends MyController {
  AuditLogController() {
    collectionName = CollectionPath.audit_log;
  }

  Future<void> insertLog(AuditLog auditLog) async {
    await db.getCollection(collectionName.name).insert(auditLog.toJson());
  }

  Future<ApiResponse<List<AuditLog>>> fetchAuditLogs(
    int page,
    int limit, {
    required bool descending,
  }) async {
    return db.paginateData<AuditLog>(
      collectionName.name,
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
    await db.getCollection(collectionName.name).remove(query);
  }
}
