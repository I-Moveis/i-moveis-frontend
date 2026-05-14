import '../entities/admin_metrics.dart';
import '../entities/paginated_properties.dart';

/// Interface para endpoints `/api/admin/*`. Todas as rotas exigem ADMIN.
abstract class AdminRepository {
  /// `GET /api/admin/metrics`.
  Future<AdminMetrics> getMetrics();

  /// `GET /api/admin/properties?status=&page=&limit=`.
  /// [status] aceita `PENDING`, `APPROVED`, `REJECTED`.
  Future<PaginatedProperties> listForModeration({
    required String status,
    int page = 1,
    int limit = 20,
  });

  /// `POST /api/admin/broadcast` — envia notificação global para todos os usuários.
  Future<void> sendBroadcast({
    required String title,
    required String body,
  });
}
