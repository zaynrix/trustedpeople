import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/contactUs_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/utils/formatting_utils.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/adminActivitiesWidget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/analytics_column.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/analytics_row.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/analytics/visitor_chart.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/cards/admin_action_card.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/widgets/maintenance_management_widget.dart';
import 'package:trustedtallentsvalley/fetures/services/models/service_model.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_requests_provider.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class AdminDashboardWidget extends ConsumerWidget {
  const AdminDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsChartData = ref.watch(analyticsChartDataProvider);
    final analyticsData = ref.watch(analyticsDataProvider);
    final constraints =
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Welcome Banner
          Container(
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
          ),

          const SizedBox(height: 32),
          // Notifications and New Requests
          _buildNotificationsAndRequests(context, ref),
          const SizedBox(height: 32),
          // *** ADD MAINTENANCE MANAGEMENT SECTION HERE ***
          const MaintenanceManagementWidget(),

          const SizedBox(height: 32),
          // Visitor Analytics Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
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
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Refresh analytics data
                        ref.refresh(analyticsServiceProvider);
                        ref.refresh(analyticsChartDataProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('تحديث', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Display analytics data with loading state handling
                analyticsData.when(
                  data: (data) {
                    return constraints.maxWidth > 768
                        ? Consumer(
                            builder: (context, ref, child) {
                              final analyticsAsync =
                                  ref.watch(analyticsDataProvider);

                              return analyticsAsync.when(
                                data: (data) => AnalyticsRow(data: data),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Center(
                                  child: Text(
                                    'Error loading analytics: $error',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            },
                          )
                        : AnalyticsColumn(data: data);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'حدث خطأ أثناء تحميل البيانات: $error',
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Display chart with loading state handling
                analyticsChartData.when(
                  data: (chartData) {
                    return SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: VisitorChart(chartData: chartData),
                    );
                  },
                  loading: () => Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'حدث خطأ في تحميل الرسم البياني',
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Card(
              child: ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: Text('المستخدمين المحظورين', style: GoogleFonts.cairo()),
            subtitle: Text(
              'إدارة المستخدمين المحظورين من الوصول للموقع',
              style: GoogleFonts.cairo(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.pushNamed(ScreensNames.blockedUsers),
            ),
          )),
          // Quick CRUD Activities
          const Row(
            children: [
              Expanded(
                child: AdminActionCard(
                  title: 'إدارة الموثوقين',
                  description: 'عرض وتعديل وإضافة مستخدمين موثوقين',
                  icon: Icons.verified_user,
                  color: Colors.green,
                  routeName: ScreensNames.trusted,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: AdminActionCard(
                  title: 'إدارة النصابين',
                  description: 'عرض وتعديل وإضافة مستخدمين نصابين',
                  icon: Icons.block,
                  color: Colors.red,
                  routeName: ScreensNames.untrusted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const AdminActivityWidget(),
        ],
      ),
    );
  }

  Widget _buildNotificationsAndRequests(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإشعارات والطلبات الجديدة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Service Requests Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment, color: Colors.blue),
                    ),

                    // Notification badge for service requests
                    Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(serviceRequestsProvider);

                        if (state.newRequestsCount > 0 &&
                            state.showNewRequestsBadge) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                state.newRequestsCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                        'طلبات الخدمة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final state = ref.watch(serviceRequestsProvider);
                          final pendingCount = state.newRequestsCount;

                          return Text(
                            pendingCount > 0
                                ? 'لديك $pendingCount طلبات جديدة في انتظار المراجعة'
                                : 'لا توجد طلبات جديدة',
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade700,
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
                    // Navigate to service requests page
                    context.goNamed(ScreensNames.serviceRequest);
                    // Clear the badge when navigating to requests page
                    ref
                        .read(serviceRequestsProvider.notifier)
                        .clearNewRequestsBadge();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'عرض الطلبات',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Messages Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.email, color: Colors.green),
                    ),

                    // Notification badge for contact messages
                    Consumer(
                      builder: (context, ref, child) {
                        final unreadCount =
                            ref.watch(unreadMessagesCountProvider).maybeWhen(
                                  data: (count) => count,
                                  orElse: () => 0,
                                );

                        if (unreadCount > 0) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                        'رسائل التواصل',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final unreadCount =
                              ref.watch(unreadMessagesCountProvider).maybeWhen(
                                    data: (count) => count,
                                    orElse: () => 0,
                                  );

                          return Text(
                            unreadCount > 0
                                ? 'لديك $unreadCount رسائل جديدة غير مقروءة'
                                : 'لا توجد رسائل جديدة',
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade700,
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
                    // Navigate to contact messages page
                    context.goNamed(ScreensNames.contactUs);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    'عرض الرسائل',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Activity Preview
          const SizedBox(height: 24),
          Text(
            'آخر الطلبات والرسائل',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Recent Service Requests Preview
          SizedBox(
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(serviceRequestsProvider);

                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${state.errorMessage}',
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  );
                }

                if (state.requests.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد طلبات حديثة',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                  );
                }

                // Show only the 3 most recent requests
                final recentRequests = state.requests.take(3).toList();

                return ListView.separated(
                  itemCount: recentRequests.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final request1 = recentRequests[index];
                    final isPending =
                        request1.status == ServiceRequestStatus.pending;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            request1.status.toString().contains('pending')
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                        child: Icon(
                          Icons.assignment,
                          color: request1.status.toString().contains('pending')
                              ? Colors.blue
                              : Colors.grey,
                        ),
                      ),
                      title: Text(
                        request1.serviceName,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'من ${request1.clientName} - ${FormattingUtils.formatDate(request1.createdAt.toDate())}',
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
                      trailing: request1.status.toString().contains('pending')
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'جديد',
                                style: GoogleFonts.cairo(
                                  color: Colors.blue.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: FormattingUtils.getStatusColorFromString(
                                        request1.status.toString())
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                FormattingUtils.getStatusTextFromString(
                                    request1.status.toString()),
                                style: GoogleFonts.cairo(
                                  color:
                                      FormattingUtils.getStatusColorFromString(
                                          request1.status.toString()),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                      onTap: () {
                        // Navigate to request details
                        context.pushNamed(
                          ScreensNames.serviceDetail,
                          pathParameters: {'id': request1.id},
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final analyticsDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final analytics = ref.watch(visitorAnalyticsProvider);

  // Create a stream that refreshes every 30 seconds
  return Stream.periodic(const Duration(seconds: 30), (_) async {
    final data = await analytics.getVisitorStats();
    return data;
  }).asyncMap((future) => future);
});
