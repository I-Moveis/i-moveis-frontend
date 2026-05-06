import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';

// ─── Domain model ─────────────────────────────────────────────────────────────
// Quando o backend entregar GET /api/reports, mapear essa classe a partir
// do JSON. Os campos cobrem o que uma tela de denúncias típica precisaria.

class AdminReport {
  const AdminReport({
    required this.id,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.reason,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String reporterName;

  /// 'USER' | 'PROPERTY'
  final String targetType;
  final String targetId;
  final String targetName;
  final String reason;
  final String description;

  /// 'PENDING' | 'REVIEWING' | 'RESOLVED' | 'DISMISSED'
  final String status;
  final DateTime createdAt;
}

// ─── Mock data ────────────────────────────────────────────────────────────────
// Substitua por chamada real quando o backend entregar:
//   GET /api/reports?status=PENDING&page=1&limit=20
// Auth: JWT + ADMIN only

final _mockReports = [
  AdminReport(
    id: 'rep-001',
    reporterName: 'João Silva',
    targetType: 'USER',
    targetId: 'u-landlord-2',
    targetName: 'Roberto Imóveis',
    reason: 'Comportamento inadequado',
    description:
        'O proprietário utilizou linguagem agressiva durante a negociação e ameaçou o inquilino por mensagem.',
    status: 'PENDING',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  AdminReport(
    id: 'rep-002',
    reporterName: 'Fernanda Costa',
    targetType: 'PROPERTY',
    targetId: 'prop-sp-3',
    targetName: 'Apartamento Centro — Rua Augusta, 900',
    reason: 'Anúncio falso',
    description:
        'As fotos do anúncio não correspondem ao imóvel real. O apartamento está em estado muito diferente do apresentado.',
    status: 'PENDING',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  AdminReport(
    id: 'rep-003',
    reporterName: 'Carlos Souza',
    targetType: 'USER',
    targetId: 'u-landlord-1',
    targetName: 'Mariana Proprietária',
    reason: 'Golpe / Fraude',
    description:
        'Proprietária solicitou depósito antecipado via Pix antes de assinar qualquer contrato e sumiu após o pagamento.',
    status: 'REVIEWING',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AdminReport(
    id: 'rep-004',
    reporterName: 'Ana Lima',
    targetType: 'PROPERTY',
    targetId: 'prop-sp-7',
    targetName: 'Casa Pinheiros — Rua Harmonia, 200',
    reason: 'Informações incorretas',
    description:
        'O anúncio informa que aceita pets, mas ao entrar em contato o proprietário recusou animais de estimação.',
    status: 'RESOLVED',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  AdminReport(
    id: 'rep-005',
    reporterName: 'Pedro Alves',
    targetType: 'USER',
    targetId: 'u-tenant-3',
    targetName: 'Carlos Souza',
    reason: 'Comportamento inadequado',
    description:
        'Inquilino realizou visita e foi extremamente desrespeitoso com o porteiro e os outros moradores do condomínio.',
    status: 'DISMISSED',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];

// ─── Provider ─────────────────────────────────────────────────────────────────
// Quando o backend estiver pronto, trocar o retorno dos mocks por:
//   final response = await dio.get('/reports', queryParameters: {'status': filter});
//   return (response.data as List).map(AdminReport.fromJson).toList();

enum _ReportFilter { all, pending, reviewing, resolved }

extension on _ReportFilter {
  String get label {
    switch (this) {
      case _ReportFilter.all:
        return 'Todos';
      case _ReportFilter.pending:
        return 'Pendentes';
      case _ReportFilter.reviewing:
        return 'Em análise';
      case _ReportFilter.resolved:
        return 'Resolvidos';
    }
  }

  String? get statusValue {
    switch (this) {
      case _ReportFilter.all:
        return null;
      case _ReportFilter.pending:
        return 'PENDING';
      case _ReportFilter.reviewing:
        return 'REVIEWING';
      case _ReportFilter.resolved:
        return 'RESOLVED';
    }
  }
}

class _ReportFilterNotifier extends Notifier<_ReportFilter> {
  @override
  _ReportFilter build() => _ReportFilter.all;

  // Usado como método pelos call sites (`ref.read(...).select(f)`);
  // converter em setter quebraria a API consumida nos widgets.
  // ignore: use_setters_to_change_properties
  void select(_ReportFilter f) => state = f;
}

final _reportFilterProvider =
    NotifierProvider<_ReportFilterNotifier, _ReportFilter>(
  _ReportFilterNotifier.new,
);

// ─── Page ─────────────────────────────────────────────────────────────────────

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final activeFilter = ref.watch(_reportFilterProvider);

        final filtered = activeFilter.statusValue == null
            ? _mockReports
            : _mockReports
                .where((r) => r.status == activeFilter.statusValue)
                .toList();

        final pendingCount =
            _mockReports.where((r) => r.status == 'PENDING').length;

        return Column(children: [
          const BrutalistAppBar(title: 'Denúncias'),

          // Info banner — mock
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppRadius.borderLg,
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    size: 13, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Dados de demonstração. Conectar a GET /api/reports quando backend estiver pronto.',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.warning, fontSize: 10),
                  ),
                ),
              ]),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _ReportFilter.values.map((f) {
                  final isActive = f == activeFilter;
                  final isPending = f == _ReportFilter.pending;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () =>
                          ref.read(_reportFilterProvider.notifier).select(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isActive
                              ? accentColor.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: AppRadius.borderFull,
                          border: Border.all(
                            color: isActive
                                ? accentColor.withValues(alpha: 0.5)
                                : borderColor,
                          ),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            f.label,
                            style: AppTypography.titleSmallBold.copyWith(
                              color: isActive ? accentColor : mutedColor,
                              fontSize: 12,
                            ),
                          ),
                          if (isPending && pendingCount > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$pendingCount',
                                style: AppTypography.tagBadge.copyWith(
                                    color: AppColors.error, fontSize: 8),
                              ),
                            ),
                          ],
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma denúncia nesta categoria.',
                      style:
                          AppTypography.bodyMedium.copyWith(color: mutedColor),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _ReportCard(
                      report: filtered[i],
                      isDark: isDark,
                      onResolve: () => _handleAction(context, filtered[i], 'RESOLVED'),
                      onDismiss: () => _handleAction(context, filtered[i], 'DISMISSED'),
                      onReview: () => _showDetail(context, filtered[i], isDark),
                    ),
                  ),
          ),
        ]);
      },
    );
  }

  void _handleAction(BuildContext context, AdminReport report, String action) {
    final label = action == 'RESOLVED' ? 'resolvida' : 'arquivada';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Mensagem única de debug/demo; partir em várias linhas prejudica
        // legibilidade do snackbar no dispositivo.
        // ignore: lines_longer_than_80_chars
        content: Text('Denúncia #${report.id} marcada como $label (demo). Conectar a PATCH /api/reports/${report.id} quando backend estiver pronto.'),
      ),
    );
  }

  Future<void> _showDetail(
      BuildContext context, AdminReport report, bool isDark) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(report: report, isDark: isDark),
    );
  }
}

