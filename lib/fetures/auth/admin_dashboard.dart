import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';
import 'package:trustedtallentsvalley/services/visitor_analytics_service.dart';

// Providers remain the same
final analyticsDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final chartDataProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
final visitorLocationsProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => true);
final analyticsServiceProvider = Provider((ref) => VisitorAnalyticsService());
final loadAnalyticsProvider = FutureProvider.autoDispose((ref) async {
  final isAdmin = ref.watch(isAdminProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);

  if (!isAdmin) {
    ref.read(isLoadingProvider.notifier).state = false;
    return;
  }

  ref.read(isLoadingProvider.notifier).state = true;

  try {
    final stats = await analyticsService.getVisitorStats();
    final chartData = await analyticsService.getVisitorChartData();
    final locationData = await analyticsService.getVisitorLocationData();

    ref.read(analyticsDataProvider.notifier).state = stats;
    ref.read(chartDataProvider.notifier).state = chartData;
    ref.read(visitorLocationsProvider.notifier).state = locationData;
  } catch (e) {
    debugPrint('Error loading analytics data: $e');
  } finally {
    ref.read(isLoadingProvider.notifier).state = false;
  }
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all state providers
    final isAdmin = ref.watch(isAdminProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final analyticsData = ref.watch(analyticsDataProvider);
    final chartData = ref.watch(chartDataProvider);
    final visitorLocations = ref.watch(visitorLocationsProvider);

    // Get screen size info
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    // Trigger data load when component builds
    ref.watch(loadAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم', style: GoogleFonts.cairo()),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.refresh(loadAnalyticsProvider),
              tooltip: 'تحديث البيانات',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isAdmin
              ? _buildAccessDeniedMessage(context)
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.refresh(loadAnalyticsProvider),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isSmallScreen),
                          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                          _buildAnalyticsCards(
                              analyticsData, isSmallScreen, context),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorChart(chartData, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorMap(visitorLocations, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorTable(
                              visitorLocations, isSmallScreen, context),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildAccessDeniedMessage(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: isSmallScreen ? 60 : 80,
              color: Colors.red.shade300,
            ),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            Text(
              'عذراً، هذه الصفحة للمشرفين فقط',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            Text(
              'لا تملك الصلاحيات الكافية للوصول إلى لوحة التحكم. يرجى التواصل مع المسؤول إذا كنت تعتقد أن هذا خطأ.',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text('العودة', style: GoogleFonts.cairo()),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Row(
      children: [
        Icon(Icons.admin_panel_settings,
            size: isSmallScreen ? 24 : 28, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'إحصائيات الموقع',
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analyticsData,
      bool isSmallScreen, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid columns based on screen size
    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 3; // Large screens - 3 cards in a row
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Medium screens - 2 cards in a row
    } else {
      crossAxisCount = 2; // Small screens - 1 card per row
    }

    return Padding(
      padding: EdgeInsets.all(
          isSmallScreen ? 8.0 : 12.0), // Add padding around the grid
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
        mainAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
        childAspectRatio:
            isSmallScreen ? 1.8 : 2.0, // Increased ratio makes items shorter
        children: [
          _buildAnalyticItem(
            analyticsData['todayVisitors']?.toString() ?? '0',
            'زيارة اليوم',
            Icons.trending_up,
            Colors.green,
            '${analyticsData['percentChange']?.toStringAsFixed(1) ?? '0'}% عن أمس',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['totalVisitors']?.toString() ?? '0',
            'إجمالي الزيارات',
            Icons.people,
            Colors.blue,
            '${analyticsData['monthlyVisitors'] ?? '0'} زيارة هذا الشهر',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['avgSessionDuration'] ?? '0:00',
            'متوسط مدة الزيارة',
            Icons.timer,
            Colors.orange,
            'تحديث لحظي',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  // Modified _buildAnalyticItem to support responsive sizing
  Widget _buildAnalyticItem(
    String value,
    String title,
    IconData icon,
    Color color,
    String subtitle, {
    required bool isSmallScreen,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorChart(
      List<Map<String, dynamic>> chartData, bool isSmallScreen) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insert_chart,
                    color: Colors.purple.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الزيارات خلال آخر 7 أيام',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            SizedBox(
              height: isSmallScreen ? 200 : 250,
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد بيانات متاحة',
                        style: GoogleFonts.cairo(),
                      ),
                    )
                  : _buildBarChart(chartData, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
      List<Map<String, dynamic>> chartData, bool isSmallScreen) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${chartData[groupIndex]['visits']} زائر',
                const TextStyle(color: Colors.white),
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
                      style:
                          GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
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
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data['visits'] as num).toDouble(),
                color: Colors.blue.shade400,
                width: isSmallScreen ? 15 : 20,
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

  Widget _buildVisitorMap(
      List<Map<String, dynamic>> visitorLocations, bool isSmallScreen) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Expandable section header
          ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.map,
                    color: Colors.green.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'خريطة الزوار',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            initiallyExpanded:
                !isSmallScreen, // Collapsed by default on small screens
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                child: SizedBox(
                  height: isSmallScreen ? 200 : 300,
                  child: visitorLocations.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد بيانات متاحة',
                            style: GoogleFonts.cairo(),
                          ),
                        )
                      : _buildMap(visitorLocations),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<Map<String, dynamic>> visitorLocations) {
    final markers = visitorLocations.map((location) {
      return Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(
          (location['latitude'] as num).toDouble(),
          (location['longitude'] as num).toDouble(),
        ),
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 24,
        ),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(25.0, 10.0),
        initialZoom: 2.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  Widget _buildVisitorTable(List<Map<String, dynamic>> visitorLocations,
      bool isSmallScreen, BuildContext context) {
    // For very small screens, we'll show a more mobile-friendly list view instead of a table
    final useListView = MediaQuery.of(context).size.width < 480;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Expandable section header
          ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.list_alt,
                    color: Colors.blue.shade700, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'بيانات الزوار',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'عدد الزوار: ${visitorLocations.length}',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade700,
              ),
            ),
            initiallyExpanded:
                !isSmallScreen, // Collapsed by default on small screens
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                child: useListView
                    ? _buildVisitorListView(visitorLocations, isSmallScreen)
                    : _buildVisitorTableView(visitorLocations, isSmallScreen),
              ),
              if (visitorLocations.length > 20)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      'يتم عرض أحدث 20 زائر من إجمالي ${visitorLocations.length}',
                      style: GoogleFonts.cairo(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Table view for larger screens
  Widget _buildVisitorTableView(
      List<Map<String, dynamic>> visitorLocations, bool isSmallScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: isSmallScreen ? 16 : 24,
        dataRowMinHeight: isSmallScreen ? 48 : 56,
        dataRowMaxHeight: isSmallScreen ? 64 : 72,
        columns: [
          DataColumn(
            label: Text(
              'التاريخ',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'عنوان IP',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'البلد',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'المدينة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'المنطقة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ],
        rows: visitorLocations.take(20).map((location) {
          // Format timestamp
          String formattedDate = 'غير معروف';
          if (location.containsKey('timestamp')) {
            final timestamp = DateTime.parse(location['timestamp'] as String);
            formattedDate =
                '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
          }

          return DataRow(
            cells: [
              DataCell(Text(formattedDate,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(location['ipAddress'] ?? 'غير معروف',
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(location['country'] ?? 'غير معروف',
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(location['city'] ?? 'غير معروف',
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(location['region'] ?? 'غير معروف',
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
            ],
          );
        }).toList(),
      ),
    );
  }

  // List view for mobile screens
  Widget _buildVisitorListView(
      List<Map<String, dynamic>> visitorLocations, bool isSmallScreen) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visitorLocations.length > 20 ? 20 : visitorLocations.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final location = visitorLocations[index];

        // Format timestamp
        String formattedDate = 'غير معروف';
        if (location.containsKey('timestamp')) {
          final timestamp = DateTime.parse(location['timestamp'] as String);
          formattedDate =
              '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${location['country'] ?? 'غير معروف'} - ${location['city'] ?? 'غير معروف'}',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'IP: ${location['ipAddress'] ?? 'غير معروف'}',
                style: GoogleFonts.cairo(fontSize: 13),
              ),
            ],
          ),
          subtitle: Text(
            'التاريخ: $formattedDate',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          trailing: Icon(
            Icons.location_on,
            color: Colors.redAccent,
            size: 18,
          ),
        );
      },
    );
  }
}
