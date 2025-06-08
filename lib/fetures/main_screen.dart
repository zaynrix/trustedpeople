import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/states/auth_state_admin.dart';
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

    // Watch auth state and handle errors gracefully
    final authState = ref.watch(authProvider);
    final isLoading = ref.watch(authLoadingProvider);

    // Get auth status safely
    final isAuthenticated =
        authState.isAuthenticated && authState.error == null;
    final isAdmin = isAuthenticated ? ref.watch(isAdminProvider) : false;
    final isTrustedUser =
        isAuthenticated ? ref.watch(isTrustedUserProvider) : false;
    final isApproved = isAuthenticated ? ref.watch(isApprovedProvider) : false;

    // Get current location for context
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final isOnSecureRoute =
        currentLocation.startsWith('/secure-trusted-895623/') ||
            currentLocation.startsWith('/secure-admin-784512/');

    if (kDebugMode) {
      print('🏗️ AppShell build:');
      print('  - Current location: $currentLocation');
      print('  - Is secure route: $isOnSecureRoute');
      print(
          '  - Auth state: isAuth=$isAuthenticated, isTrusted=$isTrustedUser, isAdmin=$isAdmin, isApproved=$isApproved');
      print('  - Loading: $isLoading, Error: ${authState.error}');
    }

    // Show loading indicator during auth state changes
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If on mobile, use standard scaffold with drawer
    if (isMobile) {
      if (kDebugMode) {
        print('🏗️ AppShell: Using mobile layout with drawer');
      }
      return Scaffold(
        drawer: const AppDrawer(),
        body: widget.child,
      );
    }

    // For desktop/tablet, use layout with custom navigation rail
    if (kDebugMode) {
      print('🏗️ AppShell: Using desktop layout with navigation rail');
    }
    return Scaffold(
      body: Row(
        textDirection: TextDirection.rtl,
        children: [
          // NavigationRail (custom implementation)
          _buildCustomNavigationRail(
              context, isAdmin, isTrustedUser, isApproved, authState),

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
    bool isTrustedUser,
    bool isApproved,
    AuthState authState,
  ) {
    // Get current route info for highlighting active item
    final location = GoRouterState.of(context).matchedLocation;
    final currentRouteName = GoRouterState.of(context).name;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isRailExpanded ? 280 : 80,
      color: Colors.grey.shade200,
      child: Column(
        children: [
          // Header with logo and user info
          _buildRailHeader(isAdmin, isTrustedUser, isApproved, authState),

          // Navigation items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Public navigation items (always shown)
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

                  // Admin navigation items (only for admins)
                  if (isAdmin && authState.error == null) ...[
                    const Divider(),
                    _buildNavItem(
                      context,
                      Icons.dashboard,
                      "لوحة الاحصائيات",
                      'adminDashboard',
                      isActive:
                          location.startsWith('/secure-admin-784512/dashboard'),
                    ),
                    _buildNavItem(
                      context,
                      Icons.people,
                      "إدارة طلبات المستخدمين",
                      ScreensNames.adminUserApplications,
                      isActive: location.startsWith(
                              '/secure-admin-784512/user-applications') ||
                          location.startsWith(
                              '/secure-trusted-895623/user-applications'),
                    ),
                    _buildNavItem(
                      context,
                      Icons.admin_panel_settings,
                      "إدارة الخدمات",
                      ScreensNames.adminServices,
                      isActive: location
                              .startsWith('/secure-admin-784512/services') ||
                          _isRouteActive(currentRouteName, location,
                              ScreensNames.adminServices, '/admin/services'),
                    ),
                    _buildNavItem(
                      context,
                      Icons.support_agent,
                      "طلبات الخدمات",
                      ScreensNames.adminServiceRequests,
                      isActive: location.startsWith(
                              '/secure-admin-784512/service-requests') ||
                          _isRouteActive(
                              currentRouteName,
                              location,
                              ScreensNames.adminServiceRequests,
                              '/admin/service-requests'),
                    ),
                  ],

                  // Trusted user navigation items (only for approved trusted users)
                  if (!isTrustedUser &&
                      !isApproved &&
                      !isAdmin &&
                      authState.isAuthenticated &&
                      authState.error == null) ...[
                    const Divider(),
                    _buildNavItem(
                      context,
                      Icons.dashboard,
                      "لوحة التحكم",
                      'trustedUserDashboard',
                      isActive: location.startsWith(
                          '/secure-trusted-895623/trusted-dashboard'),
                    ),
                    _buildNavItem(
                      context,
                      Icons.person,
                      "إدارة الملف الشخصي",
                      'trustedUserProfile',
                      isActive:
                          location.startsWith('/secure-trusted-895623/profile'),
                    ),
                  ],

                  // Pending user items (for users waiting approval)
                  if (isTrustedUser &&
                      !isApproved &&
                      !isAdmin &&
                      authState.error == null) ...[
                    const Divider(),
                    _buildNavItem(
                      context,
                      Icons.pending,
                      "حالة الطلب",
                      'pendingUserStatus',
                      isActive: location
                          .startsWith('/secure-trusted-895623/pending-status'),
                    ),
                  ],

                  // Contact us (always shown)
                  const Divider(),
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
          _buildFooter(authState),
        ],
      ),
    );
  }

  // Improved route checking logic
  bool _isRouteActive(String? currentRouteName, String location,
      String routeName, String routePath) {
    if (kDebugMode) {
      print('🔍 Route check: $routeName');
      print('  - Current name: $currentRouteName');
      print('  - Current location: $location');
      print('  - Target path: $routePath');
    }

    // Special case for home route
    if (routeName == ScreensNames.home) {
      bool isHomeActive = (currentRouteName == ScreensNames.home) ||
          (location == '/' &&
              (currentRouteName == null || currentRouteName == 'home'));
      if (kDebugMode && isHomeActive) {
        print('  ✅ Home route active');
      }
      return isHomeActive;
    }

    // Check if route names match exactly
    if (currentRouteName != null && currentRouteName == routeName) {
      if (kDebugMode) {
        print('  ✅ Route name match: $routeName');
      }
      return true;
    }

    // Check if location matches the path exactly
    if (location == routePath) {
      if (kDebugMode) {
        print('  ✅ Path exact match: $routePath');
      }
      return true;
    }

    // For nested routes, check if location starts with path
    if (routePath != '/' &&
        routePath.length > 1 &&
        location.startsWith(routePath)) {
      // Additional check: make sure it's a proper path segment match
      String remainder = location.substring(routePath.length);
      if (remainder.isEmpty || remainder.startsWith('/')) {
        if (kDebugMode) {
          print('  ✅ Nested route match: $routePath');
        }
        return true;
      }
    }

    return false;
  }

  // Improved navigation with better error handling
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
        onTap: () async {
          try {
            // Check auth state before allowing navigation
            final authState = ref.read(authProvider);
            final currentLocation = GoRouterState.of(context).matchedLocation;
            final currentRouteName = GoRouterState.of(context).name;

            if (kDebugMode) {
              print('🔄 Navigation attempt:');
              print('  - From: $currentLocation (name: $currentRouteName)');
              print('  - To: $route');
              print('  - Auth error: ${authState.error}');
            }

            // Skip navigation if already on target route
            bool alreadyOnRoute = false;

            if (currentRouteName == route) {
              alreadyOnRoute = true;
            } else if (route == ScreensNames.home && currentLocation == '/') {
              alreadyOnRoute = true;
            }

            if (alreadyOnRoute) {
              if (kDebugMode) {
                print('  ⏭️ Already on target route, skipping navigation');
              }
              return;
            }

            // Perform navigation
            if (mounted && context.mounted) {
              try {
                // Use goNamed for route names, go for direct paths
                if (route.startsWith('/')) {
                  context.go(route);
                } else {
                  context.goNamed(route);
                }

                if (kDebugMode) {
                  print('  ✅ Navigation completed successfully');
                }
              } catch (navigationError) {
                if (kDebugMode) {
                  print('  ❌ Navigation failed: $navigationError');
                }
                // Fallback to home if navigation fails
                context.go('/');
              }
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              print('❌ Navigation error: $e');
              print('Stack trace: $stackTrace');
            }
          }
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
              ? Row(
                  textDirection: TextDirection.rtl,
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isActive ? Colors.green : Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
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

  Widget _buildRailHeader(
      bool isAdmin, bool isTrustedUser, bool isApproved, AuthState authState) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

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

        // Admin badge
        if (isAdmin && authState.error == null)
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

        // Trusted user badge
        if (isTrustedUser &&
            !isAdmin &&
            authState.error == null &&
            _isRailExpanded) ...[
          const SizedBox(height: 8),
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
            child: Text(
              isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color:
                    isApproved ? Colors.blue.shade800 : Colors.orange.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // User name
          if (authState.userData?['fullName'] != null ||
              authState.userData?['profile']?['fullName'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                authState.userData?['fullName'] ??
                    authState.userData?['profile']?['fullName'] ??
                    'مستخدم',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
        ],

        // Show auth error if present
        if (authState.error != null && _isRailExpanded) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              'خطأ في المصادقة',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
        const Divider(),
      ],
    );
  }

  Widget _buildFooter(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),

          // Expand/collapse button
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

          // Logout button for authenticated users
          if (authState.isAuthenticated && authState.error == null) ...[
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                try {
                  await ref.read(authProvider.notifier).signOut();
                  if (mounted && context.mounted) {
                    context.go(ScreensNames.homePath);
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print('Logout error: $e');
                  }
                }
              },
            ),
            if (_isRailExpanded)
              Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
          ],

          // Login button for non-authenticated users
          if (!authState.isAuthenticated && authState.error == null) ...[
            IconButton(
              icon: const Icon(Icons.login, color: Colors.green),
              tooltip: 'تسجيل الدخول',
              onPressed: () {
                // Navigate to login page
                context.go('/login'); // Adjust path as needed
              },
            ),
            if (_isRailExpanded)
              Text(
                'تسجيل الدخول',
                style: GoogleFonts.cairo(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
