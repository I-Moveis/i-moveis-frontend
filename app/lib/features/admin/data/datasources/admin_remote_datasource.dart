import '../../domain/entities/admin_metrics.dart';
import '../../domain/entities/paginated_properties.dart';

/// Port para a superfície `/api/admin/*`.
abstract class AdminRemoteDataSource {
  Future<AdminMetrics> getMetrics();

  Future<PaginatedProperties> listForModeration({
    required String status,
    int page = 1,
    int limit = 20,
  });

  Future<void> sendBroadcast({
    required String title,
    required String body,
  });
}
