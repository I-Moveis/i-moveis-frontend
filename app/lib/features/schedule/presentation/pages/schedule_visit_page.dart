import 'package:flutter/material.dart' hide DayPeriod;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../visits/domain/entities/available_slot.dart';
import '../../../visits/presentation/providers/schedule_visit_notifier.dart';

/// Schedule visit — cozy date/time selection wired to the visits repository.
class ScheduleVisitPage extends ConsumerStatefulWidget {
  const ScheduleVisitPage({required this.propertyId, super.key});
  final String propertyId;

  @override
  ConsumerState<ScheduleVisitPage> createState() =>
      _ScheduleVisitPageState();
}

class _ScheduleVisitPageState extends ConsumerState<ScheduleVisitPage> {
  final TextEditingController _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load availability for the default (tomorrow) selection after mount.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(scheduleVisitNotifierProvider.notifier)
          .loadAvailability(widget.propertyId);
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    // Reset shared state so next open starts fresh.
    ref.read(scheduleVisitNotifierProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(scheduleVisitNotifierProvider.notifier)
          .submit(widget.propertyId);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Visita agendada com sucesso!')),
      );
      Navigator.of(context).pop();
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

  void _onSelectDate(DateTime date) {
    ref.read(scheduleVisitNotifierProvider.notifier)
      ..selectDate(date)
      ..loadAvailability(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      resizeToAvoidBottomInset: true,
      builder: (context, isDark, entrance, pulse) {
        final fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: entrance,
          curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
        ));
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final state = ref.watch(scheduleVisitNotifierProvider);

        return Opacity(
          opacity: fade.value,
          child: Column(children: [
            const BrutalistAppBar(title: 'Agendar visita'),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Escolha uma data',
                        style: AppTypography.titleSmallBold.copyWith(
                            color: titleColor.withValues(alpha: 0.5))),
                    const SizedBox(height: AppSpacing.md),
                    _DateStrip(
                      selected: state.selectedDate,
                      onSelect: _onSelectDate,
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Horário',
                        style: AppTypography.titleSmallBold.copyWith(
                            color: titleColor.withValues(alpha: 0.5))),
                    const SizedBox(height: AppSpacing.md),
                    _SlotsSection(
                      state: state,
                      isDark: isDark,
                      titleColor: titleColor,
                      mutedColor: mutedColor,
                      accentColor: accentColor,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      onPick: (slot) => ref
                          .read(scheduleVisitNotifierProvider.notifier)
                          .selectSlot(slot),
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
                        controller: _notesCtrl,
                        maxLines: null,
                        expands: true,
                        onChanged: (v) => ref
                            .read(scheduleVisitNotifierProvider.notifier)
                            .updateNotes(v),
                        style: AppTypography.bodyLarge
                            .copyWith(color: titleColor),
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
                      label: state.submitting ? 'ENVIANDO...' : 'CONFIRMAR',
                      icon: Icons.check_rounded,
                      onTap: state.canSubmit ? _onConfirm : null,
                    ),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
  });

  final DateTime selected;
  final void Function(DateTime) onSelect;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = DateTime(now.year, now.month, now.day + i);
          final isPicked = date.year == selected.year &&
              date.month == selected.month &&
              date.day == selected.day;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(date),
              child: Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isPicked
                      ? accentColor.withValues(alpha: 0.12)
                      : cardBg,
                  borderRadius: AppRadius.borderLg,
                  border: Border.all(
                    color: isPicked
                        ? accentColor.withValues(alpha: 0.35)
                        : borderColor,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(labels[date.weekday - 1],
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(date.day.toString(),
                        style: AppTypography.headlineMediumBold.copyWith(
                          color: isPicked ? accentColor : titleColor,
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotsSection extends StatelessWidget {
  const _SlotsSection({
    required this.state,
    required this.isDark,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.onPick,
  });

  final ScheduleVisitState state;
  final bool isDark;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final void Function(AvailableSlot) onPick;

  @override
  Widget build(BuildContext context) {
    if (state.loadingSlots) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(color: accentColor, strokeWidth: 2),
        ),
      );
    }

    if (state.slotError != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Text(
          state.slotError!.message,
          style: AppTypography.bodyMedium.copyWith(color: mutedColor),
        ),
      );
    }

    if (state.slotsByPeriod.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: borderColor),
        ),
        child: Text(
          'Sem horários disponíveis nessa data.',
          style: AppTypography.bodyMedium.copyWith(color: mutedColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final period in DayPeriod.values)
          if ((state.slotsByPeriod[period] ?? const []).isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                period.label,
                style: AppTypography.bodySmallBold.copyWith(color: mutedColor),
              ),
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final slot in state.slotsByPeriod[period]!)
                  _SlotChip(
                    slot: slot,
                    selected: state.selectedSlot == slot,
                    onTap: () => onPick(slot),
                    titleColor: titleColor,
                    mutedColor: mutedColor,
                    accentColor: accentColor,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
              ],
            ),
          ],
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.selected,
    required this.onTap,
    required this.titleColor,
    required this.mutedColor,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
  });

  final AvailableSlot slot;
  final bool selected;
  final VoidCallback onTap;
  final Color titleColor;
  final Color mutedColor;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final label =
        '${_two(slot.startsAt.hour)}:${_two(slot.startsAt.minute)} – '
        '${_two(slot.endsAt.hour)}:${_two(slot.endsAt.minute)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.12) : cardBg,
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: selected
                ? accentColor.withValues(alpha: 0.35)
                : borderColor,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: selected ? accentColor : titleColor,
          ),
        ),
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
