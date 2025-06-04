import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:trustedtallentsvalley/app/extensions/app_extention.dart';
import 'package:trustedtallentsvalley/config/app_constant.dart';
import 'package:trustedtallentsvalley/config/app_utils.dart';
import 'package:trustedtallentsvalley/fetures/admin/adminDStatistcs/widgets/dashboard_widgets.dart';

import '../models/visitor_info.dart';
import '../providers/dashboard_provider.dart';

// ==================== Analytics Cards ====================
class AnalyticsCards extends ConsumerWidget {
  const AnalyticsCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsData = ref.watch(analyticsDataProvider);
    final stats = ref.watch(visitorStatsProvider);
    final crossAxisCount = Breakpoints.getGridColumns(context);
    final spacing = Breakpoints.getCardSpacing(context);

    final analyticsItems = [
      AnalyticsItem(
        value: AnalyticsUtils.formatNumber(stats['today'] ?? 0),
        title: 'زيارة اليوم',
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        subtitle:
            '${(stats['percentageChange'] ?? 0).toStringAsFixed(1)}% عن أمس',
        trend: (stats['percentageChange'] ?? 0) > 0,
      ),
      AnalyticsItem(
        value: AnalyticsUtils.formatNumber(stats['total'] ?? 0),
        title: 'إجمالي الزيارات',
        icon: Icons.people_rounded,
        color: AppColors.primary,
        subtitle:
            '${AnalyticsUtils.formatNumber(stats['month'] ?? 0)} زيارة هذا الشهر',
      ),
      AnalyticsItem(
        value: analyticsData['avgSessionDuration'] ?? '0:00',
        title: 'متوسط مدة الزيارة',
        icon: Icons.timer_rounded,
        color: AppColors.warning,
        subtitle: 'تحديث لحظي',
      ),
      AnalyticsItem(
        value: AnalyticsUtils.formatNumber(stats['unique'] ?? 0),
        title: 'زوار فريدون',
        icon: Icons.person_outline_rounded,
        color: Colors.purple,
        subtitle: 'آخر 30 يوماً',
      ),
      AnalyticsItem(
        value: '${analyticsData['bounceRate'] ?? '0'}%',
        title: 'معدل الارتداد',
        icon: Icons.exit_to_app_rounded,
        color: AppColors.error,
        subtitle: 'تحديث لحظي',
      ),
      AnalyticsItem(
        value: AnalyticsUtils.formatNumber(stats['countries'] ?? 0),
        title: 'عدد الدول',
        icon: Icons.public_rounded,
        color: Colors.teal,
        subtitle: 'دول مختلفة',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: context.isMobile ? 1.8 : 2.2,
      ),
      itemCount: analyticsItems.length,
      itemBuilder: (context, index) => analyticsItems[index],
    );
  }
}

