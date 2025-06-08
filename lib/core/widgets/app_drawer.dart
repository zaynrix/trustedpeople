import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class AppDrawer extends ConsumerWidget {
  final bool isPermanent;

  const AppDrawer({Key? key, this.isPermanent = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isPermanent
        ? _buildPermanentDrawer(context, ref)
        : Drawer(child: _buildDrawerContent(context, ref));
  }

  Widget _buildDrawerContent(BuildContext context, WidgetRef ref) {
    // Watch auth state and providers safely
    final authState = ref.watch(authProvider);
    final isLoading = ref.watch(authLoadingProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isTrustedUser = ref.watch(isTrustedUserProvider);
    final isApproved = ref.watch(isApprovedProvider);

    // Show loading indicator during auth operations
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (!isPermanent)
          _buildDrawerHeader(context, authState, isAdmin, isTrustedUser,
              isApproved, isAuthenticated),

        if (isPermanent)
          _buildPermanentHeader(context, authState, isAdmin, isTrustedUser,
              isApproved, isAuthenticated),
        Text("Text ${authState.user!.displayName}"),

        // Public navigation items (always shown)
        _buildNavigationItem(
          context,
          icon: Icons.home,
          label: "الصفحة الرئيسية",
          route: ScreensNames.home,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.verified_user,
          label: "قائمة الموثوقين",
          route: ScreensNames.trusted,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.block,
          label: "قائمة النصابين",
          route: ScreensNames.untrusted,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.payment_outlined,
          label: 'أماكن تقبل الدفع البنكي',
          route: ScreensNames.ort,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.description,
          label: 'كيف تحمي نفسك؟',
          route: ScreensNames.instruction,
          isPermanent: isPermanent,
        ),
        _buildNavigationItem(
          context,
          icon: Icons.shopping_cart,
          label: 'اطلب خدمتك',
          route: ScreensNames.services,
          isPermanent: isPermanent,
        ),

        // Admin-only navigation items
        if (isAdmin && authState.error == null) ...[
          const Divider(),
          _buildNavigationItem(
            context,
            icon: Icons.dashboard,
            label: 'لوحة الإحصائيات',
            route: 'adminDashboard',
            isPermanent: isPermanent,
          ),
          _buildNavigationItem(
            context,
            icon: Icons.people,
            label: 'إدارة طلبات المستخدمين',
            route: ScreensNames.adminUserApplications,
            isPermanent: isPermanent,
          ),
          _buildNavigationItem(
            context,
            icon: Icons.admin_panel_settings,
            label: 'إدارة الخدمات',
            route: ScreensNames.adminServices,
            isPermanent: isPermanent,
          ),
          _buildNavigationItem(
            context,
            icon: Icons.support_agent,
            label: 'طلبات الخدمات',
            route: ScreensNames.adminServiceRequests,
            isPermanent: isPermanent,
          ),
        ],

        // Trusted user navigation items (only for approved trusted users)
        if (isTrustedUser &&
            isApproved &&
            !isAdmin &&
            authState.error == null) ...[
          const Divider(),
          _buildNavigationItem(
            context,
            icon: Icons.dashboard,
            label: 'لوحة التحكم',
            route: 'trustedUserDashboard',
            isPermanent: isPermanent,
          ),
          _buildNavigationItem(
            context,
            icon: Icons.person,
            label: 'إدارة الملف الشخصي',
            route: 'trustedUserProfile',
            isPermanent: isPermanent,
          ),
        ],

        // Pending user navigation (for users waiting approval)
        if (isTrustedUser &&
            !isApproved &&
            !isAdmin &&
            authState.error == null) ...[
          const Divider(),
          _buildNavigationItem(
            context,
            icon: Icons.pending,
            label: 'حالة الطلب',
            route: 'pendingUserStatus',
            isPermanent: isPermanent,
          ),
        ],

        // Contact us (always shown)
        const Divider(),
        _buildNavigationItem(
          context,
          icon: Icons.contact_mail,
          label: 'تواصل للاستفسارات',
          route: ScreensNames.contactUs,
          isPermanent: isPermanent,
        ),

        // Authentication section
        const Divider(),

        // Show logout for authenticated users
        if (isAuthenticated && authState.error == null)
          ListTile(
            dense: true,
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                color: Colors.red.shade400,
                fontSize: 14,
              ),
            ),
            onTap: () async {
              if (!isPermanent) Navigator.pop(context);
              try {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(ScreensNames.homePath);
                }
              } catch (e) {
                // Handle logout error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'خطأ في تسجيل الخروج: $e',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                }
              }
            },
          ),

        // Show login for non-authenticated users
        if (!isAuthenticated)
          ListTile(
            dense: true,
            leading: Icon(Icons.login, color: Colors.green.shade400),
            title: Text(
              'تسجيل الدخول',
              style: GoogleFonts.cairo(
                color: Colors.green.shade400,
                fontSize: 14,
              ),
            ),
            onTap: () {
              if (!isPermanent) Navigator.pop(context);
              context.go('/login'); // Adjust path as needed
            },
          ),

        // Show error indicator if auth error exists
        if (authState.error != null)
          ListTile(
            dense: true,
            leading: const Icon(Icons.error, color: Colors.red),
            title: Text(
              'خطأ في المصادقة',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              authState.error!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.red.shade300,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _showErrorDialog(context, authState.error!);
            },
          ),
      ],
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    authState,
    bool isAdmin,
    bool isTrustedUser,
    bool isApproved,
    bool isAuthenticated,
  ) {
    // Determine header color based on user status
    Color headerColor = Colors.black12;
    if (authState.error == null && isAuthenticated) {
      if (isAdmin) {
        headerColor = Colors.green.withOpacity(0.15);
      } else if (isTrustedUser && isApproved) {
        headerColor = Colors.blue.withOpacity(0.15);
      } else if (isTrustedUser && !isApproved) {
        headerColor = Colors.orange.withOpacity(0.15);
      }
    }

    return DrawerHeader(
      decoration: BoxDecoration(color: headerColor),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main title with logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 10),
                Text(
                  'موثوق',
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // User status indicators
            _buildUserStatusBadges(
                authState, isAdmin, isTrustedUser, isApproved, isAuthenticated),
          ],
        ),
      ),
    );
  }

  Widget _buildPermanentHeader(
    BuildContext context,
    authState,
    bool isAdmin,
    bool isTrustedUser,
    bool isApproved,
    bool isAuthenticated,
  ) {
    // Determine header color based on user status
    Color? headerColor;
    if (authState.error == null && isAuthenticated) {
      if (isAdmin) {
        headerColor = Colors.green.withOpacity(0.15);
      } else if (isTrustedUser && isApproved) {
        headerColor = Colors.blue.withOpacity(0.15);
      } else if (isTrustedUser && !isApproved) {
        headerColor = Colors.orange.withOpacity(0.15);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: headerColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main title with logo
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 8),
          Text(
            'موثوق',
            style: GoogleFonts.cairo(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // User status indicators
          _buildUserStatusBadges(
              authState, isAdmin, isTrustedUser, isApproved, isAuthenticated),
        ],
      ),
    );
  }

  Widget _buildUserStatusBadges(
    authState,
    bool isAdmin,
    bool isTrustedUser,
    bool isApproved,
    bool isAuthenticated,
  ) {
    if (authState.error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Text(
          'خطأ في المصادقة',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          'غير مسجل الدخول',
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey.shade800,
          ),
        ),
      );
    }

    if (isAdmin) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings,
                    color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Text(
                  'وضع المشرف',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              'البريد: ${authState.user?.email ?? ""}',
              style: GoogleFonts.cairo(
                color: Colors.black,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    if (isTrustedUser) {
      final userName = authState.userData?['fullName'] ??
          authState.userData?['profile']?['fullName'] ??
          'مستخدم';

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isApproved
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isApproved
                    ? Colors.blue.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved ? Icons.verified_user : Icons.pending,
                  color: isApproved ? Colors.blue : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isApproved
                        ? Colors.blue.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userName,
              style: GoogleFonts.cairo(
                color: Colors.black87,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPermanentDrawer(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: _buildDrawerContent(context, ref),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isPermanent,
  }) {
    // Get both the location path and the current route name
    final location = GoRouterState.of(context).matchedLocation;
    final currentRouteName = GoRouterState.of(context).name;

    // Check if this item's route matches the current route name
    bool isActive = currentRouteName == route;

    // Special case for home route which might have different path/name behavior
    if (route == ScreensNames.home && location == '/') {
      isActive = true;
    }

    // Additional checks for secure routes
    if (route == 'adminDashboard' &&
        location.startsWith('/secure-admin-784512/dashboard')) {
      isActive = true;
    }
    if (route == 'trustedUserDashboard' &&
        location.startsWith('/secure-trusted-895623/trusted-dashboard')) {
      isActive = true;
    }

    // Define a consistent green color
    final activeColor = Colors.green;

    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        color: isActive ? activeColor : null,
        size: 22,
      ),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          textStyle: TextStyle(
            color: isActive ? activeColor : null,
            fontWeight: isActive ? FontWeight.bold : null,
            fontSize: 14,
          ),
        ),
      ),
      tileColor: isActive ? Colors.grey.shade200 : null,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);

        try {
          // Use GoRouter for navigation with error handling
          if (route.startsWith('/')) {
            context.go(route);
          } else {
            context.goNamed(route);
          }
        } catch (e) {
          // Fallback to home if navigation fails
          context.go('/');
        }
      },
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
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
}
