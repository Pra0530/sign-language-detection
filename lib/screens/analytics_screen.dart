import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../widgets/glass_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final analytics = provider.analyticsService;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context),
                _buildOverviewCards(context, analytics),
                _buildAccuracyChart(context, analytics),
                _buildMistakenLetters(context, analytics),
                _buildUsageStats(context, analytics),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppGradients.primary.createShader(bounds),
            child: const Icon(Icons.analytics_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            'Analytics',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, dynamic analytics) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              '${analytics.accuracyPercentage.toStringAsFixed(1)}%',
              'Recognition\nAccuracy',
              Icons.track_changes_rounded,
              AppGradients.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              '${analytics.totalWords}',
              'Words\nFormed',
              Icons.text_fields_rounded,
              AppGradients.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Gradient gradient,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyChart(BuildContext context, dynamic analytics) {
    List<double> history;
    try {
      history = analytics.accuracyHistory;
    } catch (_) {
      history = [];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accuracy Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Last ${history.length} sessions',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No data yet — start translating!',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : _buildLineChart(history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<double> history) {
    try {
      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.glassDarkBorder,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 35,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                history.length,
                (i) => FlSpot(i.toDouble(), history[i].clamp(0, 100)),
              ),
              isCurved: true,
              gradient: AppGradients.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryPurple.withAlpha(77),
                    AppColors.primaryTeal.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Chart unavailable',
          style: TextStyle(color: AppColors.textTertiaryDark),
        ),
      );
    }
  }

  Widget _buildMistakenLetters(BuildContext context, dynamic analytics) {
    Map<String, int> mistakes;
    try {
      mistakes = analytics.mistakenLetters;
    } catch (_) {
      mistakes = {};
    }
    if (mistakes.isEmpty) return const SizedBox.shrink();

    final sortedEntries = mistakes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topMistakes = sortedEntries.take(8).toList();
    if (topMistakes.isEmpty) return const SizedBox.shrink();

    final maxValue = topMistakes.first.value.toDouble();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Mistaken Gestures',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Focus on practicing these letters',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildBarChart(topMistakes, maxValue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
      List<MapEntry<String, int>> topMistakes, double maxValue) {
    try {
      return BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= topMistakes.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      topMistakes[idx].key,
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(
            topMistakes.length,
            (i) => BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topMistakes[i].value.toDouble(),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.chartColors[i % AppColors.chartColors.length]
                          .withAlpha(128),
                      AppColors.chartColors[i % AppColors.chartColors.length],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return Center(
        child: Text(
          'Chart unavailable',
          style: TextStyle(color: AppColors.textTertiaryDark),
        ),
      );
    }
  }

  Widget _buildUsageStats(BuildContext context, dynamic analytics) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              Icons.calendar_today_rounded,
              'Total Sessions',
              '${analytics.totalSessions}',
              AppColors.primaryPurple,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              Icons.text_fields_rounded,
              'Letters Detected',
              '${analytics.totalLetters}',
              AppColors.primaryTeal,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              Icons.spellcheck_rounded,
              'Words Formed',
              '${analytics.totalWords}',
              AppColors.accentOrange,
            ),
            const SizedBox(height: 12),
            _buildStatRow(
              context,
              Icons.check_circle_outline,
              'Correct Detections',
              '${analytics.correctDetections}',
              AppColors.confidenceHigh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
