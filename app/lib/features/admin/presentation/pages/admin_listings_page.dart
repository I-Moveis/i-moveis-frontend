import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../search/domain/entities/property.dart';
import '../providers/moderation_queue_notifier.dart';

/// Fila de moderação admin — `GET /admin/properties?status=<X>`.
class AdminListingsPage extends ConsumerWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final async = ref.watch(moderationQueueNotifierProvider);
        final notifier = ref.read(moderationQueueNotifierProvider.notifier);
        final currentStatus = notifier.status;

        return Column(children: [
          const BrutalistAppBar(title: 'Moderação'),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            child: _StatusTabs(
              current: currentStatus,
              onSelect: notifier.setStatus,
              isDark: isDark,
            ),
          ),
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
                onRefresh: notifier.refresh,
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
                            'Nenhum imóvel ${_statusLabel(currentStatus).toLowerCase()}.',
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
                              status: currentStatus,
                              onApprove: () => _approve(context, ref, p.id),
                              onReject: () => _reject(context, ref, p.id),
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

  Future<void> _approve(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aprovar este anúncio?'),
        content: const Text('O imóvel ficará visível para inquilinos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(moderationQueueNotifierProvider.notifier).approve(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Anúncio aprovado.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<void> _reject(
      BuildContext context, WidgetRef ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final reason = await _askReason(context);
    if (reason == null) return;
    try {
      await ref
          .read(moderationQueueNotifierProvider.notifier)
          .reject(id, reason);
      messenger.showSnackBar(
        const SnackBar(content: Text('Anúncio rejeitado.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  Future<String?> _askReason(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeitar anúncio'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo (obrigatório)',
              hintText: 'Explique brevemente para o proprietário.',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Informe um motivo.';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Rejeitar'),
          ),
        ],
      ),
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
      await ref
          .read(moderationQueueNotifierProvider.notifier)
          .deleteProperty(id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Imóvel removido.')),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'APPROVED':
      return 'Aprovado';
    case 'REJECTED':
      return 'Rejeitado';
    case 'PENDING':
    default:
      return 'Pendente';
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.current,
    required this.onSelect,
    required this.isDark,
  });

  final String current;
  final ValueChanged<String> onSelect;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    const options = ['PENDING', 'APPROVED', 'REJECTED'];
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final opt in options)
          _StatusChip(
            label: _statusLabel(opt),
            selected: opt == current,
            onTap: () => onSelect(opt),
            isDark: isDark,
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? BrutalistPalette.title(isDark)
        : BrutalistPalette.surfaceBg(isDark);
    final fg = selected
        ? BrutalistPalette.surfaceBg(isDark)
        : BrutalistPalette.title(isDark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderFull,
          border: Border.all(color: BrutalistPalette.surfaceBorder(isDark)),
        ),
        child: Text(
          label,
          style: AppTypography.titleSmall.copyWith(color: fg),
        ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({
    required this.property,
    required this.isDark,
    required this.status,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });
  final Property property;
  final bool isDark;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    final showApprove = status != 'APPROVED';
    final showReject = status != 'REJECTED';

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
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            if (showApprove)
              IconButton(
                tooltip: 'Aprovar',
                icon: const Icon(Icons.check_circle_outline,
                    color: AppColors.success),
                onPressed: onApprove,
                visualDensity: VisualDensity.compact,
              ),
            if (showReject)
              IconButton(
                tooltip: 'Rejeitar',
                icon: const Icon(Icons.block, color: AppColors.warning),
                onPressed: onReject,
                visualDensity: VisualDensity.compact,
              ),
            IconButton(
              tooltip: 'Remover',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
          ]),
        ],
      ),
    );
  }
}
