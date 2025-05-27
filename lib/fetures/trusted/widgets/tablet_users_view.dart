import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/filter_chips_row.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/pagination_controls_widget.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/sort_button.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/trusted_empty_state.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/user_card.dart';

class TabletUsersView extends ConsumerWidget {
  final List<UserModel> filteredUsers;
  final Color primaryColor;

  const TabletUsersView({
    super.key,
    required this.filteredUsers,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filterMode = ref.watch(filterModeProvider);
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final visiblePhoneNumberId = ref.watch(visiblePhoneNumberProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    // Apply pagination for tablet
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
            SortButton(primaryColor: primaryColor),
            if (isAdmin) ...[
              const SizedBox(width: 16),
              _buildPredefinedUsersButton(context, ref),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Filter chips
        FilterChipsRow(
          primaryColor: primaryColor,
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
              : GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: displayedUsers.length,
            itemBuilder: (context, index) {
              final user = displayedUsers[index];
              return UserCard(
                user: user,
                visiblePhoneNumberId: visiblePhoneNumberId,
                onTogglePhoneNumber: (userId) => _togglePhoneNumberVisibility(ref, userId),
                onTap: () => ref.read(homeProvider.notifier).visibleBar(selected: user),
              );
            },
          ),
        ),

        // Pagination
        if (filteredUsers.length > pageSize)
          PaginationControls(
            currentPage: currentPage,
            totalPages: totalPages,
            pageSize: pageSize,
            primaryColor: primaryColor,
            totalItems: filteredUsers.length,
          ),
      ],
    );
  }

  void _togglePhoneNumberVisibility(WidgetRef ref, String userId) {
    final currentVisibleId = ref.read(visiblePhoneNumberProvider);
    if (currentVisibleId == userId) {
      ref.read(visiblePhoneNumberProvider.notifier).state = null;
    } else {
      ref.read(visiblePhoneNumberProvider.notifier).state = userId;
    }
  }

  Widget _buildPredefinedUsersButton(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);

    return ElevatedButton.icon(
      onPressed: () async {
        final success = await homeNotifier.batchAddPredefinedUsers(ref: ref);
        if (success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إضافة جميع المستخدمين بنجاح!',
                    style: GoogleFonts.cairo()),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      },
      icon: const Icon(Icons.group_add),
      label: Text('إضافة المستخدمين الافتراضيين',
          style: GoogleFonts.cairo()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}