// ─── Report card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.isDark,
    required this.onResolve,
    required this.onDismiss,
    required this.onReview,
  });

  final AdminReport report;
  final bool isDark;
  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    final statusColor = _statusColor(report.status);
    final statusLabel = _statusLabel(report.status);
    final isActionable =
        report.status == 'PENDING' || report.status == 'REVIEWING';

    return GestureDetector(
      onTap: onReview,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(children: [
            // Target type icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                report.targetType == 'USER'
                    ? Icons.person_outline
                    : Icons.home_outlined,
                size: 18,
                color: statusColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.targetName,
                      style: AppTypography.titleSmallBold
                          .copyWith(color: titleColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.targetType == 'USER' ? 'Usuário' : 'Imóvel'} · Denunciado por ${report.reporterName}',
                      style: AppTypography.bodySmall
                          .copyWith(color: mutedColor, fontSize: 11),
                    ),
                  ]),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderFull,
              ),
              child: Text(statusLabel,
                  style: AppTypography.tagBadge
                      .copyWith(color: statusColor, fontSize: 9)),
            ),
          ]),

          const SizedBox(height: AppSpacing.sm),

          // Reason chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: BrutalistPalette.subtleBg(isDark),
              borderRadius: AppRadius.borderFull,
            ),
            child: Text(
              report.reason,
              style: AppTypography.tagBadge
                  .copyWith(color: mutedColor, fontSize: 10),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Description preview
          Text(
            report.description,
            style: AppTypography.bodySmall.copyWith(color: titleColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDate(report.createdAt),
            style: AppTypography.bodySmall
                .copyWith(color: mutedColor, fontSize: 10),
          ),

          // Actions
          if (isActionable) ...[
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: BrutalistPalette.subtleBg(isDark),
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                          color: BrutalistPalette.surfaceBorder(isDark)),
                    ),
                    alignment: Alignment.center,
                    child: Text('Arquivar',
                        style: AppTypography.titleSmallBold
                            .copyWith(color: mutedColor, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: onResolve,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: Text('Resolver',
                        style: AppTypography.titleSmallBold
                            .copyWith(color: AppColors.success, fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onReview,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: BrutalistPalette.subtleBg(isDark),
                    borderRadius: AppRadius.borderLg,
                    border: Border.all(
                        color: BrutalistPalette.surfaceBorder(isDark)),
                  ),
                  child: Icon(Icons.open_in_new_rounded,
                      size: 16, color: mutedColor),
                ),
              ),
            ]),
          ],
        ]),
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'PENDING':
        return AppColors.error;
      case 'REVIEWING':
        return AppColors.warning;
      case 'RESOLVED':
        return AppColors.success;
      case 'DISMISSED':
        return AppColors.info;
      default:
        return AppColors.info;
    }
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pendente';
      case 'REVIEWING':
        return 'Em análise';
      case 'RESOLVED':
        return 'Resolvido';
      case 'DISMISSED':
        return 'Arquivado';
      default:
        return status;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 1) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays} dia${diff.inDays > 1 ? 's' : ''}';
  }
}

