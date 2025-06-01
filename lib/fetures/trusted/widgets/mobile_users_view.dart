import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart'
    as hn;
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/user_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/trusted_empty_state.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/trusted_user_tile.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/user_detail_bottom_sheet.dart';

import '../../home/providers/home_notifier.dart';

class MobileUsersView extends ConsumerWidget {
  final List<UserModel> filteredUsers;
  final Color primaryColor;
  final blacklistSearchQueryProvider;

  const MobileUsersView({
    super.key,
    required this.filteredUsers,
    this.blacklistSearchQueryProvider,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(blacklistSearchQueryProvider);
    final filterMode = ref.watch(hn.filterModeProvider);
    final visiblePhoneNumberId = ref.watch(hn.visiblePhoneNumberProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    // Apply pagination for mobile (show all)
    final List<UserModel> displayedUsers = filteredUsers;

    return Column(
      children: [
        // Search field
        SearchField(
          onChanged: (value) {
            ref.read(blacklistSearchQueryProvider.notifier).state = value;
            homeNotifier.setSearchQuery(value);
          },
          hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
        ),

        const SizedBox(height: 16),

        // Filter chips
        // FilterChipsRow(
        //   primaryColor: primaryColor,
        //   onLocationFilter: () {},
        // ),

        const SizedBox(height: 24),

        // Main content
        Expanded(
          child: displayedUsers.isEmpty
              ? TrustedEmptyStateWidget(
                  isFiltered: filteredUsers.isEmpty,
                  searchQuery: searchQuery,
                  filterMode: filterMode,
                )
              : ListView.separated(
                  itemCount: displayedUsers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = displayedUsers[index];
                    return TrustedUserTile(
                      user: user,
                      visiblePhoneNumberId: visiblePhoneNumberId,
                      onTogglePhoneNumber: (userId) =>
                          _togglePhoneNumberVisibility(ref, userId),
                      onTap: () => _showUserDetails(context, ref, user),
                    );
                  },
                ),
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

  void _showUserDetails(BuildContext context, WidgetRef ref, UserModel user) {
    final isAdmin = ref.read(isAdminProvider);

    UserDetailBottomSheet.show(
      context,
      user,
      onEdit: isAdmin ? () => EditUserDialog.show(context, ref, user) : null,
      onDelete:
          isAdmin ? () => DeleteUserDialog.show(context, ref, user) : null,
    );
  }
}
