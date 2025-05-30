import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

/// Main shell that provides a consistent layout with NavigationRail for all screens
class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _isRailExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Check screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    // Get admin status for conditional UI
    final isAdmin = ref.watch(isAdminProvider);
    final authState = ref.watch(authProvider);

    // If on mobile, use standard scaffold with drawer
    if (isMobile) {
      return Scaffold(
        drawer: const AppDrawer(),
        body: widget.child,
      );
    }

    // For desktop/tablet, use layout with custom navigation rail
    return Scaffold(
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          // NavigationRail (custom implementation)
          _buildCustomNavigationRail(context, isAdmin, authState),

          // Divider between rail and content
          const VerticalDivider(thickness: 1, width: 1),

          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildCustomNavigationRail(
    BuildContext context,
    bool isAdmin,
    AuthState authState,
  ) {
    // Get current route info for highlighting active item
    final location = GoRouterState.of(context).matchedLocation;
    final currentRouteName = GoRouterState.of(context).name;

    // Debug output to identify current route
    // debugPrint('Current location: $location');
    // debugPrint('Current route name: $currentRouteName');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isRailExpanded ? 280 : 80,
      color: Colors.grey.shade200,
      child: Column(
        children: [
          // Header with logo and admin info
          _buildRailHeader(isAdmin, authState),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Using exact route names and paths from ScreensNames
                  _buildNavItem(
                    context,
                    Icons.home,
                    "الصفحة الرئيسية",
                    ScreensNames.home,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.home, ScreensNames.homePath),
                  ),
                  _buildNavItem(
                    context,
                    Icons.verified_user,
                    "قائمة الموثوقين",
                    ScreensNames.trusted,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.trusted, ScreensNames.trustedPath),
                  ),
                  _buildNavItem(
                    context,
                    Icons.block,
                    "قائمة النصابين",
                    ScreensNames.untrusted,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.untrusted, ScreensNames.untrustedPath),
                  ),
                  _buildNavItem(
                    context,
                    Icons.payment_outlined,
                    "أماكن تقبل الدفع البنكي",
                    ScreensNames.ort,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.ort, ScreensNames.ortPath),
                  ),
                  _buildNavItem(
                    context,
                    Icons.description,
                    "كيف تحمي نفسك؟",
                    ScreensNames.instruction,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.instruction, ScreensNames.instructionPath),
                  ),
                  _buildNavItem(
                    context,
                    Icons.shopping_cart,
                    "اطلب خدمتك",
                    ScreensNames.services,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.services, '/services'),
                  ),

                  // Admin-only items with correct route names
                  if (isAdmin) ...[
                    _buildNavItem(
                      context,
                      Icons.admin_panel_settings,
                      "إدارة الخدمات",
                      ScreensNames.adminServices,
                      isActive: _isRouteActive(currentRouteName, location,
                          ScreensNames.adminServices, '/admin/services'),
                    ),
                    _buildNavItem(
                      context,
                      Icons.support_agent,
                      "طلبات الخدمات",
                      ScreensNames.adminServiceRequests,
                      isActive: _isRouteActive(
                          currentRouteName,
                          location,
                          ScreensNames.adminServiceRequests,
                          '/admin/service-requests'),
                    ),
                  ],

                  _buildNavItem(
                    context,
                    Icons.contact_mail,
                    "تواصل للاستفسارات",
                    ScreensNames.contactUs,
                    isActive: _isRouteActive(currentRouteName, location,
                        ScreensNames.contactUs, ScreensNames.contactUsPath),
                  ),
                ],
              ),
            ),
          ),

          // Footer with expand/collapse button and logout
          _buildLogoutButton(isAdmen: isAdmin),
        ],
      ),
    );
  }

  // Improved route matching logic
  bool _isRouteActive(String? currentRouteName, String location,
      String routeName, String routePath) {
    // Special case for home route
    if (routeName == ScreensNames.home && location == '/') {
      return true;
    }

    // Debug info when a potential match is found
    if (currentRouteName == routeName ||
        location == routePath ||
        location.startsWith(routePath)) {
      debugPrint('Match found for route: $routeName ($routePath)');
      debugPrint('  Current name: $currentRouteName, Current path: $location');
    }

    // Check if route names match
    if (currentRouteName == routeName) {
      return true;
    }

    // Check if location matches the path
    if (location == routePath) {
      return true;
    }

    // For nested routes that start with the path
    if (routePath != '/' && location.startsWith(routePath)) {
      return true;
    }

    return false;
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    required bool isActive,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // First trigger a rebuild to ensure UI updates
          setState(() {});
          // Navigate to the route using goNamed
          context.goNamed(route);
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color:
                isActive ? Colors.green.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: Colors.green.withOpacity(0.5))
                : null,
          ),
          child: _isRailExpanded
              // Expanded item with icon and text
              ? Row(
                  textDirection: TextDirection.rtl, // RTL for Arabic
                  children: [
                    Icon(
                      icon,
                      color: isActive ? Colors.green : Colors.grey.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.cairo(
                          color: isActive ? Colors.green : Colors.grey.shade800,
                          fontWeight: isActive ? FontWeight.bold : null,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              // Collapsed item with just icon and indicator
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isActive ? Colors.green : Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    // Selection indicator
                    if (isActive)
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRailHeader(bool isAdmin, AuthState authState) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
        // Logo
        SvgPicture.asset(
          'assets/images/logo.svg',
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 8),

        // App name when expanded
        if (_isRailExpanded)
          Text(
            'موثوق',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),

        // Admin badge if user is admin
        if (isAdmin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: _isRailExpanded
                ? Text(
                    'وضع المشرف',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(Icons.admin_panel_settings,
                    color: Colors.green, size: 18),
          ),

        // Email badge if expanded
        if (isAdmin && _isRailExpanded) ...[
          const SizedBox(height: 8),
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
                fontSize: 11,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],

        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildLogoutButton({required bool isAdmen}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          IconButton(
            icon: Icon(
                _isRailExpanded ? Icons.chevron_left : Icons.chevron_right),
            onPressed: () {
              setState(() {
                _isRailExpanded = !_isRailExpanded;
              });
            },
            tooltip: _isRailExpanded ? 'تصغير' : 'توسيع',
          ),
          if (isAdmen) ...[
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go(ScreensNames.homePath);
              },
            ),
            const SizedBox(height: 20),
            if (_isRailExpanded)
              Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontSize: 12,
                ),
              )
          ],
        ],
      ),
    );
  }
}