// ==================== Visitor Chart ====================
class VisitorChart extends ConsumerWidget {
  const VisitorChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(chartDataProvider);
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartHeader(theme, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            SizedBox(
              height: Breakpoints.getChartHeight(context),
              child: chartData.isEmpty
                  ? const EmptyState(message: 'لا توجد بيانات متاحة')
                  : _buildBarChart(chartData, isMobile, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartHeader(ThemeData theme, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.bar_chart_rounded,
            color: Colors.purple,
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الزيارات خلال آخر 7 أيام',
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'إحصائيات يومية مفصلة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<Map<String, dynamic>> chartData,
    bool isMobile,
    ThemeData theme,
  ) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${chartData[groupIndex]['visits']} زائر',
                GoogleFonts.cairo(color: Colors.white),
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
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chartData[value.toInt()]['day'],
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 10 : 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.cairo(
                    fontSize: isMobile ? 10 : 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outline.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data['visits'] as num).toDouble(),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                width: isMobile ? 15 : 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ==================== Visitor Map ====================
class VisitorMap extends ConsumerWidget {
  const VisitorMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorLocations = ref.watch(visitorLocationsProvider);
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          title: _buildMapHeader(theme, isMobile),
          initiallyExpanded: !isMobile,
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: SizedBox(
                height: Breakpoints.getMapHeight(context),
                child: visitorLocations.isEmpty
                    ? const EmptyState(message: 'لا توجد بيانات متاحة')
                    : _buildMap(visitorLocations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapHeader(ThemeData theme, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.map_rounded,
            color: Colors.green,
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'خريطة الزوار',
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'المواقع الجغرافية للزوار',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap(List<VisitorInfo> visitorLocations) {
    final markers = visitorLocations
        .map((location) {
          final latitude = location.additionalData['latitude'] as num?;
          final longitude = location.additionalData['longitude'] as num?;

          if (latitude == null || longitude == null) return null;

          return Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(latitude.toDouble(), longitude.toDouble()),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_pin,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        })
        .whereType<Marker>()
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(25.0, 10.0),
          initialZoom: 2.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

// ==================== Visitor Filters ====================
class VisitorFilters extends ConsumerWidget {
  const VisitorFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterHeader(theme, isMobile),
            SizedBox(height: isMobile ? 16 : 20),
            if (isMobile) ...[
              _buildSearchField(ref, theme),
              const SizedBox(height: 12),
              _buildFilterDropdown(ref, theme),
            ] else
              Row(
                children: [
                  Expanded(flex: 2, child: _buildSearchField(ref, theme)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFilterDropdown(ref, theme)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.filter_list_rounded,
            color: Colors.indigo,
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تصفية وبحث',
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ابحث وصفّي بيانات الزوار',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(WidgetRef ref, ThemeData theme) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'بحث عن زائر (IP، بلد، مدينة)...',
        hintStyle: GoogleFonts.cairo(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      style: GoogleFonts.cairo(),
      onChanged: (value) =>
          ref.read(visitorSearchProvider.notifier).state = value,
    );
  }

  Widget _buildFilterDropdown(WidgetRef ref, ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'تصفية حسب',
        labelStyle: GoogleFonts.cairo(color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
      ),
      style: GoogleFonts.cairo(),
      value: ref.read(visitorFilterProvider),
      items: [
        DropdownMenuItem(
          value: '',
          child: Text('الكل', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'today',
          child: Text('اليوم', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'week',
          child: Text('هذا الأسبوع', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'month',
          child: Text('هذا الشهر', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'desktop',
          child: Text('أجهزة الكمبيوتر', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'mobile',
          child: Text('الأجهزة المحمولة', style: GoogleFonts.cairo()),
        ),
        DropdownMenuItem(
          value: 'tablet',
          child: Text('الأجهزة اللوحية', style: GoogleFonts.cairo()),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(visitorFilterProvider.notifier).state = value;
        }
      },
    );
  }
}

// ==================== Visitor Table ====================
class VisitorTable extends ConsumerWidget {
  const VisitorTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredVisitors = ref.watch(filteredVisitorsProvider);
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          title: _buildTableHeader(theme, isMobile, filteredVisitors.length),
          initiallyExpanded: !isMobile,
          children: [
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: filteredVisitors.isEmpty
                  ? const EmptyState(message: 'لا توجد نتائج مطابقة')
                  : VisitorList(
                      visitors: filteredVisitors.take(20).toList(),
                      ref: ref,
                    ),
            ),
            if (filteredVisitors.length > 20)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Text(
                    'يتم عرض أحدث 20 زائر من إجمالي ${filteredVisitors.length}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme, bool isMobile, int visitorCount) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.table_rows_rounded,
            color: Colors.blue,
            size: isMobile ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بيانات الزوار',
                style: GoogleFonts.cairo(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'عدد الزوار: ${AnalyticsUtils.formatNumber(visitorCount)}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Visitor List ====================
class VisitorList extends StatelessWidget {
  final List<VisitorInfo> visitors;
  final WidgetRef ref;

  const VisitorList({
    super.key,
    required this.visitors,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visitors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => VisitorCard(
        visitor: visitors[index],
        ref: ref,
      ),
    );
  }
}
