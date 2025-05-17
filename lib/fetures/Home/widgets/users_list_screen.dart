import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/app/core/widgets/empty_state_widget.dart';
import 'package:trustedtallentsvalley/app/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/app/core/widgets/footer_state_widget.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/users_data_table.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/add_user_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/edit_user_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/export_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/help_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/show_delete_confirmation.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/filter_chips_row.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/sort_dropdown.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/user_detail_slidebar.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/user_details_bottom_sheet.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class UsersListScreen extends ConsumerWidget {
  final String title;
  final AsyncValue<QuerySnapshot> usersStream;
  final Color primaryColor;
  final Color backgroundColor;

  const UsersListScreen({
    super.key,
    required this.title,
    required this.usersStream,
    this.primaryColor = Colors.green,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1200;

    // Watch for loading state
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          // Export button - only visible to admins
          if (!isMobile && ref.watch(isAdminProvider))
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () {
                showExportDialog(context, ref);
              },
              tooltip: 'تصدير البيانات',
            ),
          // Help button - visible to everyone
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              showHelpDialog(context);
            },
            tooltip: 'المساعدة',
          ),
          const SizedBox(width: 8),
        ],
        shape: isMobile
            ? null
            : const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      // Show loading indicator when loading
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) const AppDrawer(isPermanent: true),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMainContent(
                    context,
                    ref,
                    constraints,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // FAB for adding new users (if admin)
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          showAddUserDialog(context, ref);
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildMainContent(BuildContext context,
      WidgetRef ref,
      BoxConstraints constraints, {
        bool isMobile = false,
        bool isTablet = false,
      }) {
    // Watch for all required state
    final searchQuery = ref.watch(searchQueryProvider);
    final showSideBar = ref.watch(showSideBarProvider);
    final selectedUser = ref.watch(selectedUserProvider);
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final sortField = ref.watch(sortFieldProvider);
    final sortAscending = ref.watch(sortDirectionProvider);
    final filterMode = ref.watch(filterModeProvider);
    final locationFilter = ref.watch(locationFilterProvider);

    // Get the providers
    final homeNotifier = ref.read(homeProvider.notifier);

    // Watch for error messages
    final errorMessage = ref.watch(errorMessageProvider);
    if (errorMessage != null) {
      // Show error snackbar once
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
        // Apply filtering
        var filteredUsers = snapshot.docs.where((user) {
          // Apply search filter
          final aliasName = (user['aliasName'] ?? '').toString().toLowerCase();
          final mobileNumber = (user['mobileNumber'] ?? '').toString();
          final location = (user['location'] ?? '').toString().toLowerCase();
          final services =
          (user['servicesProvided'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();

          bool matchesSearch = query.isEmpty ||
              aliasName.contains(query) ||
              mobileNumber.contains(query) ||
              location.contains(query) ||
              services.contains(query);

          // Apply additional filters based on filter mode
          switch (filterMode) {
            case FilterMode.all:
              return matchesSearch;
            case FilterMode.withReviews:
              final hasReviews = (user['reviews'] ?? '')
                  .toString()
                  .isNotEmpty;
              return matchesSearch && hasReviews;
            case FilterMode.withoutTelegram:
              final noTelegram =
                  (user['telegramAccount'] ?? '')
                      .toString()
                      .isEmpty;
              return matchesSearch && noTelegram;
            case FilterMode.byLocation:
            // Location-specific filtering
              if (locationFilter == null || locationFilter.isEmpty) {
                return matchesSearch;
              }
              return matchesSearch &&
                  location.contains(locationFilter.toLowerCase());
          }
        }).toList();

        // Apply sorting
        filteredUsers.sort((a, b) {
          final aValue = (a[sortField] ?? '').toString();
          final bValue = (b[sortField] ?? '').toString();

          return sortAscending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        });

        // Apply pagination (for desktop/tablet view)
        final int startIndex = (currentPage - 1) * pageSize;
        List<DocumentSnapshot> paginatedUsers = filteredUsers;

        if (!isMobile && filteredUsers.length > pageSize) {
          final endIndex = startIndex + pageSize < filteredUsers.length
              ? startIndex + pageSize
              : filteredUsers.length;

          if (startIndex < filteredUsers.length) {
            paginatedUsers = filteredUsers.sublist(startIndex, endIndex);
          } else {
            paginatedUsers = [];
          }
        }

        // For mobile view, we'll show all results to enable easier scrolling
        final displayedUsers = isMobile ? filteredUsers : paginatedUsers;

        if (isMobile) {
          return Column(
            children: [
              SearchField(
                onChanged: (value) {
                  ref
                      .read(searchQueryProvider.notifier)
                      .state = value;
                  homeNotifier.setSearchQuery(value);
                },
                hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
              ),
              const SizedBox(height: 16),
              const FilterChipsRow(primaryColor: Colors.green,),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? const EmptyStateWidget()
                    : RefreshIndicator(
                  onRefresh: () async {
                    // Refresh the data
                    // ref.refresh(trustedUsersStreamProvider);
                    return;
                  },
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 500,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: displayedUsers.length,
                    itemBuilder: (context, index) {
                      final user =
                      UserModel.fromFirestore(displayedUsers[index]);
                      return UserCard(
                        user: user,
                        onTap: () {
                          homeNotifier.visibleBar(selected: user);
                          showUserDetailBottomSheet(context, ref, user);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
        else if (isTablet) {
          // Tablet layout with sidebar
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      onChanged: (value) {
                        ref
                            .read(searchQueryProvider.notifier)
                            .state = value;
                        homeNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SortButton(primaryColor: primaryColor,),
                ],
              ),
              const SizedBox(height: 16),
              const FilterChipsRow(primaryColor: Colors.green,),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? const EmptyStateWidget()
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 400,
                                childAspectRatio: 1.2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: displayedUsers.length,
                              itemBuilder: (context, index) {
                                final user = UserModel.fromFirestore(
                                    displayedUsers[index]);
                                return UserCard(
                                  user: user,
                                  onTap: () {
                                    homeNotifier.visibleBar(
                                        selected: user);
                                    // _showUserDetailBottomSheet(
                                    //     context, ref, user);
                                  },
                                );
                              },
                            ),
                          ),
                          if (filteredUsers.length > pageSize)
                            _buildPagination(
                                context, ref, filteredUsers.length),
                        ],
                      ),
                    ),
                    if (showSideBar && selectedUser != null) ...[
                      const SizedBox(width: 24),
                      UserDetailSidebar(
                        user: selectedUser,
                        onClose: () {
                          homeNotifier.closeBar();
                        },
                        onEdit: () =>
                            showEditUserDialog(
                                context, ref, selectedUser),
                        onDelete: () =>
                            showDeleteConfirmation(
                                context, ref, selectedUser),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        } else {
          // Desktop layout with data table
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      onChanged: (value) {
                        ref
                            .read(searchQueryProvider.notifier)
                            .state = value;
                        homeNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SortButton(primaryColor: primaryColor,),
                ],
              ),
              const SizedBox(height: 16),
              const FilterChipsRow(primaryColor: Colors.green,),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? EmptyStateWidget()
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: UsersDataTable(
                              users: displayedUsers,
                              // onSort: (field, ascending) {
                              //   homeNotifier.setSort(field, ascending: ascending);
                              // },
                              // onUserTap: (user) {
                              //   homeNotifier.visibleBar(selected: user);
                              // },
                              // currentSortField: sortField,
                              // isAscending: sortAscending,
                            ),
                          ),
                          if (filteredUsers.length > pageSize)
                            _buildPagination(
                                context, ref, filteredUsers.length),
                        ],
                      ),
                    ),
                    if (showSideBar && selectedUser != null) ...[
                      const SizedBox(width: 24),
                      UserDetailSidebar(
                        user: selectedUser,
                        onClose: () {
                          homeNotifier.closeBar();
                        },
                        onEdit: () =>
                            showEditUserDialog(
                                context, ref, selectedUser),
                        onDelete: () =>
                            showDeleteConfirmation(
                                context, ref, selectedUser),
                      ),
                    ],
                  ],
                ),
              ),
              // Stats footer for larger screens
              if (!isMobile)
                FooterStateWidget(
                    filteredCount: filteredUsers.length,totalCount: snapshot.docs.length),
            ],
          );
        }
      },
      loading: () =>
      const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) =>
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل البيانات',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // ref.refresh(trustedUsersStreamProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'إعادة المحاولة',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Sort button with dropdown menu
  // Widget _buildSortButton(BuildContext context, WidgetRef ref) {
  //   final sortField = ref.watch(sortFieldProvider);
  //   final sortAscending = ref.watch(sortDirectionProvider);
  //   final homeNotifier = ref.read(homeProvider.notifier);
  //
  //   String getSortFieldName() {
  //     switch (sortField) {
  //       case 'aliasName':
  //         return 'الاسم';
  //       case 'mobileNumber':
  //         return 'رقم الجوال';
  //       case 'location':
  //         return 'الموقع';
  //       case 'reviews':
  //         return 'التقييمات';
  //       default:
  //         return 'الاسم';
  //     }
  //   }
  //
  //   return PopupMenuButton<String>(
  //     tooltip: 'ترتيب',
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 10,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           const Icon(Icons.sort_rounded, size: 20),
  //           const SizedBox(width: 8),
  //           Text(
  //             'ترتيب حسب: ${getSortFieldName()}',
  //             style: GoogleFonts.cairo(),
  //           ),
  //           const SizedBox(width: 8),
  //           Icon(
  //             sortAscending
  //                 ? Icons.arrow_upward_rounded
  //                 : Icons.arrow_downward_rounded,
  //             size: 18,
  //           ),
  //         ],
  //       ),
  //     ),
  //     itemBuilder: (context) =>
  //     [
  //       PopupMenuItem(
  //         value: 'aliasName',
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.person,
  //               size: 18,
  //               color: sortField == 'aliasName' ? primaryColor : Colors.grey,
  //             ),
  //             const SizedBox(width: 8),
  //             Text('الاسم', style: GoogleFonts.cairo()),
  //             const Spacer(),
  //             if (sortField == 'aliasName')
  //               Icon(
  //                 sortAscending
  //                     ? Icons.arrow_upward_rounded
  //                     : Icons.arrow_downward_rounded,
  //                 size: 14,
  //                 color: primaryColor,
  //               ),
  //           ],
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'mobileNumber',
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.phone,
  //               size: 18,
  //               color: sortField == 'mobileNumber' ? primaryColor : Colors.grey,
  //             ),
  //             const SizedBox(width: 8),
  //             Text('رقم الجوال', style: GoogleFonts.cairo()),
  //             const Spacer(),
  //             if (sortField == 'mobileNumber')
  //               Icon(
  //                 sortAscending
  //                     ? Icons.arrow_upward_rounded
  //                     : Icons.arrow_downward_rounded,
  //                 size: 14,
  //                 color: primaryColor,
  //               ),
  //           ],
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'location',
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.location_on,
  //               size: 18,
  //               color: sortField == 'location' ? primaryColor : Colors.grey,
  //             ),
  //             const SizedBox(width: 8),
  //             Text('الموقع', style: GoogleFonts.cairo()),
  //             const Spacer(),
  //             if (sortField == 'location')
  //               Icon(
  //                 sortAscending
  //                     ? Icons.arrow_upward_rounded
  //                     : Icons.arrow_downward_rounded,
  //                 size: 14,
  //                 color: primaryColor,
  //               ),
  //           ],
  //         ),
  //       ),
  //       PopupMenuItem(
  //         value: 'reviews',
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.star,
  //               size: 18,
  //               color: sortField == 'reviews' ? primaryColor : Colors.grey,
  //             ),
  //             const SizedBox(width: 8),
  //             Text('التقييمات', style: GoogleFonts.cairo()),
  //             const Spacer(),
  //             if (sortField == 'reviews')
  //               Icon(
  //                 sortAscending
  //                     ? Icons.arrow_upward_rounded
  //                     : Icons.arrow_downward_rounded,
  //                 size: 14,
  //                 color: primaryColor,
  //               ),
  //           ],
  //         ),
  //       ),
  //     ],
  //     onSelected: (value) {
  //       if (sortField == value) {
  //         // Toggle direction if same field
  //         homeNotifier.setSort(value);
  //       } else {
  //         // Set new field and reset to ascending
  //         homeNotifier.setSort(value, ascending: true);
  //       }
  //     },
  //   );
  // }
  // Pagination controls
  Widget _buildPagination(BuildContext context, WidgetRef ref, int totalItems) {
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final totalPages = (totalItems / pageSize).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page size dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<int>(
              value: pageSize,
              isDense: true,
              underline: const SizedBox(),
              items: [10, 25, 50, 100]
                  .map((size) =>
                  DropdownMenuItem<int>(
                    value: size,
                    child:
                    Text('$size لكل صفحة', style: GoogleFonts.cairo()),
                  ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  homeNotifier.setPageSize(value);
                }
              },
            ),
          ),
          const Spacer(),
          // Page navigation
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed:
            currentPage > 1 ? () => homeNotifier.setCurrentPage(1) : null,
            tooltip: 'الصفحة الأولى',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: currentPage > 1
                ? () => homeNotifier.setCurrentPage(currentPage - 1)
                : null,
            tooltip: 'الصفحة السابقة',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '$currentPage من $totalPages',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: currentPage < totalPages
                ? () => homeNotifier.setCurrentPage(currentPage + 1)
                : null,
            tooltip: 'الصفحة التالية',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => homeNotifier.setCurrentPage(totalPages)
                : null,
            tooltip: 'الصفحة الأخيرة',
            color: primaryColor,
            disabledColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}