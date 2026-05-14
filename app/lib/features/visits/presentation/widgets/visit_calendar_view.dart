import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/entities/visit.dart';

/// Smart agenda — calendário mensal com dots nos dias que têm visitas e
/// lista filtrada pelo dia selecionado abaixo.
///
/// Compartilhado entre `LandlordVisitsPage` (visitas nos imóveis do locador)
/// e `MyVisitsPage` (visitas agendadas pelo inquilino). A página passa a
/// lista já filtrada para o seu papel + um builder do tile (quem é o card
/// muda entre as duas) e o widget cuida da view de calendário.
///
/// Decisão de produto: dots usam estilo uniforme — não diferenciamos
/// visualmente visitas agendadas manualmente vs. agendadas pela IA (campo
/// `visit.source`). A infra está pronta pra quando o backend começar a
/// devolver o `source` e o produto quiser acender a distinção. Ver
/// `docs/BACKEND_VISIT_SOURCE.md`.
class VisitCalendarView extends StatefulWidget {
  const VisitCalendarView({
    required this.visits,
    required this.tileBuilder,
    this.onRefresh,
    super.key,
  });

  final List<Visit> visits;

  /// Constrói o card/tile de uma visita. Cada página tem seu próprio tile
  /// (tenant mostra o imóvel, landlord mostra o inquilino, etc.).
  final Widget Function(BuildContext context, Visit visit) tileBuilder;

  /// Opcional — pull-to-refresh. Quando nulo, a lista só rola.
  final Future<void> Function()? onRefresh;

  @override
  State<VisitCalendarView> createState() => _VisitCalendarViewState();
}

class _VisitCalendarViewState extends State<VisitCalendarView> {
  /// Primeira montagem ancora em "hoje" — na prática a maioria das visitas
  /// úteis é a de hoje ou a próxima, então abrir no mês atual com o dia
  /// de hoje selecionado é o caminho mais curto pro que o usuário quer ver.
  DateTime _focusedMonth = _startOfMonth(DateTime.now());
  DateTime _selectedDay = _stripTime(DateTime.now());

  /// Indexa visitas por dia (chave é meia-noite local) para o `eventLoader`
  /// do TableCalendar consultar em O(1) enquanto renderiza o grid mensal.
  /// Recalculado quando a lista de visitas muda.
  late Map<DateTime, List<Visit>> _visitsByDay;

  @override
  void initState() {
    super.initState();
    _visitsByDay = _groupByDay(widget.visits);
  }

  @override
  void didUpdateWidget(covariant VisitCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visits != widget.visits) {
      _visitsByDay = _groupByDay(widget.visits);
    }
  }

  static DateTime _stripTime(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
  static DateTime _startOfMonth(DateTime dt) => DateTime(dt.year, dt.month);

  static Map<DateTime, List<Visit>> _groupByDay(List<Visit> visits) {
    final map = <DateTime, List<Visit>>{};
    for (final v in visits) {
      final key = _stripTime(v.scheduledAt);
      (map[key] ??= <Visit>[]).add(v);
    }
    // Ordena cada dia por horário — o dia pode ter várias visitas.
    for (final list in map.values) {
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    }
    return map;
  }

  List<Visit> _eventsForDay(DateTime day) =>
      _visitsByDay[_stripTime(day)] ?? const <Visit>[];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visitsOfSelectedDay = _eventsForDay(_selectedDay);

    return Column(
      children: [
        _CalendarCard(
          isDark: isDark,
          focusedMonth: _focusedMonth,
          selectedDay: _selectedDay,
          eventsForDay: _eventsForDay,
          onDaySelected: (selected, focused) {
            setState(() {
              _selectedDay = _stripTime(selected);
              _focusedMonth = focused;
            });
          },
          onPageChanged: (focused) {
            // Só atualiza o mês sem mexer no dia selecionado — deixa o
            // usuário navegar meses sem perder o dia que tava olhando.
            _focusedMonth = focused;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _DayList(
            isDark: isDark,
            day: _selectedDay,
            visits: visitsOfSelectedDay,
            tileBuilder: widget.tileBuilder,
            onRefresh: widget.onRefresh,
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.isDark,
    required this.focusedMonth,
    required this.selectedDay,
    required this.eventsForDay,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  final bool isDark;
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<Visit> Function(DateTime day) eventsForDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focused) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cardBg = BrutalistPalette.surfaceBg(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);
    final accent = BrutalistPalette.accentOrange(isDark);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: TableCalendar<Visit>(
        locale: 'pt_BR',
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedMonth,
        selectedDayPredicate: (d) => isSameDay(d, selectedDay),
        availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
        eventLoader: eventsForDay,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTypography.titleSmallBold.copyWith(color: titleColor),
          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: mutedColor),
          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: mutedColor),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTypography.labelSmall.copyWith(color: mutedColor),
          weekendStyle: AppTypography.labelSmall.copyWith(color: mutedColor),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: AppTypography.bodyMedium.copyWith(color: titleColor),
          weekendTextStyle: AppTypography.bodyMedium.copyWith(color: titleColor),
          todayDecoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTypography.bodyMedium.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
          selectedDecoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.black : AppColors.white,
            fontWeight: FontWeight.w700,
          ),
          markerDecoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 5,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        ),
      ),
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({
    required this.isDark,
    required this.day,
    required this.visits,
    required this.tileBuilder,
    required this.onRefresh,
  });

  final bool isDark;
  final DateTime day;
  final List<Visit> visits;
  final Widget Function(BuildContext context, Visit visit) tileBuilder;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final titleColor = BrutalistPalette.title(isDark);
    final mutedColor = BrutalistPalette.muted(isDark);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.xs,
        AppSpacing.screenHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            _formatDayHeader(day),
            style: AppTypography.titleSmallBold.copyWith(color: titleColor),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            visits.isEmpty
                ? 'sem visitas'
                : '${visits.length} ${visits.length == 1 ? 'visita' : 'visitas'}',
            style: AppTypography.bodySmall.copyWith(color: mutedColor),
          ),
        ],
      ),
    );

    if (visits.isEmpty) {
      final empty = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_available_outlined, size: 40, color: mutedColor),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nenhuma visita para este dia.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: mutedColor),
              ),
            ],
          ),
        ),
      );
      final body = onRefresh != null
          ? RefreshIndicator(
              onRefresh: onRefresh!,
              child: ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                children: [empty],
              ),
            )
          : empty;
      return Column(children: [header, Expanded(child: body)]);
    }

    final list = ListView.separated(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        0,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      itemCount: visits.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) => tileBuilder(ctx, visits[i]),
    );

    return Column(children: [
      header,
      Expanded(
        child: onRefresh != null
            ? RefreshIndicator(onRefresh: onRefresh!, child: list)
            : list,
      ),
    ]);
  }

  static String _formatDayHeader(DateTime dt) {
    const weekdays = [
      'segunda', 'terça', 'quarta', 'quinta',
      'sexta', 'sábado', 'domingo',
    ];
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    final wd = weekdays[dt.weekday - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$wd, $day $month';
  }
}
