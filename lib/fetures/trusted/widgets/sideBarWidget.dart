import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';

class UserDetailSidebar extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserDetailSidebar({
    super.key,
    required this.user,
    required this.onClose,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserInfoCard(
                      icon: Icons.person_rounded,
                      title: "الاسم",
                      value: user.aliasName),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.phone_rounded,
                      title: "رقم الجوال",
                      value: user.mobileNumber),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.location_on_rounded,
                      title: "الموقع",
                      value: user.location),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.settings_rounded,
                      title: "الخدمات المقدمة",
                      value: user.servicesProvided),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.telegram,
                      title: "حساب تيليجرام",
                      value: user.telegramAccount),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.link_rounded,
                      title: "حسابات أخرى",
                      value: user.otherAccounts),
                  const SizedBox(height: 12),
                  UserInfoCard(
                      icon: Icons.star_rounded,
                      title: "التقييمات",
                      value: user.reviews),
                  const SizedBox(height: 24),
                  if (ref.watch(isAdminProvider))
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onEdit != null)
                          ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            label: Text('تعديل', style: GoogleFonts.cairo()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (onDelete != null)
                          ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: Text('حذف', style: GoogleFonts.cairo()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    Color backgroundColor, borderColor;

    switch (user.role) {
      case 0: // Admin
        backgroundColor = Colors.purple.shade50;
        borderColor = Colors.purple.shade200;
        break;
      case 1: // Trusted
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        break;
      case 2: // Known
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade200;
        break;
      case 3: // Fraud
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات التواصل',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                StatusChip(role: user.role, compact: true),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close_rounded, size: 24, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
