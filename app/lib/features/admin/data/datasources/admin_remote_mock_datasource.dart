import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/paginated_properties.dart';
import 'admin_remote_datasource.dart';

/// Mock de admin — devolve zeros em vez de demo-data para evitar que o
/// dashboard mostre números falsos quando `kUseMockData=true`.
class AdminRemoteMockDataSource implements AdminRemoteDataSource {
  @override
  Future<AdminMetrics> getMetrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return AdminMetrics.empty;
  }

  @override
  Future<PaginatedProperties> listForModeration({
    required String status,
    int page = 1,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const PaginatedProperties(
      items: [],
      page: 1,
      limit: 20,
      total: 0,
      totalPages: 0,
    );
  }
}
