import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_info_card.dart';
class UserDetailSidebar extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onClose;

  const UserDetailSidebar({
    Key? key,
    required this.user,
    required this.onClose,
  }) : super(key: key);

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
                    value: user.aliasName,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.phone_rounded,
                    title: "رقم الجوال",
                    value: user.mobileNumber,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.location_on_rounded,
                    title: "الموقع",
                    value: user.location,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.settings_rounded,
                    title: "الخدمات المقدمة",
                    value: user.servicesProvided,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.telegram,
                    title: "حساب تيليجرام",
                    value: user.telegramAccount,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.link_rounded,
                    title: "حسابات أخرى",
                    value: user.otherAccounts,
                  ),
                  const SizedBox(height: 12),
                  UserInfoCard(
                    icon: Icons.star_rounded,
                    title: "التقييمات",
                    value: user.reviews,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: user.isTrusted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: user.isTrusted ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
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
                StatusChip(isTrusted: user.isTrusted),
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
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
