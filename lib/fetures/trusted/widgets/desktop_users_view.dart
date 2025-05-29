import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/theme/app_colors.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/filter_chips_row.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/pagination_controls_widget.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/sort_button.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/trusted_empty_state.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/user_table.dart';

class DesktopUsersView extends ConsumerWidget {
  final List<UserModel> filteredUsers;
  final bool isTrusted;

  const DesktopUsersView({
    super.key,
    required this.filteredUsers,
    required this.isTrusted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filterMode = ref.watch(filterModeProvider);
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    // Apply pagination for desktop
    List<UserModel> displayedUsers = filteredUsers;
    int totalPages = 1;

    if (filteredUsers.length > pageSize) {
      totalPages = (filteredUsers.length / pageSize).ceil();
      final startIndex = (currentPage - 1) * pageSize;
      final endIndex = (startIndex + pageSize < filteredUsers.length)
          ? startIndex + pageSize
          : filteredUsers.length;

      if (startIndex < filteredUsers.length) {
        displayedUsers = filteredUsers.sublist(startIndex, endIndex);
      } else {
        displayedUsers = [];
        // Reset to first page if current page is out of range
        WidgetsBinding.instance.addPostFrameCallback((_) {
          homeNotifier.setCurrentPage(1);
        });
      }
    }

    return Column(
      children: [
        // Controls row
        Row(
          children: [
            Expanded(
              child: SearchField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                  homeNotifier.setSearchQuery(value);
                },
                hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
              ),
            ),
            const SizedBox(width: 16),
            SortButton(
                primaryColor: isTrusted
                    ? AppColors.trustedColor
                    : AppColors.unTrustedColor),
            if (isAdmin) ...[
              const SizedBox(width: 16),
              _buildPredefinedUsersButton(context, ref),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Filter chips
        FilterChipsRow(
          primaryColor:
              isTrusted ? AppColors.trustedColor : AppColors.unTrustedColor,
          onLocationFilter: () {},
        ),

        const SizedBox(height: 24),

        // Main content
        Expanded(
          child: displayedUsers.isEmpty
              ? TrustedEmptyStateWidget(
                  isFiltered: filteredUsers.isEmpty,
                  searchQuery: searchQuery,
                  filterMode: filterMode,
                )
              : Container(
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
                  child: UserTable(
                    users: displayedUsers,
                    primaryColor: isTrusted
                        ? AppColors.trustedColor
                        : AppColors.unTrustedColor,
                  ),
                ),
        ),

        // Pagination
        if (filteredUsers.length > pageSize)
          PaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            pageSize: pageSize,
            primaryColor:
                isTrusted ? AppColors.trustedColor : AppColors.unTrustedColor,
            totalItems: filteredUsers.length,
          ),
      ],
    );
  }

  Widget _buildPredefinedUsersButton(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);

    return ElevatedButton.icon(
      onPressed: () async {
        // final success = await homeNotifier.batchAddPredefinedUsers(ref: ref);
        // if (success) {
        //   if (context.mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('تم إضافة جميع المستخدمين بنجاح!',
        //             style: GoogleFonts.cairo()),
        //         backgroundColor: Colors.green,
        //       ),
        //     );
        //   }
        // }
      },
      icon: const Icon(Icons.group_add),
      label: Text('إضافة المستخدمين الافتراضيين', style: GoogleFonts.cairo()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
