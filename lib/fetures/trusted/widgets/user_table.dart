import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/user_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/phone_number_section.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';

class UserTable extends ConsumerWidget {
  final List<UserModel> users;
  final Color primaryColor;

  const UserTable({
    Key? key,
    required this.users,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final visiblePhoneNumberId = ref.watch(visiblePhoneNumberProvider);
    final selectedUser = ref.watch(selectedUserProvider);

    return Column(
      children: [
        // Table header
        _buildTableHeader(isAdmin),

        // Table content
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 1,
                indent: 16,
                endIndent: 16),
            itemBuilder: (context, index) {
              final user = users[index];
              final isPhoneVisible = visiblePhoneNumberId == user.id;
              final isSelected = user.id == selectedUser?.id;

              return _buildTableRow(context, ref, user, isPhoneVisible,
                  isSelected, index, isAdmin);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Center(
                child: Text('الاسم والحالة',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              )),
          Expanded(
              flex: 2,
              child: Center(
                child: Text('رقم الجوال',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              )),
          Expanded(
              flex: 2,
              child: Center(
                child: Text('الموقع',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              )),
          Expanded(
              flex: 1,
              child: Center(
                child: Text('التقييمات',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              )),
          Expanded(
              flex: 1,
              child: Center(
                child: Text('تيليجرام',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              )),
          if (isAdmin) ...[
            Expanded(
                flex: 1,
                child: Center(
                  child: Text('تم بواسطة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                )),
            Expanded(
                flex: 1,
                child: Center(
                  child: Text('إجراءات',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                )),
          ] else
            Expanded(
                flex: 1,
                child: Center(
                  child: Text('تفاصيل',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                )),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    WidgetRef ref,
    UserModel user,
    bool isPhoneVisible,
    bool isSelected,
    int index,
    bool isAdmin,
  ) {
    final homeNotifier = ref.read(homeProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withOpacity(0.08)
            : user.role == 0
                ? Colors.purple.shade50
                : index % 2 == 0
                    ? Colors.white
                    : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: user.role == 0
            ? Border.all(color: Colors.purple.shade200, width: 1)
            : isSelected
                ? Border.all(color: primaryColor.withOpacity(0.3), width: 1)
                : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => homeNotifier.visibleBar(selected: user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Name and Status
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user.aliasName,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected
                            ? primaryColor
                            : user.role == 0
                                ? Colors.purple.shade700
                                : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    StatusChip(role: user.role, compact: true),
                  ],
                ),
              ),

              // Phone Number
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: PhoneNumberSection(
                    user: user,
                    isPhoneVisible: isPhoneVisible,
                  ),
                ),
              ),

              // Location
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    user.location.isEmpty ? 'غير محدد' : "🌍${user.location}",
                    style: GoogleFonts.cairo(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              // Reviews
              Expanded(
                flex: 1,
                child: Center(
                  child: user.reviews.isNotEmpty
                      ? Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(user.reviews,
                                  style: GoogleFonts.cairo(),
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                      )
                      : Text('لا يوجد',
                          style: GoogleFonts.cairo(
                              color: Colors.grey.shade500, fontSize: 12)),
                ),
              ),

              // Telegram
              Expanded(
                flex: 1,
                child: Center(child:  user.telegramAccount.isNotEmpty
                    ? Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.telegram,
                                size: 16, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text('متوفر',
                                style: GoogleFonts.cairo(
                                    color: Colors.blue.shade600, fontSize: 12)),
                          ],
                        ),
                    )
                    : Text('غير متوفر',
                        style: GoogleFonts.cairo(
                            color: Colors.grey.shade500, fontSize: 12)),
              ),),

              // Admin columns or actions
              if (isAdmin) ...[
                // Added by
                Expanded(
                  flex: 1,
                  child: Text(
                    user.addedBy.isEmpty ? 'غير معروف' : user.addedBy,
                    style: GoogleFonts.cairo(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Actions
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () =>
                            homeNotifier.visibleBar(selected: user),
                        icon: const Icon(Icons.visibility, size: 16),
                        tooltip: 'عرض التفاصيل',
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          foregroundColor: primaryColor,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () =>
                            EditUserDialog.show(context, ref, user),
                        icon: const Icon(Icons.edit, size: 16),
                        tooltip: 'تعديل',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          foregroundColor: Colors.blue.shade600,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () =>
                            DeleteUserDialog.show(context, ref, user),
                        icon: const Icon(Icons.delete, size: 16),
                        tooltip: 'حذف',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          foregroundColor: Colors.red.shade600,
                          minimumSize: const Size(32, 32),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () =>
                            homeNotifier.visibleBar(selected: user),
                        icon: const Icon(Icons.visibility, size: 18),
                        tooltip: 'عرض التفاصيل',
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          foregroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
