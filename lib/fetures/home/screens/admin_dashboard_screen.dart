// File: lib/features/Home/widgets/enhanced_admin_dashboard_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/adminActivitiesWidget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/analytics_column.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/analytics_row.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/visitor_chart.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/cards/admin_action_card.dart';
import 'package:trustedtallentsvalley/fetures/admin/adminDStatistcs/providers/dashboard_provider.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/widgets/maintenance_management_widget.dart';
import 'package:trustedtallentsvalley/fetures/mouthoq/widgets/status_section_widget.dart';
import 'package:trustedtallentsvalley/fetures/services/notification_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/enhanced_analytics_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class AdminDashboardWidget extends ConsumerWidget {
  const AdminDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Initialize system monitoring
    ref.watch(systemMonitorProvider);
    ref.watch(dailySummaryProvider);

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return isMobile
        ? _buildMobileLayout(context, ref)
        : _buildWebLayout(context, ref, isDesktop);
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileWelcomeBanner(),
            const SizedBox(height: 20),
            _buildNotificationStatusCard(ref),
            const SizedBox(height: 20),
            _buildMobileQuickStats(ref),
            const SizedBox(height: 20),
            _buildMobileNotificationsCard(context, ref),
            const SizedBox(height: 20),
            // const UserApplicationsNavigationSection(),
            const SizedBox(height: 20),
            _buildMaintenanceCard(),
            const SizedBox(height: 20),
            _buildMobileAnalyticsCard(ref),
            const SizedBox(height: 20),
            _buildMobileManagementCards(context),
            const SizedBox(height: 20),
            _buildMobileRecentActivity(ref),
            const SizedBox(height: 20),
            _buildNotificationSettingsCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, WidgetRef ref, bool isDesktop) {
    final maxWidth = isDesktop ? 1400.0 : 1000.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWebHeader(ref),
              const SizedBox(height: 32),

              // Notification status row
              _buildNotificationStatusCard(ref),
              const SizedBox(height: 32),
              SimpleUserApplicationsCard(),
              // First row: Quick stats and notifications
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildWebQuickStats(ref, isDesktop),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: _buildWebNotificationsPanel(context, ref, isDesktop),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Second row: Analytics and maintenance
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildWebAnalyticsCard(ref, isDesktop),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildWebMaintenanceCard(isDesktop),
                        const SizedBox(height: 24),
                        _buildWebManagementGrid(context, isDesktop),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Third row: Recent activity and notification settings
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildWebRecentActivity(ref, isDesktop),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: _buildNotificationSettingsCard(),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // New notification status card
  Widget _buildNotificationStatusCard(WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.green.shade50],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظام الإشعارات نشط',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'سيتم إرسال التحديثات عبر WhatsApp و Telegram',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'متصل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return const NotificationSettingsWidget();
  }

  // Updated methods to use enhanced providers
  Widget _buildMobileQuickStats(WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إحصائيات سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مراقبة مباشرة',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final serviceRequests =
                    ref.watch(enhancedServiceRequestsProvider);
                final analyticsData = ref.watch(enhancedAnalyticsDataProvider);

                return Row(
                  children: [
                    Expanded(
                      child: _buildMobileStatItem(
                        icon: Icons.assignment,
                        label: 'طلبات جديدة',
                        value: serviceRequests.newRequestsCount.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: analyticsData.when(
                        data: (data) => _buildMobileStatItem(
                          icon: Icons.visibility,
                          label: 'الزيارات اليوم',
                          value: data['todayVisitors']?.toString() ?? '0',
                          color: Colors.green,
                        ),
                        loading: () => _buildMobileStatItem(
                          icon: Icons.visibility,
                          label: 'الزيارات اليوم',
                          value: '...',
                          color: Colors.green,
                        ),
                        error: (_, __) => _buildMobileStatItem(
                          icon: Icons.visibility,
                          label: 'الزيارات اليوم',
                          value: 'خطأ',
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNotificationsCard(BuildContext context, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإشعارات والطلبات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send, size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'إشعارات فورية',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMobileNotificationItem(
              context: context,
              ref: ref,
              icon: Icons.assignment,
              title: 'طلبات الخدمة',
              color: Colors.blue,
              isServiceRequests: true,
            ),
            const SizedBox(height: 12),
            _buildMobileNotificationItem(
              context: context,
              ref: ref,
              icon: Icons.email,
              title: 'رسائل التواصل',
              color: Colors.green,
              isServiceRequests: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileNotificationItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required Color color,
    required bool isServiceRequests,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final count = isServiceRequests
                      ? ref
                          .watch(enhancedServiceRequestsProvider)
                          .newRequestsCount
                      : ref
                          .watch(enhancedUnreadMessagesCountProvider)
                          .maybeWhen(
                            data: (count) => count,
                            orElse: () => 0,
                          );

                  if (count > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final count = isServiceRequests
                        ? ref
                            .watch(enhancedServiceRequestsProvider)
                            .newRequestsCount
                        : ref
                            .watch(enhancedUnreadMessagesCountProvider)
                            .maybeWhen(
                              data: (count) => count,
                              orElse: () => 0,
                            );

                    return Text(
                      count > 0 ? '$count جديد (سيتم الإشعار)' : 'لا توجد',
                      style: GoogleFonts.cairo(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (isServiceRequests) {
                context.goNamed(ScreensNames.serviceRequest);
                ref
                    .read(enhancedServiceRequestsProvider.notifier)
                    .clearNewRequestsBadge();
              } else {
                context.goNamed(ScreensNames.contactUs);
              }
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }

  // Continue with other methods using enhanced providers...
  Widget _buildMaintenanceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: MaintenanceManagementWidget(),
      ),
    );
  }

  Widget _buildMobileAnalyticsCard(WidgetRef ref) {
    final analyticsData = ref.watch(enhancedAnalyticsDataProvider);
    final analyticsChartData = ref.watch(analyticsChartDataProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تحليلات الزيارات',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.notifications_active,
                        size: 12,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        ref.refresh(analyticsServiceProvider);
                        ref.refresh(analyticsChartDataProvider);
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            analyticsData.when(
              data: (data) => AnalyticsColumn(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'خطأ في البيانات',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 16),
            analyticsChartData.when(
              data: (chartData) => SizedBox(
                height: 150,
                child: VisitorChart(chartData: chartData),
              ),
              loading: () => Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'خطأ في الرسم البياني',
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileManagementCards(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text('المستخدمين المحظورين', style: GoogleFonts.cairo()),
            subtitle: Text(
              'إدارة المستخدمين المحظورين',
              style: GoogleFonts.cairo(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.pushNamed(ScreensNames.blockedUsers),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: AdminActionCard(
                title: 'إدارة الموثوقين',
                description: 'المستخدمين الموثوقين',
                icon: Icons.verified_user,
                color: Colors.green,
                routeName: ScreensNames.trusted,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AdminActionCard(
                title: 'إدارة النصابين',
                description: 'المستخدمين النصابين',
                icon: Icons.block,
                color: Colors.red,
                routeName: ScreensNames.untrusted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileRecentActivity(WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'النشاط الحديث',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const AdminActivityWidget(),
          ],
        ),
      ),
    );
  }

  // Web-specific widgets with enhanced providers
  Widget _buildMobileWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
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
                  color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'لوحة تحكم المشرف',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'مرحباً بك في لوحة التحكم - الإشعارات مفعلة',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'لوحة تحكم المشرف',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'إشعارات فعالة',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في لوحة التحكم الشاملة - يمكنك إدارة المستخدمين ومراقبة النشاط وتحليل البيانات مع إشعارات فورية',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final serviceRequests =
                  ref.watch(enhancedServiceRequestsProvider);
              final unreadMessages =
                  ref.watch(enhancedUnreadMessagesCountProvider).maybeWhen(
                        data: (count) => count,
                        orElse: () => 0,
                      );

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'المتابعة المطلوبة',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${serviceRequests.newRequestsCount + unreadMessages}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebQuickStats(WidgetRef ref, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إحصائيات سريعة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مراقبة مباشرة',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Consumer(
            builder: (context, ref, child) {
              final serviceRequests =
                  ref.watch(enhancedServiceRequestsProvider);
              final analyticsData = ref.watch(enhancedAnalyticsDataProvider);

              return analyticsData.when(
                data: (data) => Column(
                  children: [
                    _buildWebStatItem(
                      icon: Icons.assignment,
                      label: 'طلبات جديدة',
                      value: serviceRequests.newRequestsCount.toString(),
                      color: Colors.blue,
                      hasNotification: serviceRequests.newRequestsCount > 0,
                    ),
                    const SizedBox(height: 16),
                    _buildWebStatItem(
                      icon: Icons.visibility,
                      label: 'زيارات اليوم',
                      value: data['todayVisitors']?.toString() ?? '0',
                      color: Colors.green,
                      hasNotification: true,
                    ),
                    const SizedBox(height: 16),
                    _buildWebStatItem(
                      icon: Icons.people,
                      label: 'إجمالي الزوار',
                      value: data['totalVisitors']?.toString() ?? '0',
                      color: Colors.orange,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => Center(
                  child: Text(
                    'خطأ في تحميل الإحصائيات',
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool hasNotification = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (hasNotification) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'إشعار',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNotificationsPanel(
      BuildContext context, WidgetRef ref, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإشعارات والطلبات الجديدة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'إشعارات فورية',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWebNotificationItem(
            context: context,
            ref: ref,
            icon: Icons.assignment,
            title: 'طلبات الخدمة',
            subtitle: 'طلبات جديدة تحتاج للمراجعة',
            color: Colors.blue,
            isServiceRequests: true,
          ),
          const SizedBox(height: 16),
          _buildWebNotificationItem(
            context: context,
            ref: ref,
            icon: Icons.email,
            title: 'رسائل التواصل',
            subtitle: 'رسائل جديدة من العملاء',
            color: Colors.green,
            isServiceRequests: false,
          ),
          const SizedBox(height: 24),
          _buildRecentRequestsPreview(ref),
        ],
      ),
    );
  }

  Widget _buildWebNotificationItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isServiceRequests,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final count = isServiceRequests
                      ? ref
                          .watch(enhancedServiceRequestsProvider)
                          .newRequestsCount
                      : ref
                          .watch(enhancedUnreadMessagesCountProvider)
                          .maybeWhen(
                            data: (count) => count,
                            orElse: () => 0,
                          );

                  if (count > 0) {
                    return Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final count = isServiceRequests
                        ? ref
                            .watch(enhancedServiceRequestsProvider)
                            .newRequestsCount
                        : ref
                            .watch(enhancedUnreadMessagesCountProvider)
                            .maybeWhen(
                              data: (count) => count,
                              orElse: () => 0,
                            );

                    return Text(
                      count > 0
                          ? '$count جديد - $subtitle (تم الإشعار)'
                          : 'لا توجد إشعارات جديدة',
                      style: GoogleFonts.cairo(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isServiceRequests) {
                context.goNamed(ScreensNames.serviceRequest);
                ref
                    .read(enhancedServiceRequestsProvider.notifier)
                    .clearNewRequestsBadge();
              } else {
                context.goNamed(ScreensNames.contactUs);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'عرض',
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebAnalyticsCard(WidgetRef ref, bool isDesktop) {
    final analyticsData = ref.watch(enhancedAnalyticsDataProvider);
    final analyticsChartData = ref.watch(analyticsChartDataProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تحليلات الزيارات',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.refresh(analyticsServiceProvider);
                      ref.refresh(analyticsChartDataProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('تحديث', style: GoogleFonts.cairo()),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          analyticsData.when(
            data: (data) => AnalyticsRow(data: data),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(
                'خطأ في تحميل البيانات',
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 24),
          analyticsChartData.when(
            data: (chartData) => SizedBox(
              height: 200,
              child: VisitorChart(chartData: chartData),
            ),
            loading: () => Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'خطأ في الرسم البياني',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebMaintenanceCard(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة الصيانة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const MaintenanceManagementWidget(),
        ],
      ),
    );
  }

  Widget _buildWebManagementGrid(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        // const UserApplicationsNavigationSection(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.block, color: Colors.red),
            ),
            title: Text('المستخدمين المحظورين', style: GoogleFonts.cairo()),
            subtitle: Text(
              'إدارة المستخدمين المحظورين',
              style: GoogleFonts.cairo(fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => context.pushNamed(ScreensNames.blockedUsers),
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: AdminActionCard(
                title: 'الموثوقين',
                description: 'إدارة المستخدمين الموثوقين',
                icon: Icons.verified_user,
                color: Colors.green,
                routeName: ScreensNames.trusted,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: AdminActionCard(
                title: 'النصابين',
                description: 'إدارة المستخدمين النصابين',
                icon: Icons.block,
                color: Colors.red,
                routeName: ScreensNames.untrusted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebRecentActivity(WidgetRef ref, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'النشاط الحديث',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const AdminActivityWidget(),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsPreview(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'آخر الطلبات',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(enhancedServiceRequestsProvider);

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.requests.isEmpty) {
              return Text(
                'لا توجد طلبات حديثة',
                style: GoogleFonts.cairo(color: Colors.grey),
              );
            }

            final recentRequests = state.requests.take(2).toList();

            return Column(
              children: recentRequests.map((request) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                request.status.toString().contains('pending')
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade100,
                            child: Icon(
                              Icons.assignment,
                              size: 16,
                              color:
                                  request.status.toString().contains('pending')
                                      ? Colors.blue
                                      : Colors.grey,
                            ),
                          ),
                          if (request.status.toString().contains('pending'))
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.serviceName,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'من ${request.clientName}',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (request.status.toString().contains('pending'))
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'جديد',
                                style: GoogleFonts.cairo(
                                  color: Colors.blue.shade800,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.notifications,
                                size: 8,
                                color: Colors.blue.shade800,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
