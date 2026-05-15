import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/proposal.dart';
import '../providers/proposals_notifier.dart';
import 'my_proposals_page.dart';

/// Lista as propostas recebidas pelo landlord logado, com ações de
/// Aceitar / Recusar inline.
class ReceivedProposalsPage extends ConsumerStatefulWidget {
  const ReceivedProposalsPage({super.key});

  @override
  ConsumerState<ReceivedProposalsPage> createState() =>
      _ReceivedProposalsPageState();
}

class _ReceivedProposalsPageState
    extends ConsumerState<ReceivedProposalsPage> {
  /// IDs em transição (aguardando resposta do PATCH) — usado para
  /// desabilitar os botões durante a chamada.
  final _busy = <String>{};

  Future<void> _changeStatus(Proposal p, ProposalStatus next) async {
    setState(() => _busy.add(p.id));
    try {
      await updateProposalStatus(
        ref,
        id: p.id,
        status: next,
        asLandlord: true,
      );
      if (!mounted) return;
      _toast(next == ProposalStatus.accepted
          ? 'Proposta aceita.'
          : 'Proposta recusada.');
    } on DioException {
      if (mounted) _toast('Não foi possível atualizar a proposta.');
    } on Object {
      if (mounted) _toast('Erro inesperado.');
    } finally {
      if (mounted) setState(() => _busy.remove(p.id));
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final async =
        ref.watch(proposalsProvider(const ProposalsArgs(asLandlord: true)));

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
                  title: 'Propostas Recebidas',
                  subtitle: 'Avalie as propostas dos interessados',
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
                    error: (_, __) => ProposalsEmpty(
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      message: 'Não foi possível carregar as propostas.',
                    ),
                    data: (proposals) => proposals.isEmpty
                        ? ProposalsEmpty(
                            isDark: isDark,
                            titleColor: titleColor,
                            mutedColor: mutedColor,
                            message:
                                'Quando alguém enviar uma proposta para um '
                                'dos seus imóveis, ela aparece aqui.',
                          )
                        : Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              children: [
                                for (final p in proposals) ...[
                                  ProposalCard(
                                    proposal: p,
                                    isDark: isDark,
                                    titleColor: titleColor,
                                    mutedColor: mutedColor,
                                    accentColor: accentColor,
                                    showCounterpartName: true,
                                    actions: p.status == ProposalStatus.pending
                                        ? _Actions(
                                            isDark: isDark,
                                            busy: _busy.contains(p.id),
                                            onAccept: () => _changeStatus(
                                                p, ProposalStatus.accepted),
                                            onReject: () => _changeStatus(
                                                p, ProposalStatus.rejected),
                                          )
                                        : null,
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

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isDark,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });
  final bool isDark;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: busy ? null : onReject,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Text(
                  'Recusar',
                  style: AppTypography.titleSmallBold
                      .copyWith(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: BrutalistGradientButton(
            label: busy ? '...' : 'Aceitar',
            height: 44,
            icon: Icons.check_rounded,
            onTap: busy ? () {} : onAccept,
          ),
        ),
      ],
    );
  }
}