// ─── Report detail sheet ──────────────────────────────────────────────────────

class _ReportDetailSheet extends StatelessWidget {
  const _ReportDetailSheet({required this.report, required this.isDark});
  final AdminReport report;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final bg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final statusColor = _ReportCard._statusColor(report.status);
    final statusLabel = _ReportCard._statusLabel(report.status);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Status badge
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(statusLabel,
                    style: AppTypography.tagBadge
                        .copyWith(color: statusColor, fontSize: 10)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: BrutalistPalette.subtleBg(isDark),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  report.targetType == 'USER' ? 'Usuário' : 'Imóvel',
                  style: AppTypography.tagBadge
                      .copyWith(color: mutedColor, fontSize: 10),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            _DetailRow(
              label: 'Denunciado',
              value: report.targetName,
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Denunciante',
              value: report.reporterName,
              isDark: isDark,
            ),
            _DetailRow(
              label: 'Motivo',
              value: report.reason,
              isDark: isDark,
            ),
            _DetailRow(
              label: 'ID do alvo',
              value: report.targetId,
              isDark: isDark,
              mono: true,
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Descrição',
                style: AppTypography.bodySmall.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
            const SizedBox(height: AppSpacing.xs),
            Text(report.description,
                style: AppTypography.bodyMedium.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xxl),

            // Endpoint note for backend team
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.06),
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Integração com backend',
                        style: AppTypography.tagBadge.copyWith(
                            color: AppColors.info, fontSize: 10)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'GET  /api/reports/:id\n'
                      'PATCH /api/reports/:id  { status: "RESOLVED" | "DISMISSED" }\n'
                      'Auth: JWT + ADMIN only',
                      style: AppTypography.bodySmall.copyWith(
                          color: mutedColor,
                          fontFamily: 'monospace',
                          fontSize: 10),
                    ),
                  ]),
            ),
            const SizedBox(height: AppSpacing.massive),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.mono = false,
  });

  final String label;
  final String value;
  final bool isDark;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: AppTypography.bodySmall.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
          ),
          Container(
              width: 1, height: 16, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm)),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: titleColor,
                fontFamily: mono ? 'monospace' : null,
                fontSize: mono ? 11 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
