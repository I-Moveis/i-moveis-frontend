import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

// ─── Filtros ──────────────────────────────────────────────────────────────────

enum _ContractFilter { all, active, pending, closed, expiring }

extension _ContractFilterLabel on _ContractFilter {
  String get label {
    switch (this) {
      case _ContractFilter.all:
        return 'Todos';
      case _ContractFilter.active:
        return 'Ativos';
      case _ContractFilter.pending:
        return 'Pendentes';
      case _ContractFilter.closed:
        return 'Encerrados';
      case _ContractFilter.expiring:
        return 'A vencer';
    }
  }

  static _ContractFilter fromSlug(String? slug) {
    switch (slug) {
      case 'ativos':
        return _ContractFilter.active;
      case 'pendentes':
        return _ContractFilter.pending;
      case 'encerrados':
        return _ContractFilter.closed;
      case 'avencer':
        return _ContractFilter.expiring;
      default:
        return _ContractFilter.all;
    }
  }
}

// ─── Modelo de contrato (mock) ────────────────────────────────────────────────

enum _ContractStatus { active, pending, closed }

extension _ContractStatusLabel on _ContractStatus {
  String get label {
    switch (this) {
      case _ContractStatus.active:
        return 'Ativo';
      case _ContractStatus.pending:
        return 'Pendente';
      case _ContractStatus.closed:
        return 'Encerrado';
    }
  }

  Color get color {
    switch (this) {
      case _ContractStatus.active:
        return AppColors.success;
      case _ContractStatus.pending:
        return AppColors.pending;
      case _ContractStatus.closed:
        return AppColors.error;
    }
  }
}

class _Contract {
  const _Contract({
    required this.id,
    required this.status,
    required this.tenantName,
    required this.propertyLabel,
    this.endDate,
  });

  final String id;
  final _ContractStatus status;
  final String tenantName;
  final String propertyLabel;
  final DateTime? endDate;

  bool get isExpiringSoon {
    if (endDate == null || status == _ContractStatus.closed) return false;
    final daysLeft = endDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 30;
  }
}

// ─── Tela ─────────────────────────────────────────────────────────────────────

class AdminContractsPage extends StatefulWidget {
  const AdminContractsPage({super.key, this.initialFilter});

  /// Slug do filtro a ser pré-selecionado ao abrir a tela.
  /// Ex: 'avencer', 'ativos', 'pendentes', 'encerrados'.
  final String? initialFilter;

  @override
  State<AdminContractsPage> createState() => _AdminContractsPageState();
}

class _AdminContractsPageState extends State<AdminContractsPage> {
  late _ContractFilter _activeFilter;

  // Dados mockados aguardando GET /admin/contracts do backend.
  late final List<_Contract> _contracts;

  @override
  void initState() {
    super.initState();
    _activeFilter = _ContractFilterLabel.fromSlug(widget.initialFilter);

    final now = DateTime.now();
    _contracts = [
      _Contract(
        id: '1001',
        status: _ContractStatus.active,
        tenantName: 'Lucas Ferreira',
        propertyLabel: 'Rua das Flores, 42 — Apto 3',
        endDate: now.add(const Duration(days: 45)),
      ),
      const _Contract(
        id: '1002',
        status: _ContractStatus.pending,
        tenantName: 'Mariana Costa',
        propertyLabel: 'Av. Paulista, 1200 — Sala 5',
      ),
      _Contract(
        id: '1003',
        status: _ContractStatus.active,
        tenantName: 'Rafael Souza',
        propertyLabel: 'Rua XV de Novembro, 8 — Casa',
        endDate: now.add(const Duration(days: 20)),
      ),
      _Contract(
        id: '1004',
        status: _ContractStatus.active,
        tenantName: 'Beatriz Lima',
        propertyLabel: 'Rua do Comércio, 300 — Apto 1',
        endDate: now.add(const Duration(days: 12)),
      ),
      _Contract(
        id: '1005',
        status: _ContractStatus.closed,
        tenantName: 'Fernando Alves',
        propertyLabel: 'Alameda Santos, 89 — Apto 7',
        endDate: now.subtract(const Duration(days: 30)),
      ),
      _Contract(
        id: '1006',
        status: _ContractStatus.active,
        tenantName: 'Camila Ribeiro',
        propertyLabel: 'Rua Augusta, 512 — Cobertura',
        endDate: now.add(const Duration(days: 60)),
      ),
    ];
  }

  List<_Contract> get _filtered {
    switch (_activeFilter) {
      case _ContractFilter.all:
        return _contracts;
      case _ContractFilter.active:
        return _contracts
            .where((c) => c.status == _ContractStatus.active)
            .toList();
      case _ContractFilter.pending:
        return _contracts
            .where((c) => c.status == _ContractStatus.pending)
            .toList();
      case _ContractFilter.closed:
        return _contracts
            .where((c) => c.status == _ContractStatus.closed)
            .toList();
      case _ContractFilter.expiring:
        return _contracts.where((c) => c.isExpiringSoon).toList();
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
              parent: entrance,
              curve: const Interval(0.1, 0.5, curve: Curves.easeOut)),
        );
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final filtered = _filtered;

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                  child: BrutalistAppBar(title: 'Contratos')),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Filtros ──────────────────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _ContractFilter.values.map((f) {
                            final isActive = f == _activeFilter;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(right: AppSpacing.sm),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _activeFilter = f),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.sm),
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
                                  child: Text(
                                    f.label,
                                    style: AppTypography.titleSmallBold
                                        .copyWith(
                                      color: isActive ? accentColor : mutedColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Contagem ─────────────────────────────────
                      Text(
                        '${filtered.length} contrato${filtered.length != 1 ? 's' : ''}',
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Lista ─────────────────────────────────────
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xxl),
                          child: Center(
                            child: Text(
                              'Nenhum contrato nesta categoria.',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: mutedColor),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((c) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _ContractTile(
                                contract: c,
                                isDark: isDark,
                                accentColor: accentColor,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
                                formatDate: _formatDate,
                              ),
                            )),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tile de contrato ─────────────────────────────────────────────────────────

class _ContractTile extends StatelessWidget {
  const _ContractTile({
    required this.contract,
    required this.isDark,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.formatDate,
  });

  final _Contract contract;
  final bool isDark;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final status = contract.status;
    final expiring = contract.isExpiringSoon;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: expiring
                ? AppColors.warning.withValues(alpha: 0.4)
                : borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.article_outlined,
                  size: 20, color: accentColor.withValues(alpha: 0.5)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contrato #${contract.id}',
                      style: AppTypography.titleLargeBold
                          .copyWith(color: titleColor),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      contract.tenantName,
                      style:
                          AppTypography.bodySmall.copyWith(color: mutedColor),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      contract.propertyLabel,
                      style: AppTypography.bodySmall.copyWith(
                          color: mutedColor, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badge de status
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      status.label,
                      style: AppTypography.tagBadge
                          .copyWith(color: status.color),
                    ),
                  ),
                  // Badge "A vencer" quando aplicável
                  if (expiring) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: AppRadius.borderFull,
                      ),
                      child: Text(
                        'A vencer',
                        style: AppTypography.tagBadge
                            .copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: mutedColor.withValues(alpha: 0.4)),
            ]),
            // Data de vencimento
            if (contract.endDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  'Vencimento: ${formatDate(contract.endDate!)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: expiring ? AppColors.warning : mutedColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
