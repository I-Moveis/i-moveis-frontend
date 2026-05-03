import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import '../tokens/brutalist_palette.dart';
import '../tokens/app_radius.dart';

/// A brutalist-styled Bar Chart for analytical data.
class BrutalistBarChart extends StatelessWidget {
  const BrutalistBarChart({
    super.key,
    required this.data,
    required this.labels,
    required this.isDark,
    this.height = 240,
    this.title,
    this.valueSuffix = '',
  });

  final List<double> data;
  final List<String> labels;
  final bool isDark;
  final double height;
  final String? title;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final accentColor = BrutalistPalette.accentOrange(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final bgColor = BrutalistPalette.surfaceBg(isDark);
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.titleSmallBold.copyWith(
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: data.isEmpty ? 10 : (data.reduce((a, b) => a > b ? a : b) * 1.2),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.blackLight : AppColors.white,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()}$valueSuffix',
                      AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.white : AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[index],
                          style: AppTypography.monoSmall.copyWith(color: mutedColor, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: AppTypography.monoSmall.copyWith(color: mutedColor, fontSize: 10),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: borderColor.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value,
                      color: accentColor,
                      width: 14,
                      borderRadius: AppRadius.borderXs,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.black.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// A brutalist-styled Line Chart for analytical data.
class BrutalistLineChart extends StatelessWidget {
  const BrutalistLineChart({
    super.key,
    required this.points,
    required this.labels,
    required this.isDark,
    this.height = 240,
    this.title,
    this.valuePrefix = '',
  });

  final List<FlSpot> points;
  final List<String> labels;
  final bool isDark;
  final double height;
  final String? title;
  final String valuePrefix;

  @override
  Widget build(BuildContext context) {
    final accentColor = BrutalistPalette.accentPeach(isDark);
    final borderColor = BrutalistPalette.surfaceBorder(isDark);
    final bgColor = BrutalistPalette.surfaceBg(isDark);
    final mutedColor = isDark ? AppColors.whiteMuted : AppColors.lightTextTertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTypography.titleSmallBold.copyWith(
              color: isDark ? AppColors.white : AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        Container(
          height: height,
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.borderLg,
            border: Border.all(color: borderColor),
          ),
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => isDark ? AppColors.blackLight : AppColors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '$valuePrefix${spot.y.toInt()}',
                        AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.white : AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: borderColor.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          labels[index],
                          style: AppTypography.monoSmall.copyWith(color: mutedColor, fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      String text = value.toInt().toString();
                      if (value >= 1000) text = '${(value / 1000).toStringAsFixed(1)}k';
                      return Text(
                        text,
                        style: AppTypography.monoSmall.copyWith(color: mutedColor, fontSize: 10),
                      );
                    },
                    reservedSize: 32,
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: points,
                  isCurved: true,
                  color: accentColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 3,
                      color: accentColor,
                      strokeWidth: 1.5,
                      strokeColor: isDark ? AppColors.black : AppColors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
