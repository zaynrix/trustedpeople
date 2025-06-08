import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/home/dialogs/quick_actions_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/screens/admin_dashboard_screen.dart';
import 'package:trustedtallentsvalley/fetures/home/screens/user_home_content_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    // Watch auth state and providers safely
    final authState = ref.watch(authProvider);
    final isLoading = ref.watch(authLoadingProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isTrustedUser = ref.watch(isTrustedUserProvider);
    final isApproved = ref.watch(isApprovedProvider);

    // Handle loading state
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: isMobile,
          backgroundColor: Colors.teal,
          title: Text(
            'موثوق',
            style: GoogleFonts.cairo(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        drawer: isMobile ? const AppDrawer() : null,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Determine app bar color and title based on user status
    Color appBarColor = Colors.teal;
    String title = 'موثوق - الصفحة الرئيسية';

    if (authState.error == null && isAuthenticated) {
      if (isAdmin) {
        appBarColor = Colors.green.shade700;
        title = 'موثوق - لوحة التحكم';
      } else if (isTrustedUser && isApproved) {
        appBarColor = Colors.blue.shade700;
        title = 'موثوق - المستخدم الموثوق';
      } else if (isTrustedUser && !isApproved) {
        appBarColor = Colors.orange.shade700;
        title = 'موثوق - في انتظار الموافقة';
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: appBarColor,
        title: Text(
          title,
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // Show admin actions only for authenticated admins without errors
          if (isAdmin && authState.error == null) ...[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات النظام',
              onPressed: () {
                // Navigate to admin settings screen
                // You can implement this later
              },
            ),
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'لوحة الإحصائيات',
              onPressed: () {
                // Navigate to admin dashboard
                // context.goNamed('adminDashboard');
              },
            ),
          ],

          // Show user actions for trusted users
          if (isTrustedUser &&
              isApproved &&
              !isAdmin &&
              authState.error == null) ...[
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'الملف الشخصي',
              onPressed: () {
                // Navigate to user profile
                // context.goNamed('trustedUserProfile');
              },
            ),
          ],

          // Show auth error indicator if present
          if (authState.error != null)
            IconButton(
              icon: const Icon(Icons.error, color: Colors.red),
              tooltip: 'خطأ في المصادقة',
              onPressed: () {
                // Show error dialog or retry authentication
                _showAuthErrorDialog(context, authState.error!);
              },
            ),
        ],
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildContent(
                    context,
                    constraints,
                    authState,
                    isAdmin,
                    isTrustedUser,
                    isApproved,
                    isAuthenticated,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Show appropriate FAB based on user status
      floatingActionButton: _buildFloatingActionButton(
        context,
        authState,
        isAdmin,
        isTrustedUser,
        isApproved,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BoxConstraints constraints,
    authState,
    bool isAdmin,
    bool isTrustedUser,
    bool isApproved,
    bool isAuthenticated,
  ) {
    // Show error state if auth error exists
    if (authState.error != null) {
      return _buildErrorWidget(context, authState.error!);
    }

    // Show admin dashboard for admins
    if (isAdmin && isAuthenticated) {
      return const AdminDashboardWidget();
    }

    // Show user dashboard for approved trusted users
    if (isTrustedUser && isApproved && !isAdmin && isAuthenticated) {
      return _buildTrustedUserDashboard(context, authState);
    }

    // Show pending status for unapproved trusted users
    if (isTrustedUser && !isApproved && !isAdmin && isAuthenticated) {
      return _buildPendingStatusWidget(context, authState);
    }

    // Show public content for non-authenticated users or regular users
    return HomeContentWidget(constraints: constraints);
  }

  Widget _buildTrustedUserDashboard(BuildContext context, authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome message
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.blue, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً ${authState.userData?['fullName'] ?? authState.userData?['profile']?['fullName'] ?? 'المستخدم'}',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مستخدم موثوق معتمد',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Quick actions for trusted users
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(
                context,
                Icons.person,
                'إدارة الملف الشخصي',
                'تحديث بياناتك الشخصية',
                Colors.blue,
                () {
                  // Navigate to profile
                },
              ),
              _buildActionCard(
                context,
                Icons.dashboard,
                'لوحة التحكم',
                'عرض إحصائياتك',
                Colors.green,
                () {
                  // Navigate to dashboard
                },
              ),
              _buildActionCard(
                context,
                Icons.settings,
                'الإعدادات',
                'إعدادات الحساب',
                Colors.orange,
                () {
                  // Navigate to settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingStatusWidget(BuildContext context, authState) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pending,
                color: Colors.orange,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'طلبك قيد المراجعة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'مرحباً ${authState.userData?['fullName'] ?? authState.userData?['profile']?['fullName'] ?? 'المستخدم'}',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'تم استلام طلب انضمامك كمستخدم موثوق وهو قيد المراجعة من قبل فريق الإدارة. سيتم إشعارك عند الموافقة على الطلب.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Refresh status or navigate to status page
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  'تحديث الحالة',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'خطأ في المصادقة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Retry authentication or navigate to login
                },
                icon: const Icon(Icons.refresh),
                label: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    authState,
    bool isAdmin,
    bool isTrustedUser,
    bool isApproved,
  ) {
    // Don't show FAB if there's an auth error
    if (authState.error != null) return null;

    // Admin FAB
    if (isAdmin) {
      return FloatingActionButton.extended(
        onPressed: () {
          QuickActionsDialog.show(context);
        },
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: Text(
          'إضافة سريعة',
          style: GoogleFonts.cairo(),
        ),
      );
    }

    // Trusted user FAB (for approved users)
    if (isTrustedUser && isApproved && !isAdmin) {
      return FloatingActionButton.extended(
        onPressed: () {
          // Show trusted user quick actions
          _showTrustedUserActions(context);
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.dashboard),
        label: Text(
          'إجراءات سريعة',
          style: GoogleFonts.cairo(),
        ),
      );
    }

    return null;
  }

  void _showAuthErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'خطأ في المصادقة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          error,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'موافق',
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
      ),
    );
  }

  void _showTrustedUserActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إجراءات سريعة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('تحديث الملف الشخصي', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text('عرض الإحصائيات', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                // Navigate to dashboard
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text('إعدادات الحساب', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
