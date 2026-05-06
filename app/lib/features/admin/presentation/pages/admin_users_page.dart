import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../admin_users/domain/entities/admin_user.dart';
import '../../../admin_users/presentation/providers/admin_users_notifier.dart';

// ─── Role filter options ──────────────────────────────────────────────────────

enum _RoleFilter { all, tenant, landlord, admin }

extension _RoleFilterLabel on _RoleFilter {
  String get label {
    switch (this) {
      case _RoleFilter.all:
        return 'Todos';
      case _RoleFilter.tenant:
        return 'Inquilino';
      case _RoleFilter.landlord:
        return 'Proprietário';
      case _RoleFilter.admin:
        return 'Admin';
    }
  }

  String? get roleValue {
    switch (this) {
      case _RoleFilter.all:
        return null;
      case _RoleFilter.tenant:
        return 'TENANT';
      case _RoleFilter.landlord:
        return 'LANDLORD';
      case _RoleFilter.admin:
        return 'ADMIN';
    }
  }
}

// ─── State notifier for role filter ──────────────────────────────────────────

class _RoleFilterNotifier extends Notifier<_RoleFilter> {
  @override
  _RoleFilter build() => _RoleFilter.all;

  // Usado como método pelos call sites (`ref.read(...).select(f)`);
  // converter em setter quebraria a API consumida nos widgets.
  // ignore: use_setters_to_change_properties
  void select(_RoleFilter f) => state = f;
}

final _roleFilterProvider =
    NotifierProvider<_RoleFilterNotifier, _RoleFilter>(_RoleFilterNotifier.new);

// ─── Page ─────────────────────────────────────────────────────────────────────

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
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final async = ref.watch(adminUsersNotifierProvider);
        final activeFilter = ref.watch(_roleFilterProvider);

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
                    style:
                        AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ),
              data: (users) {
                // Client-side filter by role
                final filtered = activeFilter.roleValue == null
                    ? users
                    : users
                        .where((u) => u.role == activeFilter.roleValue)
                        .toList();

                return RefreshIndicator(
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
                      // New user button
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
                      const SizedBox(height: AppSpacing.lg),

                      // Role filter chips
                      _RoleFilterChips(
                        active: activeFilter,
                        accentColor: accentColor,
                        mutedColor: mutedColor,
                        borderColor: borderColor,
                        onSelect: (f) =>
                            ref.read(_roleFilterProvider.notifier).select(f),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // User count label
                      Text(
                        '${filtered.length} usuário${filtered.length != 1 ? 's' : ''}',
                        style:
                            AppTypography.bodySmall.copyWith(color: mutedColor),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Center(
                            child: Text(
                              'Nenhum usuário nesta categoria.',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: mutedColor),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((u) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _UserTile(
                                user: u,
                                isDark: isDark,
                                onEdit: () =>
                                    context.push('/admin/users/${u.id}/edit'),
                                onDelete: () =>
                                    _confirmDelete(context, ref, u),
                                onNotes: () =>
                                    _showNotesSheet(context, u, isDark),
                              ),
                            )),
                      const SizedBox(height: AppSpacing.massive),
                    ],
                  ),
                );
              },
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
      await ref.read(adminUsersNotifierProvider.notifier).delete(user.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Usuário excluído.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<void> _showNotesSheet(
      BuildContext context, AdminUser user, bool isDark) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotesSheet(user: user, isDark: isDark),
    );
  }
}

// ─── Role filter chips ────────────────────────────────────────────────────────

class _RoleFilterChips extends StatelessWidget {
  const _RoleFilterChips({
    required this.active,
    required this.accentColor,
    required this.mutedColor,
    required this.borderColor,
    required this.onSelect,
  });

  final _RoleFilter active;
  final Color accentColor;
  final Color mutedColor;
  final Color borderColor;
  final ValueChanged<_RoleFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _RoleFilter.values.map((f) {
          final isActive = f == active;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(f),
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
                child: Text(
                  f.label,
                  style: AppTypography.titleSmallBold.copyWith(
                    color: isActive ? accentColor : mutedColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── User tile ────────────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onNotes,
  });

  final AdminUser user;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onNotes;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // Avatar
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
                  style:
                      AppTypography.titleSmallBold.copyWith(color: accentColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      style: AppTypography.titleSmallBold
                          .copyWith(color: titleColor)),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(children: [
                    Text(
                      '${user.roleLabel} · ${user.phoneNumber}',
                      style:
                          AppTypography.bodySmall.copyWith(color: mutedColor),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Status badge — mockado (todos Ativo até backend ter o campo)
                    _StatusBadge(isDark: isDark),
                  ]),
                ],
              ),
            ),
            // Actions
            IconButton(
              icon: Icon(Icons.edit_note_rounded, color: mutedColor),
              tooltip: 'Notas internas',
              onPressed: onNotes,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.edit_rounded, color: mutedColor),
              tooltip: 'Editar',
              onPressed: onEdit,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: 'Excluir',
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ]),
          // Created at
          if (user.createdAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Text(
                'Desde ${_formatDate(user.createdAt!)}',
                style: AppTypography.bodySmall
                    .copyWith(color: mutedColor, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.borderFull,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('Ativo',
            style: AppTypography.tagBadge
                .copyWith(color: AppColors.success, fontSize: 9)),
      ]),
    );
  }
}

// ─── Notes bottom sheet ───────────────────────────────────────────────────────

class _NotesSheet extends StatefulWidget {
  const _NotesSheet({required this.user, required this.isDark});
  final AdminUser user;
  final bool isDark;

  @override
  State<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<_NotesSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  late String _prefKey;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _prefKey = 'admin_note_${widget.user.id}';
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey) ?? '';
    if (mounted) setState(() => _controller.text = saved);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _controller.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final bg = isDark ? const Color(0xFF1C1C1C) : Colors.white;
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            Text('Notas — ${widget.user.name}',
                style:
                    AppTypography.titleSmallBold.copyWith(color: titleColor)),
            const SizedBox(height: AppSpacing.xs),

            // "local" warning
            Row(children: [
              const Icon(Icons.info_outline, size: 12, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Salvo localmente neste dispositivo',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.warning, fontSize: 10),
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),

            Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                style: AppTypography.bodyMedium.copyWith(color: titleColor),
                decoration: InputDecoration(
                  hintText:
                      'Ex: Histórico de atraso no pagamento. Contato preferencial via WhatsApp.',
                  hintStyle:
                      AppTypography.bodySmall.copyWith(color: mutedColor),
                  contentPadding: const EdgeInsets.all(AppSpacing.lg),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: AppRadius.borderFull,
                  ),
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Salvar nota',
                          style: AppTypography.titleSmallBold
                              .copyWith(color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
