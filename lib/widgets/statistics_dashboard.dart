import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/animation_config.dart';

/// Animated statistics dashboard widget
class StatisticsDashboard extends StatelessWidget {
  final int totalFavorites;
  final int totalDownloads;
  final Map<String, int>? categoryBreakdown;
  final List<DailyStats>? dailyStats;
  
  const StatisticsDashboard({
    super.key,
    required this.totalFavorites,
    required this.totalDownloads,
    this.categoryBreakdown,
    this.dailyStats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Favorites',
                value: totalFavorites,
                icon: Icons.favorite,
                color: Colors.pink,
                index: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Downloads',
                value: totalDownloads,
                icon: Icons.download,
                color: Colors.blue,
                index: 1,
              ),
            ),
          ],
        ),
        
        if (categoryBreakdown != null && categoryBreakdown!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _CategoryBreakdown(breakdown: categoryBreakdown!),
        ],
        
        if (dailyStats != null && dailyStats!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _ActivityChart(stats: dailyStats!),
        ],
      ],
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final int index;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: AnimationConfig.verySlow,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: AnimationConfig.staggerDelay * index,
          duration: AnimationConfig.normal,
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: AnimationConfig.staggerDelay * index,
          duration: AnimationConfig.normal,
          curve: AnimationConfig.bounceCurve,
        );
  }
}

/// Category breakdown widget
class _CategoryBreakdown extends StatelessWidget {
  final Map<String, int> breakdown;
  
  const _CategoryBreakdown({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold<int>(0, (sum, value) => sum + value);
    
    return LiquidGlassLayer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...breakdown.entries.map((entry) {
              final percentage = (entry.value / total * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryBar(
                  label: entry.key,
                  value: entry.value,
                  percentage: percentage,
                ),
              );
            }),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: AnimationConfig.normal,
          duration: AnimationConfig.normal,
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: AnimationConfig.normal,
          duration: AnimationConfig.normal,
        );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final int value;
  final int percentage;
  
  const _CategoryBar({
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Text(
              '$value ($percentage%)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: percentage / 100),
          duration: AnimationConfig.verySlow,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            );
          },
        ),
      ],
    );
  }
}

/// Activity chart widget
class _ActivityChart extends StatelessWidget {
  final List<DailyStats> stats;
  
  const _ActivityChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity (Last 7 Days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.length) {
                            return Text(
                              stats[value.toInt()].day,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: stats
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.count.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: AnimationConfig.slow,
          duration: AnimationConfig.normal,
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: AnimationConfig.slow,
          duration: AnimationConfig.normal,
        );
  }
}

/// Daily stats model
class DailyStats {
  final String day;
  final int count;
  
  const DailyStats({
    required this.day,
    required this.count,
  });
}
