import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

// User Applications Statistics Provider
final userApplicationsStatsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final authNotifier = ref.read(authProvider.notifier);
  return await authNotifier.getApplicationStatistics();
});

// Widget to add to your existing admin dashboard
class UserApplicationsNavigationSection extends ConsumerWidget {
  const UserApplicationsNavigationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userApplicationsStatsProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.people_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلبات التسجيل',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        'إدارة طلبات المستخدمين الجدد',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Statistics
            statsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => _buildErrorWidget(),
              data: (stats) => _buildStatsGrid(stats, isMobile),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            if (isMobile)
              _buildMobileButtons(context)
            else
              _buildDesktopButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats, bool isMobile) {
    final statItems = [
      {
        'label': 'إجمالي الطلبات',
        'value': stats['total'] ?? 0,
        'color': Colors.blue,
        'icon': Icons.assignment,
      },
      {
        'label': 'قيد المراجعة',
        'value': stats['in_progress'] ?? 0,
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      },
      {
        'label': 'مقبولة',
        'value': stats['approved'] ?? 0,
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      {
        'label': 'مرفوضة',
        'value': stats['rejected'] ?? 0,
        'color': Colors.red,
        'icon': Icons.cancel,
      },
    ];

    if (isMobile) {
      return Column(
        children: statItems.map((item) => _buildStatCard(item, true)).toList(),
      );
    } else {
      return Row(
        children: statItems
            .map((item) => Expanded(child: _buildStatCard(item, false)))
            .toList(),
      );
    }
  }

  Widget _buildStatCard(Map<String, dynamic> item, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(
        bottom: isMobile ? 8 : 0,
        right: isMobile ? 0 : 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (item['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (item['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            item['icon'],
            color: item['color'],
            size: isMobile ? 24 : 20,
          ),
          const SizedBox(height: 8),
          Text(
            '${item['value']}',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: item['color'],
            ),
          ),
          Text(
            item['label'],
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 12 : 11,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () =>
              context.go('/secure-trusted-895623/user-applications'),
          icon: const Icon(Icons.list_alt),
          label: Text(
            'عرض جميع الطلبات',
            style: GoogleFonts.cairo(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(
              '/secure-trusted-895623/user-applications?filter=in_progress'),
          icon: const Icon(Icons.pending_actions),
          label: Text(
            'الطلبات المعلقة',
            style: GoogleFonts.cairo(fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange.shade600,
            side: BorderSide(color: Colors.orange.shade600),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: () =>
                context.go('/secure-trusted-895623/user-applications'),
            icon: const Icon(Icons.list_alt, size: 20),
            label: Text(
              'عرض جميع الطلبات',
              style: GoogleFonts.cairo(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go(
                '/secure-trusted-895623/user-applications?filter=in_progress'),
            icon: const Icon(Icons.pending_actions, size: 18),
            label: Text(
              'المعلقة',
              style: GoogleFonts.cairo(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade600,
              side: BorderSide(color: Colors.orange.shade600),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showQuickActions(context),
            icon: const Icon(Icons.more_horiz, size: 18),
            label: Text(
              'المزيد',
              style: GoogleFonts.cairo(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Text(
            'خطأ في تحميل الإحصائيات',
            style: GoogleFonts.cairo(
              color: Colors.red.shade800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => QuickActionsBottomSheet(),
    );
  }
}

// Quick Actions Bottom Sheet
class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'الطلبات المقبولة',
        'subtitle': 'عرض الطلبات المقبولة',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'route': '/secure-trusted-895623/user-applications?filter=approved',
      },
      {
        'title': 'الطلبات المرفوضة',
        'subtitle': 'عرض الطلبات المرفوضة',
        'icon': Icons.cancel,
        'color': Colors.red,
        'route': '/secure-trusted-895623/user-applications?filter=rejected',
      },
      {
        'title': 'تحتاج مراجعة',
        'subtitle': 'طلبات تحتاج مراجعة إضافية',
        'icon': Icons.rate_review,
        'color': Colors.blue,
        'route': '/secure-trusted-895623/user-applications?filter=needs_review',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...actions
              .map((action) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (action['color'] as Color).withOpacity(0.1),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['color'] as Color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      action['title'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      action['subtitle'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(action['route'] as String);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ))
              .toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Alternative: Simple Navigation Card (if you prefer a simpler approach)
class SimpleUserApplicationsCard extends ConsumerWidget {
  const SimpleUserApplicationsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userApplicationsStatsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go('/secure-trusted-895623/user-applications'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.people_outline,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طلبات التسجيل',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    statsAsync.when(
                      loading: () => Text(
                        'جارٍ التحميل...',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      error: (_, __) => Text(
                        'خطأ في التحميل',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                      data: (stats) => Text(
                        '${stats['total'] ?? 0} طلب - ${stats['in_progress'] ?? 0} في الانتظار',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
