import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class AppDrawer extends ConsumerWidget {
  final bool isPermanent;

  const AppDrawer({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return isPermanent
        ? _buildPermanentDrawer(context, ref)
        : Drawer(child: _buildDrawerContent(context, ref));
  }

  Widget _buildDrawerContent(BuildContext context, WidgetRef ref) {
    // Get admin status
    final isAdmin = ref.watch(isAdminProvider);

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        if (!isPermanent)
          DrawerHeader(
            decoration: BoxDecoration(
              color: isAdmin
                  ? Colors.green
                  .withOpacity(0.15) // Subtle green tint for admins
                  : Colors.black12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main title
                Text(
                  'ترست فالي',
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Add spacing between elements
                const SizedBox(height: 8),

                // Admin indicator - only visible to admins
                if (isAdmin)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'وضع المشرف',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (isPermanent)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.green.withOpacity(0.15) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main title
                Text(
                  'ترست فالي',
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Add spacing between elements
                const SizedBox(height: 8),

                // Admin indicator - only visible to admins
                if (isAdmin)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'وضع المشرف',
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Regular navigation items - shown to everyone
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
          icon: Icons.contact_mail,
          label: 'تواصل للاستفسارات',
          route: ScreensNames.contactUs,
          isPermanent: isPermanent,
        ),
        // Only add a divider and admin options for admins
        if (isAdmin) ...[
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                color: Colors.red.shade400,
              ),
            ),
            onTap: () {
              if (!isPermanent) Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
              context.go(ScreensNames.homePath);
            },
          ),
        ],
      ],
    );
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
    final location = GoRouterState.of(context).matchedLocation;
    final bool isActive = location == route || location.startsWith(route);

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.green : null),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          textStyle: TextStyle(
            color: isActive ? Colors.green : null,
            fontWeight: isActive ? FontWeight.bold : null,
          ),
        ),
      ),
      tileColor: isActive ? Colors.grey.shade300 : null,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        // Use GoRouter for navigation
        context.goNamed(route);
      },
    );
  }
}