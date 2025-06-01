import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/theme/app_colors.dart';
import 'package:trustedtallentsvalley/core/widgets/footer_state_widget.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/user_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/desktop_users_view.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/mobile_users_view.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/sideBarWidget.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/tablet_users_view.dart';

class UsersListScreen extends ConsumerWidget {
  final String title;
  final AsyncValue<QuerySnapshot> usersStream;
  final bool isTrusted;
  final Color backgroundColor;

  const UsersListScreen({
    super.key,
    required this.title,
    required this.usersStream,
    required this.isTrusted,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1200;
    final isLoading = ref.watch(isLoadingProvider);
    final isAdmin = ref.watch(isAdminProvider);

    debugPrint("this truested ${trustedUsersStreamProvider.name}");

    return Scaffold(
      backgroundColor: backgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(context, ref, isMobile, isTablet),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor:
                  isTrusted ? AppColors.trustedColor : AppColors.unTrustedColor,
              onPressed: () => AddUserDialog.show(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    bool isMobile,
    bool isTablet,
  ) {
    // Handle error messages
    final errorMessage = ref.watch(errorMessageProvider);
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      });
    }

    return usersStream.when(
      data: (snapshot) {
        debugPrint(
            'UsersListScreen: Received ${snapshot.docs.length} documents');

        // Convert documents to UserModel list
        List<UserModel> allUsers = [];
        for (var doc in snapshot.docs) {
          try {
            final user = UserModel.fromFirestore(doc);
            allUsers.add(user);
          } catch (e) {
            debugPrint('Error converting document ${doc.id}: $e');
          }
        }

        debugPrint(
            'UsersListScreen: Successfully converted ${allUsers.length} users');

        // Apply filters and sorting
        final filteredUsers = _getFilteredUsers(ref, allUsers);

        // Create responsive layout
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Debug info (remove in production)
              if (ref.watch(isAdminProvider))
                _buildDebugInfo(
                    ref, snapshot.docs.length, filteredUsers.length),

              // Content based on screen size
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main content
                    Expanded(
                      child: Column(
                        children: [
                          // View based on screen size
                          Expanded(
                            child: isMobile
                                ? MobileUsersView(
                                    filteredUsers: filteredUsers,
                                    primaryColor: isTrusted
                                        ? AppColors.trustedColor
                                        : AppColors.unTrustedColor,
                                  )
                                : isTablet
                                    ? TabletUsersView(
                                        filteredUsers: filteredUsers,
                                        primaryColor: isTrusted
                                            ? AppColors.trustedColor
                                            : AppColors.unTrustedColor,
                                      )
                                    : DesktopUsersView(
                                        filteredUsers: filteredUsers,
                                        isTrusted: isTrusted,
                                      ),
                          ),

                          // Footer stats
                          if (!isMobile)
                            FooterStateWidget(
                              filteredCount: filteredUsers.length,
                              totalCount: snapshot.docs.length,
                            ),
                        ],
                      ),
                    ),

                    // Sidebar
                    if (ref.watch(showSideBarProvider) &&
                        ref.watch(selectedUserProvider) != null) ...[
                      const SizedBox(width: 24),
                      UserDetailSidebar(
                        user: ref.watch(selectedUserProvider)!,
                        onClose: () =>
                            ref.read(homeProvider.notifier).closeBar(),
                        onEdit: () => EditUserDialog.show(
                            context, ref, ref.watch(selectedUserProvider)!),
                        onDelete: () => DeleteUserDialog.show(
                            context, ref, ref.watch(selectedUserProvider)!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorWidget(context, ref, error),
    );
  }

  Widget _buildDebugInfo(WidgetRef ref, int totalCount, int filteredCount) {
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final totalPages = (filteredCount / pageSize).ceil();
    final displayedCount = pageSize < filteredCount
        ? (currentPage * pageSize < filteredCount
            ? pageSize
            : filteredCount % pageSize)
        : filteredCount;

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        'Debug: Total: $totalCount, Filtered: $filteredCount, Displayed: $displayedCount, Page: $currentPage/$totalPages',
        style: GoogleFonts.cairo(fontSize: 12, color: Colors.blue.shade700),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ أثناء تحميل البيانات',
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: GoogleFonts.cairo(color: Colors.grey.shade700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(allUsersStreamProvider),
            icon: const Icon(Icons.refresh),
            label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  List<UserModel> _getFilteredUsers(WidgetRef ref, List<UserModel> allUsers) {
    final searchQuery = ref.watch(searchQueryProvider);
    final filterMode = ref.watch(filterModeProvider);
    final locationFilter = ref.watch(locationFilterProvider);
    final sortField = ref.watch(sortFieldProvider);
    final sortAscending = ref.watch(sortDirectionProvider);

    // Apply search filter
    List<UserModel> filteredUsers = allUsers.where((user) {
      if (searchQuery.isEmpty) return true;

      final query = searchQuery.toLowerCase().trim();
      return user.aliasName.toLowerCase().contains(query) ||
          user.mobileNumber.toLowerCase().contains(query) ||
          user.location.toLowerCase().contains(query) ||
          user.servicesProvided.toLowerCase().contains(query) ||
          user.statusText.toLowerCase().contains(query);
    }).toList();

    // Apply additional filters
    filteredUsers = filteredUsers.where((user) {
      switch (filterMode) {
        case FilterMode.all:
          return true;
        case FilterMode.withReviews:
          return user.reviews.isNotEmpty;
        case FilterMode.withoutTelegram:
          return user.telegramAccount.isEmpty;
        case FilterMode.byLocation:
          if (locationFilter == null || locationFilter.isEmpty) return true;
          return user.location
              .toLowerCase()
              .contains(locationFilter.toLowerCase());
      }
    }).toList();

    // Apply sorting
    filteredUsers.sort((a, b) {
      dynamic aValue, bValue;

      switch (sortField) {
        case 'aliasName':
          aValue = a.aliasName;
          bValue = b.aliasName;
          break;
        case 'mobileNumber':
          aValue = a.mobileNumber;
          bValue = b.mobileNumber;
          break;
        case 'location':
          aValue = a.location;
          bValue = b.location;
          break;
        case 'reviews':
          aValue = a.reviews;
          bValue = b.reviews;
          break;
        case 'role':
          aValue = a.role;
          bValue = b.role;
          break;
        default:
          aValue = a.aliasName;
          bValue = b.aliasName;
      }

      final comparison = aValue.toString().compareTo(bValue.toString());
      return sortAscending ? comparison : -comparison;
    });

    return filteredUsers;
  }
}
