import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/header_user_details_slidebar.dart';

import '../../../../services/auth_service.dart';

class UserDetailSidebar extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserDetailSidebar({
    Key? key,
    required this.user,
    required this.onClose,
    this.onEdit,
    this.onDelete,
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
          HeaderUserDetailSlidebar(user: user, onClose: onClose,),
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (onEdit != null && ref.watch(isAdminProvider))
                        ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 18),
                          label: Text(
                            'تعديل',
                            style: GoogleFonts.cairo(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      const SizedBox(width: 16),
                      if (onDelete != null && ref.watch(isAdminProvider))
                        ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 18),
                          label: Text(
                            'حذف',
                            style: GoogleFonts.cairo(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
}

