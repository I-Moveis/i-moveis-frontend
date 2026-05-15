import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/current_user_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../data/contract_repository.dart';

/// Lista os contratos do tenant logado (qualquer status). Bate
/// `GET /tenants/:tenantId/contracts` — o include traz property +
/// landlord, então não precisamos cruzar com outros providers.
class MyContractsPage extends ConsumerWidget {
  const MyContractsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(currentUserIdProvider);

    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
        ));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;

        return Opacity(
          opacity: fade.value,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: BrutalistPageHeader(
                  title: 'Meus Contratos',
                  subtitle: 'Histórico de aluguéis vinculados a você',
                  onBack: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: userIdAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.xxxl),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => _Empty(
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      message: 'Não foi possível carregar seus contratos.',
                    ),
                    data: (userId) {
                      if (userId == null || userId.isEmpty) {
                        return _Empty(
                          isDark: isDark,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                          message: 'Entre na sua conta para ver os contratos.',
                        );
                      }
                      final contractsAsync =
                          ref.watch(tenantContractsProvider(userId));
                      return contractsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.xxxl),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, __) => _Empty(
                          isDark: isDark,
                          titleColor: titleColor,
                          mutedColor: mutedColor,
                          message:
                              'Não foi possível carregar seus contratos.',
                        ),
                        data: (contracts) {
                          if (contracts.isEmpty) {
                            return _Empty(
                              isDark: isDark,
                              titleColor: titleColor,
                              mutedColor: mutedColor,
                              message:
                                  'Quando você assinar um contrato, ele aparece aqui.',
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                for (final c in contracts) ...[
                                  ContractCard(
                                    raw: c,
                                    isDark: isDark,
                                    titleColor: titleColor,
                                    mutedColor: mutedColor,
                                    accentColor: accentColor,
                                    showLandlord: true,
                                    showTenant: false,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                const SizedBox(height: AppSpacing.massive),
                              ],
                            ),
                          );
                        },
                      );
                    },
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

/// Card reutilizado nas duas telas (tenant e landlord). Os dados vêm
/// como Map porque o backend devolve includes que não cabem direto na
/// entidade `Contract` (que cobre só o contrato individual).
class ContractCard extends StatelessWidget {
  const ContractCard({
    required this.raw,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.showLandlord,
    required this.showTenant,
    super.key,
  });

  final Map<String, dynamic> raw;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final bool showLandlord;
  final bool showTenant;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    final property = raw['property'] as Map<String, dynamic>?;
    final landlord = raw['landlord'] as Map<String, dynamic>?;
    final tenant = raw['tenant'] as Map<String, dynamic>?;

    final propertyTitle = (property?['title'] as String?) ?? 'Imóvel';
    final propertyAddress = (property?['address'] as String?) ?? '';
    final landlordName = (landlord?['name'] as String?) ?? '—';
    final tenantName = (tenant?['name'] as String?) ?? '—';

    final monthlyRent = _parseDouble(raw['monthlyRent']);
    final startDate = DateTime.tryParse((raw['startDate'] ?? '').toString());
    final endDate = DateTime.tryParse((raw['endDate'] ?? '').toString());
    final status = (raw['status'] as String?) ?? 'PENDING';

    final statusLabel = _statusLabel(status);
    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
        boxShadow: BrutalistPalette.subtleShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(propertyTitle,
                        style: AppTypography.titleLargeBold
                            .copyWith(color: titleColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    if (propertyAddress.isNotEmpty)
                      Text(propertyAddress,
                          style: AppTypography.bodySmall
                              .copyWith(color: mutedColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  statusLabel,
                  style: AppTypography.propertyTag
                      .copyWith(color: statusColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (showLandlord)
            _row(Icons.person_outline_rounded, 'Locador', landlordName,
                titleColor, mutedColor),
          if (showTenant)
            _row(Icons.person_outline_rounded, 'Locatário', tenantName,
                titleColor, mutedColor),
          if (startDate != null && endDate != null)
            _row(
              Icons.event_outlined,
              'Vigência',
              '${_formatDate(startDate)} → ${_formatDate(endDate)}',
              titleColor,
              mutedColor,
            ),
          _row(
            Icons.attach_money_rounded,
            'Aluguel',
            _formatBrl(monthlyRent),
            accentColor,
            mutedColor,
            valueBold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String label,
    String value,
    Color valueColor,
    Color mutedColor, {
    bool valueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: mutedColor),
          const SizedBox(width: AppSpacing.sm),
          Text('$label:',
              style: AppTypography.bodySmall.copyWith(color: mutedColor)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: (valueBold
                      ? AppTypography.titleSmallBold
                      : AppTypography.bodySmall)
                  .copyWith(color: valueColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw) ?? 0;
    return 0;
  }

  static String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }

  static String _formatBrl(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '00';
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,$decPart/mês';
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Ativo';
      case 'TERMINATED':
        return 'Encerrado';
      case 'COMPLETED':
        return 'Concluído';
      case 'PENDING':
      default:
        return 'Pendente';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'TERMINATED':
        return AppColors.error;
      case 'COMPLETED':
        return AppColors.whiteMuted;
      case 'PENDING':
      default:
        return AppColors.warning;
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.message,
  });
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_turned_in_outlined,
                size: 48, color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhum contrato',
                style: AppTypography.headlineSmall.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: mutedColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContractsEmpty extends StatelessWidget {
  const ContractsEmpty({
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.message,
    super.key,
  });
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _Empty(
      isDark: isDark,
      titleColor: titleColor,
      mutedColor: mutedColor,
      message: message,
    );
  }
}
