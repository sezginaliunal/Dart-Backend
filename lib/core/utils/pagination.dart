/// Query string'den pagination parametrelerini parse eder.
///
/// Desteklenen query params:
///   ?page=1&pageSize=20&sortBy=createdAt&desc=true
///
/// Kullanım:
///   final params = PaginationParams.fromRequest(request);
///   final result = await repo.paginationList(
///     page: params.page,
///     pageSize: params.pageSize,
///     sortBy: params.sortBy,
///     descending: params.descending,
///   );
///   return ResponseHandler.ok(PaginationResponse(result.data!, params).toJson());
final class PaginationParams {
  final int page;
  final int pageSize;
  final String sortBy;
  final bool descending;

  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
    this.sortBy = 'createdAt',
    this.descending = true,
  });

  factory PaginationParams.fromQuery(Map<String, String> query) {
    final page = int.tryParse(query['page'] ?? '') ?? 1;
    final pageSize = int.tryParse(query['pageSize'] ?? '') ?? 20;

    return PaginationParams(
      // Negatif veya sıfır değerlere karşı güvenli sınırlar
      page: page < 1 ? 1 : page,
      pageSize: pageSize < 1
          ? 20
          : pageSize > 100
              ? 100 // maksimum 100 kayıt — sunucu aşırı yüklenmesini önler
              : pageSize,
      sortBy: query['sortBy'] ?? 'createdAt',
      descending: query['desc'] != 'false', // varsayılan: en yeni önce
    );
  }
}

/// Pagination meta verisiyle birlikte liste response'u.
final class PaginationResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int count;

  const PaginationResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.count,
  });

  factory PaginationResponse.fromParams(
    List<T> items,
    PaginationParams params,
  ) => PaginationResponse(
        items: items,
        page: params.page,
        pageSize: params.pageSize,
        count: items.length,
      );

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJson) => {
        'items': items.map(toJson).toList(),
        'pagination': {
          'page': page,
          'pageSize': pageSize,
          'count': count,
          'hasMore': count == pageSize, // tam doluysa sonraki sayfa vardır
        },
      };
}
