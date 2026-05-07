import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/design_system.dart';
import '../../../admin_users/domain/entities/admin_user.dart';
import '../../../admin_users/presentation/providers/admin_users_notifier.dart';

/// Tela de novos usuários cadastrados num período selecionável.
///
/// O filtro de data é aplicado client-side sobre a lista retornada por
/// [adminUsersNotifierProvider]. A re-filtragem só ocorre quando o usuário
/// solta o slider ([RangeSlider.onChangeEnd]) — sem requisição extra.
class AdminNewUsersPage extends ConsumerStatefulWidget {
  const AdminNewUsersPage({super.key});

  @override
  ConsumerState<AdminNewUsersPage> createState() => _AdminNewUsersPageState();
}

class _AdminNewUsersPageState extends ConsumerState<AdminNewUsersPage> {
  // Período disponível: 1º do mês corrente até hoje.
  late final DateTime _monthStart;
  late final DateTime _today;
  late final int _totalDays; // dias disponíveis no slider (0 = dia 1, max = hoje)

  // Seleção atual do slider (em dias a partir de _monthStart).
  late RangeValues _sliderValues;

  // Datas correspondentes à seleção confirmada (aplicadas ao filtro).
  late DateTime _filterStart;
  late DateTime _filterEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _monthStart = DateTime(now.year, now.month);
    _totalDays = _today.difference(_monthStart).inDays;

    // Padrão: período completo (do dia 1 até hoje).
    _sliderValues = RangeValues(0, _totalDays.toDouble());
    _filterStart = _monthStart;
    _filterEnd = _today;
  }

  DateTime _dayToDate(double day) =>
      _monthStart.add(Duration(days: day.round()));

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  List<AdminUser> _applyFilter(List<AdminUser> users) {
    final start = DateTime(
        _filterStart.year, _filterStart.month, _filterStart.day);
    final end = DateTime(
        _filterEnd.year, _filterEnd.month, _filterEnd.day, 23, 59, 59);
    return users.where((u) {
      if (u.createdAt == null) return false;
      return !u.createdAt!.isBefore(start) && !u.createdAt!.isAfter(end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BrutalistPageScaffold(
      builder: (context, isDark, entrance, pulse) {
        final titleColor = BrutalistPalette.title(isDark);
        final mutedColor = BrutalistPalette.muted(isDark);
        final accentColor =
            isDark ? BrutalistPalette.warmOrange : BrutalistPalette.deepOrange;
        final cardBg = BrutalistPalette.surfaceBg(isDark);
        final borderColor = BrutalistPalette.surfaceBorder(isDark);

        final usersAsync = ref.watch(adminUsersNotifierProvider);

        return Column(children: [
          const BrutalistAppBar(title: 'Novos Usuários'),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Erro ao carregar usuários.',
                    style:
                        AppTypography.bodyMedium.copyWith(color: titleColor),
                  ),
                ),
              ),
              data: (users) {
                final filtered = _applyFilter(users);

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
                      // ── Seletor de período ──────────────────────────
                      _DateRangeSelector(
                        isDark: isDark,
                        sliderValues: _sliderValues,
                        totalDays: _totalDays,
                        filterStart: _filterStart,
                        filterEnd: _filterEnd,
                        accentColor: accentColor,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        titleColor: titleColor,
                        mutedColor: mutedColor,
                        formatDate: _formatDate,
                        onSliderChanged: (values) {
                          // Atualiza posição visual sem re-filtrar
                          setState(() => _sliderValues = values);
                        },
                        onSliderChangeEnd: (values) {
                          // Requisição/filtragem apenas ao soltar o slider
                          setState(() {
                            _sliderValues = values;
                            _filterStart = _dayToDate(values.start);
                            _filterEnd = _dayToDate(values.end);
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // ── Contagem ────────────────────────────────────
                      Text(
                        '${filtered.length} novo${filtered.length != 1 ? 's' : ''} no período',
                        style: AppTypography.bodySmall
                            .copyWith(color: mutedColor),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ── Lista ───────────────────────────────────────
                      if (filtered.isEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                          child: Center(
                            child: Text(
                              'Nenhum usuário cadastrado no período selecionado.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: mutedColor),
                            ),
                          ),
                        )
                      else
                        ...filtered.map((u) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: _NewUserTile(
                                user: u,
                                isDark: isDark,
                                accentColor: accentColor,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                titleColor: titleColor,
                                mutedColor: mutedColor,
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
}

// ─── Seletor de período ───────────────────────────────────────────────────────

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.isDark,
    required this.sliderValues,
    required this.totalDays,
    required this.filterStart,
    required this.filterEnd,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
    required this.formatDate,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
  });

  final bool isDark;
  final RangeValues sliderValues;
  final int totalDays;
  final DateTime filterStart;
  final DateTime filterEnd;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;
  final String Function(DateTime) formatDate;
  final ValueChanged<RangeValues> onSliderChanged;
  final ValueChanged<RangeValues> onSliderChangeEnd;

  @override
  Widget build(BuildContext context) {
    // Se o mês tem apenas 1 dia (hoje é dia 1), exibe mensagem simples.
    final isSingleDay = totalDays == 0;

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
          Text('Período',
              style:
                  AppTypography.titleSmallBold.copyWith(color: titleColor)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDate(filterStart),
                  style:
                      AppTypography.bodySmall.copyWith(color: accentColor)),
              Text(formatDate(filterEnd),
                  style:
                      AppTypography.bodySmall.copyWith(color: accentColor)),
            ],
          ),
          if (isSingleDay)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'Hoje é o primeiro dia do mês.',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
            )
          else
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: accentColor,
                thumbColor: accentColor,
                inactiveTrackColor: borderColor,
                overlayColor: accentColor.withValues(alpha: 0.12),
                rangeThumbShape:
                    const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: RangeSlider(
                max: totalDays.toDouble(),
                divisions: totalDays,
                values: sliderValues,
                // Atualiza apenas a posição visual enquanto arrasta
                onChanged: onSliderChanged,
                // Aplica o filtro somente ao soltar
                onChangeEnd: onSliderChangeEnd,
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Arraste para filtrar. O filtro é aplicado ao soltar.',
            style: AppTypography.bodySmall
                .copyWith(color: mutedColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─── Tile de usuário novo ─────────────────────────────────────────────────────

class _NewUserTile extends StatelessWidget {
  const _NewUserTile({
    required this.user,
    required this.isDark,
    required this.accentColor,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.mutedColor,
  });

  final AdminUser user;
  final bool isDark;
  final Color accentColor;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color mutedColor;

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: borderColor),
      ),
      child: Row(children: [
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
              Text(
                '${user.roleLabel} · ${user.phoneNumber}',
                style: AppTypography.bodySmall.copyWith(color: mutedColor),
              ),
              if (user.createdAt != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Cadastrado em ${_formatDate(user.createdAt!)}',
                  style: AppTypography.bodySmall
                      .copyWith(color: mutedColor, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
        // Badge de papel
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: AppRadius.borderFull,
          ),
          child: Text(
            user.roleLabel,
            style: AppTypography.tagBadge
                .copyWith(color: accentColor, fontSize: 9),
          ),
        ),
      ]),
    );
  }
}
