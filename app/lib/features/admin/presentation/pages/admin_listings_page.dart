import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../listing/presentation/providers/my_properties_notifier.dart';
import '../../../search/domain/entities/property.dart';

/// Admin moderation list — consumes the same property notifier as the
/// landlord "Meus imóveis" (the backend has no separate moderation feed
/// and no landlord-scoped filter today — see BACKEND_GAPS.md). Excluir
/// hits DELETE; approve/reject are visually inert because there's no
/// endpoint.
class AdminListingsPage extends ConsumerWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final async = ref.watch(myPropertiesNotifierProvider);

        return Column(children: [
          const BrutalistAppBar(title: 'Moderação'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar.',
                    style: AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: () => ref
                    .read(myPropertiesNotifierProvider.notifier)
                    .refresh(),
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  children: [
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Text(
                            'Nenhum imóvel a moderar.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: BrutalistPalette.muted(isDark)),
                          ),
                        ),
                      )
                    else
                      ...items.map((p) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm),
                            child: _ListingRow(
                              property: p,
                              isDark: isDark,
                              onDelete: () => _confirmDelete(context, ref, p.id),
                            ),
                          )),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover imóvel?'),
        content: const Text(
            'O imóvel será permanentemente removido do sistema.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(myPropertiesNotifierProvider.notifier).delete(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel removido.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.property,
    required this.isDark,
    required this.onDelete,
  });
  final Property property;
  final bool isDark;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property.title,
                  style: AppTypography.titleSmallBold.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${property.type} · ${property.price}',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Remover',
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }
}
