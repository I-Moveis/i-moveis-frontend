import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../domain/entities/visit.dart';
import '../providers/edit_visit_notifier.dart';
import '../providers/visit_detail_provider.dart';

/// Allows the tenant to reschedule a visit (change date/time/notes). Submits
/// a PATCH; on 409 surfaces a snackbar and lets the user pick a new time.
class EditVisitPage extends ConsumerStatefulWidget {
  const EditVisitPage({required this.visitId, super.key});
  final String visitId;

  @override
  ConsumerState<EditVisitPage> createState() => _EditVisitPageState();
}

class _EditVisitPageState extends ConsumerState<EditVisitPage> {
  final TextEditingController _notesCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _initializeIfNeeded(Visit visit) {
    if (_initialized) return;
    _initialized = true;
    _notesCtrl.text = visit.notes ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editVisitNotifierProvider.notifier).init(visit);
    });
  }

  Future<void> _pickDate() async {
    final state = ref.read(editVisitNotifierProvider);
    if (state == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: state.scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(state.scheduledAt),
    );
    if (time == null) return;

    ref.read(editVisitNotifierProvider.notifier).updateScheduledAt(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
  }

  Future<void> _onSave(Visit original) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(editVisitNotifierProvider.notifier)
          .submit(original);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Visita atualizada.')),
      );
      router.pop();
    } on ConflictFailure catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Horário indisponível. Escolha outro.'),
        ),
      );
    } on Failure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(visitDetailProvider(widget.visitId));
    final formState = ref.watch(editVisitNotifierProvider);

    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        return Column(children: [
          const BrutalistAppBar(title: 'Reagendar visita'),
          Expanded(
            child: async.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    e is Failure ? e.message : 'Erro ao carregar visita.',
                    style: AppTypography.bodyMedium.copyWith(
                        color: BrutalistPalette.title(isDark)),
                  ),
                ),
              ),
              data: (visit) {
                _initializeIfNeeded(visit);
                if (formState == null) {
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                }
                return _Form(
                  visit: visit,
                  state: formState,
                  isDark: isDark,
                  notesCtrl: _notesCtrl,
                  onPickDateTime: _pickDate,
                  onNotesChanged: (v) => ref
                      .read(editVisitNotifierProvider.notifier)
                      .updateNotes(v),
                  onSave: () => _onSave(visit),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.visit,
    required this.state,
    required this.isDark,
    required this.notesCtrl,
    required this.onPickDateTime,
    required this.onNotesChanged,
    required this.onSave,
  });

  final Visit visit;
  final EditVisitState state;
  final bool isDark;
  final TextEditingController notesCtrl;
  final VoidCallback onPickDateTime;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accentColor =
        isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Data e hora',
              style: AppTypography.titleSmallBold.copyWith(
                  color: titleColor.withValues(alpha: 0.5))),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onPickDateTime,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: AppRadius.borderLg,
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_rounded, color: mutedColor),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _formatDateTime(state.scheduledAt),
                    style: AppTypography.titleSmall
                        .copyWith(color: titleColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Observações',
              style: AppTypography.titleSmallBold.copyWith(
                  color: titleColor.withValues(alpha: 0.5))),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 100,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.borderLg,
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: notesCtrl,
              maxLines: null,
              expands: true,
              onChanged: onNotesChanged,
              style: AppTypography.bodyLarge.copyWith(color: titleColor),
              cursorColor: accentColor,
              cursorWidth: 1.5,
              decoration: InputDecoration(
                hintText: 'Alguma observação? (opcional)',
                hintStyle: AppTypography.bodyLarge
                    .copyWith(color: BrutalistPalette.faint(isDark)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          BrutalistGradientButton(
            label: state.submitting ? 'SALVANDO...' : 'SALVAR',
            icon: Icons.check_rounded,
            onTap: state.submitting ? null : onSave,
          ),
          const SizedBox(height: AppSpacing.massive),
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year · $hh:$mm';
  }
}
