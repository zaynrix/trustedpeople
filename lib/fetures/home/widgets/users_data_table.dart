import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class UsersDataTable extends ConsumerWidget {
  final List<DocumentSnapshot> users;
  final String? visiblePhoneNumberId;
  final Function(String) onTogglePhoneNumber;
  final Function(UserModel)? onEditUser;
  final Function(UserModel)? onDeleteUser;

  const UsersDataTable({
    super.key,
    required this.users,
    this.visiblePhoneNumberId,
    required this.onTogglePhoneNumber,
    this.onEditUser,
    this.onDeleteUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isAdmin = ref.watch(isAdminProvider);

    // Empty state
    if (users.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildTableHeader(isMobile, isAdmin),
          // Content
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade200,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return _buildUserRow(
                  context,
                  ref,
                  users[index],
                  index,
                  isMobile,
                  isAdmin,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مستخدمين للعرض',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من أن قاعدة البيانات تحتوي على مستخدمين أو جرب تغيير معايير البحث',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(bool isMobile, bool isAdmin) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.people, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              'قائمة المستخدمين',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Text(
              '${users.length} مستخدم',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'الاسم والحالة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'رقم الجوال',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الموقع',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     'الخدمات',
          //     style: GoogleFonts.cairo(
          //       fontWeight: FontWeight.bold,
          //       color: Colors.grey.shade800,
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Text(
              'التقييمات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'تيليجرام',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          if (isAdmin) ...[
            Expanded(
              flex: 1,
              child: Text(
                'تم بواسطة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'إجراءات',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            Expanded(
              flex: 1,
              child: Text(
                'تفاصيل',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserRow(
    BuildContext context,
    WidgetRef ref,
    DocumentSnapshot userDoc,
    int index,
    bool isMobile,
    bool isAdmin,
  ) {
    final userData = UserModel.fromFirestore(userDoc);
    final isPhoneVisible = visiblePhoneNumberId == userData.id;
    final selectedUser = ref.watch(selectedUserProvider);
    final isSelected = userDoc.id == selectedUser?.id;
    final isUserAdmin = userData.role == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.08)
            : isUserAdmin
                ? Colors.purple.shade50
                : index % 2 == 0
                    ? Colors.white
                    : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: isUserAdmin
            ? Border.all(color: Colors.purple.shade200, width: 1)
            : isSelected
                ? Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1)
                : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          ref.read(homeProvider.notifier).visibleBar(selected: userData);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? _buildMobileLayout(context, ref, userData, isPhoneVisible,
                  isSelected, isUserAdmin, isAdmin)
              : _buildDesktopLayout(context, ref, userData, isPhoneVisible,
                  isSelected, isUserAdmin, isAdmin),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    UserModel userData,
    bool isPhoneVisible,
    bool isSelected,
    bool isUserAdmin,
    bool isCurrentUserAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Status Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.aliasName ?? '',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : isUserAdmin
                              ? Colors.purple.shade700
                              : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusChip(
                    isTrusted: userData.isTrusted,
                    role: userData.role,
                    compact: true,
                  ),
                ],
              ),
            ),
            if (isCurrentUserAdmin) ...[
              IconButton(
                onPressed: () => onEditUser?.call(userData),
                icon: const Icon(Icons.edit, size: 16),
                tooltip: 'تعديل',
                color: Colors.blue.shade600,
              ),
              IconButton(
                onPressed: () => onDeleteUser?.call(userData),
                icon: const Icon(Icons.delete, size: 16),
                tooltip: 'حذف',
                color: Colors.red.shade600,
              ),
            ],
            IconButton(
              onPressed: () {
                ref.read(homeProvider.notifier).visibleBar(selected: userData);
              },
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              tooltip: 'عرض التفاصيل',
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Phone Number
        _buildPhoneNumberSection(context, userData, isPhoneVisible),
        const SizedBox(height: 8),
        // Location and Services
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      userData.location ?? 'غير محدد',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (userData.reviews.isNotEmpty == true) ...[
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                userData.reviews,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (userData.telegramAccount.isNotEmpty == true) ...[
              Icon(Icons.telegram, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                'متوفر',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WidgetRef ref,
    UserModel userData,
    bool isPhoneVisible,
    bool isSelected,
    bool isUserAdmin,
    bool isCurrentUserAdmin,
  ) {
    return Row(
      children: [
        // Name and Status
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData.aliasName ?? '',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : isUserAdmin
                          ? Colors.purple.shade700
                          : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              StatusChip(
                isTrusted: userData.isTrusted,
                role: userData.role,
                compact: true,
              ),
            ],
          ),
        ),
        // Phone Number
        Expanded(
          flex: 2,
          child: _buildPhoneNumberSection(context, userData, isPhoneVisible),
        ),
        // Location
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  userData.location ?? 'غير محدد',
                  style: GoogleFonts.cairo(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Services
        // Expanded(
        //   flex: 2,
        //   child: userData.servicesProvided.isNotEmpty == true
        //       ? Row(
        //           children: [
        //             Icon(Icons.work, size: 16, color: Colors.grey.shade600),
        //             const SizedBox(width: 4),
        //             Expanded(
        //               child: Text(
        //                 userData.servicesProvided,
        //                 style: GoogleFonts.cairo(),
        //                 overflow: TextOverflow.ellipsis,
        //                 maxLines: 2,
        //               ),
        //             ),
        //           ],
        //         )
        //       : Text(
        //           'غير محدد',
        //           style: GoogleFonts.cairo(
        //             color: Colors.grey.shade500,
        //             fontSize: 12,
        //           ),
        //         ),
        // ),
        // Reviews
        Expanded(
          flex: 1,
          child: userData.reviews.isNotEmpty == true
              ? Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        userData.reviews,
                        style: GoogleFonts.cairo(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : Text(
                  'لا يوجد',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
        ),
        // Telegram
        Expanded(
          flex: 1,
          child: userData.telegramAccount.isNotEmpty == true
              ? Row(
                  children: [
                    Icon(Icons.telegram, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      'متوفر',
                      style: GoogleFonts.cairo(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : Text(
                  'غير متوفر',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
        ),
        // Admin columns
        if (isCurrentUserAdmin) ...[
          // Added by
          Expanded(
            flex: 1,
            child: Builder(
              builder: (context) {
                String addedByValue = 'غير معروف';
                try {
                  final data =
                      users.firstWhere((doc) => doc.id == userData.id).data();
                  if (data != null && data is Map<String, dynamic>) {
                    if (data.containsKey('addedBy')) {
                      addedByValue = data['addedBy'] ?? 'غير معروف';
                    }
                  }
                } catch (e) {
                  // Silently handle any errors
                }
                return Text(
                  addedByValue,
                  style: GoogleFonts.cairo(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    ref
                        .read(homeProvider.notifier)
                        .visibleBar(selected: userData);
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  tooltip: 'عرض التفاصيل',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(32, 32),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onEditUser?.call(userData),
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
                  onPressed: () => onDeleteUser?.call(userData),
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
        ] else ...[
          // View details only for non-admins
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    ref
                        .read(homeProvider.notifier)
                        .visibleBar(selected: userData);
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  tooltip: 'عرض التفاصيل',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    foregroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneNumberSection(
    BuildContext context,
    UserModel userData,
    bool isPhoneVisible,
  ) {
    if (isPhoneVisible) {
      return Row(
        children: [
          GestureDetector(
            onTap: () => _copyToClipboard(context, userData.mobileNumber ?? ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData.mobileNumber ?? '',
                    style: GoogleFonts.cairo(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.content_copy,
                    size: 14,
                    color: Colors.green.shade600,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.visibility_off,
              size: 18,
              color: Colors.grey.shade600,
            ),
            onPressed: () => onTogglePhoneNumber(userData.id),
            tooltip: 'إخفاء رقم الجوال',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () => onTogglePhoneNumber(userData.id),
      icon: const Icon(Icons.visibility, size: 16),
      label: Text(
        'اظهر رقم الجوال',
        style: GoogleFonts.cairo(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'تم نسخ رقم الجوال بنجاح',
              style: GoogleFonts.cairo(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
