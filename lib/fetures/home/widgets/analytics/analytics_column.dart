import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/cards/analytic_item.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class AnalyticsColumn extends StatelessWidget {
  final Map<String, dynamic> data;

  const AnalyticsColumn({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle null or empty data
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Fix property name mismatch - monthlyVisits vs monthlyVisitors
    final monthlyVisits = data['monthlyVisitors'] ?? data['monthlyVisits'] ?? 0;

    // Ensure all values are properly formatted to avoid null errors
    final todayVisitors = data['todayVisitors'] ?? 0;
    final percentChange = data['percentChange'] ?? 0.0;
    final totalVisitors = data['totalVisitors'] ?? 0;
    final avgSessionDuration = data['avgSessionDuration'] ?? '0:00';

    return Column(
      children: [
        AnalyticItem(
          value: todayVisitors.toString(),
          label: 'زيارة اليوم',
          icon: Icons.trending_up,
          color: Colors.green,
          subtext: '${percentChange.toStringAsFixed(1)}% عن أمس',
          onTap: () {
            GoRouter.of(context).goNamed(ScreensNames.adminDashboard);
          },
        ),
        const SizedBox(height: 16),
        AnalyticItem(
          value: totalVisitors.toString(),
          label: 'إجمالي الزيارات',
          icon: Icons.people,
          color: Colors.blue,
          subtext: '$monthlyVisits زيارة هذا الشهر',
          onTap: () {
            GoRouter.of(context).goNamed(ScreensNames.adminDashboard);
          },
        ),
        const SizedBox(height: 16),
        AnalyticItem(
          value: avgSessionDuration,
          label: 'متوسط مدة الزيارة',
          icon: Icons.timer,
          color: Colors.orange,
          subtext: 'تحديث لحظي',
          onTap: () {
            GoRouter.of(context).goNamed(ScreensNames.adminDashboard);
          },
        ),
      ],
    );
  }
}