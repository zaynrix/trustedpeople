import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/clipboard_utils.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';

import '../../../core/utils/url_launcher_utils.dart';

class UserDetailBottomSheet {
  /// Shows the user details in a modal bottom sheet, optimized for mobile view
  static void show(
      BuildContext context,
      UserModel user, {
        VoidCallback? onEdit,
        VoidCallback? onDelete,
      }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet expandable
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailBottomSheetContent(
        user: user,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _UserDetailBottomSheetContent extends ConsumerWidget {
  final UserModel user;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _UserDetailBottomSheetContent({
    super.key,
    required this.user,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get colors based on user role
    final (backgroundColor, borderColor) = _getRoleColors();
    final isAdmin = ref.watch(isAdminProvider);

    // Calculate the bottom sheet height (70% of screen height)
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = screenHeight * 0.7;

    return Container(
      height: bottomSheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context, backgroundColor, borderColor),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main contact information section
                  _buildContactInfoSection(context),

                  const SizedBox(height: 24),

                  // Additional information section
                  _buildAdditionalInfoSection(),

                  const SizedBox(height: 24),

                  // Admin actions
                  if (isAdmin) _buildAdminActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color backgroundColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: borderColor)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.aliasName,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                StatusChip(role: user.role, compact: false),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: Colors.grey.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'معلومات التواصل',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Phone with call button
        _buildPhoneNumberCard(context: context),

        const SizedBox(height: 12),

        // Location
        UserInfoCard(
          icon: Icons.location_on_rounded,
          title: "الموقع",
          value: user.location,
        ),

        // Telegram (if available)
        if (user.telegramAccount.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildTelegramCard(context),
        ],

        // Other accounts (if available)
        if (user.otherAccounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          UserInfoCard(
            icon: Icons.link_rounded,
            title: "حسابات أخرى",
            value: user.otherAccounts,
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'معلومات إضافية',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        // Services provided
        UserInfoCard(
          icon: Icons.settings_rounded,
          title: "الخدمات المقدمة",
          value: user.servicesProvided,
        ),

        // Reviews (if available)
        if (user.reviews.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildReviewsCard(),
        ],
      ],
    );
  }

  Widget _buildPhoneNumberCard({required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "رقم الجوال",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  user.mobileNumber,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.content_copy,
                color: Colors.blue.shade700,
                onTap: () => ClipboardUtils.copyToClipboard(
                  context,
                  user.mobileNumber,
                ),
                tooltip: 'نسخ الرقم',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.call,
                color: Colors.green.shade700,
                onTap: () => _launchCall(user.mobileNumber, context),
                tooltip: 'اتصال',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelegramCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.telegram, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "حساب تيليجرام",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  user.telegramAccount,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          _buildActionButton(
            icon: Icons.open_in_new,
            color: Colors.blue.shade700,
            onTap: () => _openTelegram(user.telegramAccount, context),
            tooltip: 'فتح تيليجرام',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsCard() {
    // Parse the review value to determine rating level
    bool isHighlyRated = false;
    double? rating;

    // Try to extract numerical rating
    if (user.reviews.contains('/')) {
      try {
        final parts = user.reviews.split('/');
        if (parts.length >= 2) {
          final ratingStr = parts[0].trim();
          final totalStr = parts[1].trim();
          final ratingVal = double.tryParse(ratingStr);
          final totalVal = double.tryParse(totalStr);

          if (ratingVal != null && totalVal != null) {
            rating = ratingVal;
            isHighlyRated = (ratingVal / totalVal) >= 0.8; // 80% or higher
          }
        }
      } catch (e) {
        // If parsing fails, continue with default handling
      }
    } else if (user.reviews.contains('5') || user.reviews.contains('4')) {
      isHighlyRated = true;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "التقييمات",
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.reviews,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (isHighlyRated) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade300, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 12, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'موصى به',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

  Widget _buildAdminActions(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خيارات المشرف',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onEdit != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onEdit!();
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text('تعديل', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 12),
                if (onDelete != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete!();
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: Text('حذف', style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  void _launchCall(String phoneNumber, BuildContext context) async {
    final success = await UrlLauncherUtils.launchPhoneCall(phoneNumber);
    if (!success && context.mounted) {
      UrlLauncherUtils.handleLaunchError(context, 'تطبيق الاتصال');
    }
  }

  void _openTelegram(String username, BuildContext context) async {
    final success = await UrlLauncherUtils.launchTelegram(username);
    if (!success && context.mounted) {
      UrlLauncherUtils.handleLaunchError(context, 'تيليجرام');
    }
  }

  (Color, Color) _getRoleColors() {
    switch (user.role) {
      case 0: // Admin
        return (Colors.purple.shade50, Colors.purple.shade200);
      case 1: // Trusted
        return (Colors.green.shade50, Colors.green.shade200);
      case 2: // Known
        return (Colors.blue.shade50, Colors.blue.shade200);
      case 3: // Fraud
        return (Colors.red.shade50, Colors.red.shade200);
      default:
        return (Colors.grey.shade50, Colors.grey.shade200);
    }
  }
}