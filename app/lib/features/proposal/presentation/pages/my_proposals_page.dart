import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/proposal.dart';
import '../providers/proposals_notifier.dart';

/// Lista as propostas que o tenant logado enviou (status, valor, imóvel).
class MyProposalsPage extends ConsumerWidget {
  const MyProposalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async =
        ref.watch(proposalsProvider(const ProposalsArgs(asLandlord: false)));

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
                  title: 'Minhas Propostas',
                  subtitle: 'Acompanhe o status das propostas que você enviou',
                  onBack: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: async.when(
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
                      message: 'Não foi possível carregar suas propostas.',
                    ),
                    data: (proposals) => proposals.isEmpty
                        ? _Empty(
                            isDark: isDark,
                            titleColor: titleColor,
                            mutedColor: mutedColor,
                            message:
                                'Quando você enviar uma proposta para um imóvel, '
                                'ela aparece aqui.',
                          )
                        : Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                for (final p in proposals) ...[
                                  _ProposalCard(
                                    proposal: p,
                                    isDark: isDark,
                                    titleColor: titleColor,
                                    mutedColor: mutedColor,
                                    accentColor: accentColor,
                                    showCounterpartName: false,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                const SizedBox(height: AppSpacing.massive),
                              ],
                            ),
                          ),
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

/// Card compartilhado entre as duas telas — comportamento idêntico,
/// só muda se mostra o nome do contraponto (tenant) no topo.
class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.proposal,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.showCounterpartName,
    this.actions,
  });

  final Proposal proposal;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final bool showCounterpartName;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final statusColor = _statusColor(proposal.status);
    final propertyTitle =
        proposal.propertyTitle?.trim().isNotEmpty == true
            ? proposal.propertyTitle!
            : 'Imóvel';
    final tenantName =
        proposal.tenantName?.trim().isNotEmpty == true
            ? proposal.tenantName!
            : 'Inquilino';

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
                child: Text(
                  propertyTitle,
                  style: AppTypography.titleLargeBold
                      .copyWith(color: titleColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  proposal.status.label,
                  style: AppTypography.propertyTag
                      .copyWith(color: statusColor, fontSize: 10),
                ),
              ),
            ],
          ),
          if (showCounterpartName) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 14, color: mutedColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    tenantName,
                    style: AppTypography.bodySmall.copyWith(color: mutedColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valor proposto',
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor)),
                    const SizedBox(height: 2),
                    Text(
                      _formatBrl(proposal.proposedPrice),
                      style: AppTypography.titleMediumBold
                          .copyWith(color: accentColor),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Enviada em',
                      style: AppTypography.bodySmall
                          .copyWith(color: mutedColor)),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(proposal.createdAt),
                    style: AppTypography.titleSmallBold
                        .copyWith(color: titleColor),
                  ),
                ],
              ),
            ],
          ),
          if (proposal.message != null && proposal.message!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: BrutalistPalette.subtleBg(isDark),
                borderRadius: AppRadius.borderMd,
              ),
              child: Text(
                proposal.message!,
                style: AppTypography.bodySmall.copyWith(
                  color: titleColor.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (actions != null) ...[
            const SizedBox(height: AppSpacing.md),
            actions!,
          ],
        ],
      ),
    );
  }

  static Color _statusColor(ProposalStatus s) {
    switch (s) {
      case ProposalStatus.accepted:
        return AppColors.success;
      case ProposalStatus.rejected:
      case ProposalStatus.withdrawn:
        return AppColors.error;
      case ProposalStatus.counterOffer:
      case ProposalStatus.pending:
        return AppColors.warning;
    }
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
    return 'R\$ $buf,$decPart';
  }

  static String _formatDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
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
            Icon(Icons.description_outlined,
                size: 48, color: mutedColor.withValues(alpha: 0.4)),
            const SizedBox(height: AppSpacing.md),
            Text('Nenhuma proposta',
                style: AppTypography.headlineSmall.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl),
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

// Reexposto para a página de landlord usar o mesmo card.
class ProposalCard extends StatelessWidget {
  const ProposalCard({
    required this.proposal,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.showCounterpartName,
    this.actions,
    super.key,
  });

  final Proposal proposal;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final bool showCounterpartName;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    return _ProposalCard(
      proposal: proposal,
      isDark: isDark,
      titleColor: titleColor,
      mutedColor: mutedColor,
      accentColor: accentColor,
      showCounterpartName: showCounterpartName,
      actions: actions,
    );
  }
}

class ProposalsEmpty extends StatelessWidget {
  const ProposalsEmpty({
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
