import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../admin_users/domain/entities/admin_user.dart';
import '../../../admin_users/presentation/providers/admin_users_notifier.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor = isDark
            ? BrutalistPalette.warmOrange
            : BrutalistPalette.deepOrange;

        final async = ref.watch(adminUsersNotifierProvider);

        return Column(children: [
          const BrutalistAppBar(title: 'Usuários'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar usuários.',
                    style: AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ),
              data: (users) => RefreshIndicator(
                onRefresh: () =>
                    ref.read(adminUsersNotifierProvider.notifier).refresh(),
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: AppSpacing.lg,
                  ),
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/admin/users/new'),
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
                            Text('Novo usuário',
                                style: AppTypography.titleSmallBold
                                    .copyWith(color: accentColor)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    if (users.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Center(
                          child: Text(
                            'Nenhum usuário cadastrado.',
                            style: AppTypography.bodyMedium
                                .copyWith(color: mutedColor),
                          ),
                        ),
                      )
                    else
                      ...users.map((u) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm),
                            child: _UserTile(
                              user: u,
                              isDark: isDark,
                              onEdit: () =>
                                  context.push('/admin/users/${u.id}/edit'),
                              onDelete: () =>
                                  _confirmDelete(context, ref, u),
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
      BuildContext context, WidgetRef ref, AdminUser user) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir ${user.name}?'),
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
      await ref
          .read(adminUsersNotifierProvider.notifier)
          .delete(user.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuário excluído.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });
  final AdminUser user;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: AppTypography.titleSmallBold.copyWith(color: accentColor),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: AppTypography.titleSmallBold.copyWith(color: titleColor)),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${user.roleLabel} · ${user.phoneNumber}',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_rounded, color: mutedColor),
          onPressed: onEdit,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.error),
          onPressed: onDelete,
          visualDensity: VisualDensity.compact,
        ),
      ]),
    );
  }
}
