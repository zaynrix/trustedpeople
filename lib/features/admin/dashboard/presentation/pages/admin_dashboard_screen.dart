import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/features/admin/core/widgets/analytics_card.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/presentation/widgets/visitor_chart.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/presentation/widgets/visitor_map.dart';
import 'package:trustedtallentsvalley/features/auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    // Watch dashboard data from providers
    final dashboardStats = ref.watch(dashboardStatsProvider);
    final chartData = ref.watch(chartDataProvider);
    final visitorLocations = ref.watch(visitorLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: Colors.green.shade700,
        title: Text(
          'ترست فالي - لوحة التحكم',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث البيانات',
            onPressed: () {
              ref.refresh(dashboardStatsProvider);
              ref.refresh(chartDataProvider);
              ref.refresh(visitorLocationsProvider);
            },
          ),
        ],
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: !isAdmin
          ? _buildAccessDeniedMessage(context)
          : LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (constraints.maxWidth > 768)
                      const AppDrawer(isPermanent: true),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildDashboardContent(context, constraints, ref,
                            dashboardStats, chartData, visitorLocations),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                _showQuickActionsMenu(context);
              },
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.add),
              label: Text(
                'إضافة سريعة',
                style: GoogleFonts.cairo(),
              ),
            )
          : null,
    );
  }

  // Dashboard content implementation
  Widget _buildDashboardContent(
      BuildContext context,
      BoxConstraints constraints,
      WidgetRef ref,
      AsyncValue<DashboardStats> dashboardStats,
      AsyncValue<List<ChartDataPoint>> chartData,
      AsyncValue<List<VisitorLocation>> visitorLocations) {
    final isSmallScreen = constraints.maxWidth < 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isSmallScreen),
          const SizedBox(height: 24),

          // Analytics cards section
          dashboardStats.when(
            data: (stats) =>
                _buildAnalyticsCards(stats, isSmallScreen, context),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error loading stats: $err'),
          ),

          const SizedBox(height: 24),

          // Chart section
          chartData.when(
            data: (data) =>
                VisitorChart(chartData: data, isSmallScreen: isSmallScreen),
            loading: () => _buildLoadingPlaceholder(200),
            error: (err, stack) => Text('Error loading chart: $err'),
          ),

          const SizedBox(height: 24),

          // Map section
          visitorLocations.when(
            data: (locations) =>
                VisitorMap(locations: locations, isSmallScreen: isSmallScreen),
            loading: () => _buildLoadingPlaceholder(300),
            error: (err, stack) => Text('Error loading map: $err'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings,
                  color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Text(
                'لوحة تحكم المشرف',
                style: GoogleFonts.cairo(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'مرحباً بك في لوحة التحكم، يمكنك إدارة المستخدمين ومراقبة النشاط هنا',
            style: GoogleFonts.cairo(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(
      DashboardStats stats, bool isSmallScreen, BuildContext context) {
    if (isSmallScreen) {
      return Column(
        children: [
          AnalyticsCard(
            value: stats.todayVisitors.toString(),
            title: 'زيارة اليوم',
            icon: Icons.trending_up,
            color: Colors.green,
            subtitle: '${stats.percentChange.toStringAsFixed(1)}% عن أمس',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          AnalyticsCard(
            value: stats.totalVisitors.toString(),
            title: 'إجمالي الزيارات',
            icon: Icons.people,
            color: Colors.blue,
            subtitle: '${stats.monthlyVisitors} زيارة هذا الشهر',
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 16),
          AnalyticsCard(
            value: stats.avgSessionDuration,
            title: 'متوسط مدة الزيارة',
            icon: Icons.timer,
            color: Colors.orange,
            subtitle: 'تحديث لحظي',
            isSmallScreen: isSmallScreen,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: AnalyticsCard(
              value: stats.todayVisitors.toString(),
              title: 'زيارة اليوم',
              icon: Icons.trending_up,
              color: Colors.green,
              subtitle: '${stats.percentChange.toStringAsFixed(1)}% عن أمس',
              isSmallScreen: isSmallScreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnalyticsCard(
              value: stats.totalVisitors.toString(),
              title: 'إجمالي الزيارات',
              icon: Icons.people,
              color: Colors.blue,
              subtitle: '${stats.monthlyVisitors} زيارة هذا الشهر',
              isSmallScreen: isSmallScreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnalyticsCard(
              value: stats.avgSessionDuration,
              title: 'متوسط مدة الزيارة',
              icon: Icons.timer,
              color: Colors.orange,
              subtitle: 'تحديث لحظي',
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      );
    }
  }

  // Access denied message for non-admins
  Widget _buildAccessDeniedMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 60,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'عذراً، هذه الصفحة للمشرفين فقط',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'لا تملك الصلاحيات الكافية للوصول إلى لوحة التحكم.',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    // Your existing quick actions menu implementation
  }
}
