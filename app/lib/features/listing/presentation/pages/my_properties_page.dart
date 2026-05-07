import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';
import '../providers/my_properties_notifier.dart';

class MyPropertiesPage extends ConsumerWidget {
  const MyPropertiesPage({
    super.key,
    this.showBack = false,
    this.title = 'Meus imóveis',
  });

  final bool showBack;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark
            ? BrutalistPalette.warmOrange
            : BrutalistPalette.deepOrange;

        final async = ref.watch(myPropertiesNotifierProvider);

        // Quando aberta via bottom nav (showBack=false, default), mostra o
        // header padronizado com logo + subtítulo — mesmo visual de
        // "Meus Inquilinos" e "Conversas". Quando chegou por push de
        // outra tela (showBack=true), cai no AppBar com botão de voltar.
        return Column(children: [
          if (showBack)
            BrutalistAppBar(title: title, showBack: showBack)
          else
            const BrutalistPageHeader(
              title: 'Meus Imóveis',
              subtitle: 'Gerencie seus anúncios ativos',
            ),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => _ErrorView(
                message: e is Failure
                    ? e.message
                    : 'Não foi possível carregar seus imóveis.',
                onRetry: () => ref
                    .read(myPropertiesNotifierProvider.notifier)
                    .refresh(),
                isDark: isDark,
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
                    GestureDetector(
                      onTap: () =>
                          context.push('/my-properties/create'),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.08),
                          borderRadius: AppRadius.borderLg,
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 20, color: accentColor),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Novo anúncio',
                                style: AppTypography.titleSmallBold
                                    .copyWith(color: accentColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (items.isEmpty)
                      _EmptyView(isDark: isDark)
                    else
                      ...items.map((p) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.md),
                            child: _PropertyTile(
                              property: p,
                              isDark: isDark,
                              mutedColor: mutedColor,
                              onAnalytics: () => context.push(
                                  '/my-properties/${p.id}/analytics'),
                              onEdit: () => context.push(
                                  '/my-properties/${p.id}/edit'),
                              onDelete: () =>
                                  _confirmDelete(context, ref, p.id),
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
        title: const Text('Excluir imóvel?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(myPropertiesNotifierProvider.notifier).delete(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel excluído.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }
}

class _PropertyTile extends StatelessWidget {
  const _PropertyTile({
    required this.property,
    required this.isDark,
    required this.mutedColor,
    required this.onAnalytics,
    required this.onEdit,
    required this.onDelete,
  });

  final Property property;
  final bool isDark;
  final Color mutedColor;
  final VoidCallback onAnalytics;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
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
          if (property.address.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(property.address,
                style: AppTypography.bodySmall.copyWith(color: mutedColor)),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            _ActionIconButton(
              icon: Icons.edit_rounded,
              label: 'Editar',
              onTap: onEdit,
              isDark: isDark,
            ),
            const SizedBox(width: AppSpacing.sm),
            _ActionIconButton(
              icon: Icons.bar_chart_rounded,
              label: 'Análise',
              onTap: onAnalytics,
              isDark: isDark,
            ),
            const Spacer(),
            _ActionIconButton(
              icon: Icons.delete_outline_rounded,
              label: 'Excluir',
              onTap: onDelete,
              isDark: isDark,
              destructive: true,
            ),
          ]),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    final color = destructive ? AppColors.error : mutedColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: BrutalistPalette.subtleBg(isDark),
          borderRadius: AppRadius.borderMd,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Text(label,
                style: AppTypography.bodySmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final mutedColor = BrutalistPalette.muted(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 48, color: mutedColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Você ainda não tem imóveis anunciados.',
              textAlign: TextAlign.center,
              style:
                  AppTypography.bodyMedium.copyWith(color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: mutedColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            BrutalistGradientButton(
              label: 'TENTAR NOVAMENTE',
              icon: Icons.refresh_rounded,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
