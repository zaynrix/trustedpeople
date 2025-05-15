import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/users_data_table.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/add_user_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/edit_user_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/widgets/user_detail_slidebar.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class UsersListScreen extends ConsumerWidget {
  final String title;
  final AsyncValue<QuerySnapshot> usersStream;
  final Color primaryColor;
  final Color backgroundColor;

  const UsersListScreen({
    Key? key,
    required this.title,
    required this.usersStream,
    this.primaryColor = Colors.green,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
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
                _showExportDialog(context, ref);
              },
              tooltip: 'تصدير البيانات',
            ),
          // Help button - visible to everyone
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {
              _showHelpDialog(context);
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

  Widget _buildMainContent(
    BuildContext context,
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
              final hasReviews = (user['reviews'] ?? '').toString().isNotEmpty;
              return matchesSearch && hasReviews;
            case FilterMode.withoutTelegram:
              final noTelegram =
                  (user['telegramAccount'] ?? '').toString().isEmpty;
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
                  ref.read(searchQueryProvider.notifier).state = value;
                  homeNotifier.setSearchQuery(value);
                },
                hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
              ),
              const SizedBox(height: 16),
              _buildFilterChips(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? _buildEmptyState()
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
                                _showUserDetailBottomSheet(context, ref, user);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        } else if (isTablet) {
          // Tablet layout with sidebar
          return Column(
            children: [
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
                  _buildSortButton(context, ref),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilterChips(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? _buildEmptyState()
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
                              onEdit: () => showEditUserDialog(
                                  context, ref, selectedUser),
                              onDelete: () => _showDeleteConfirmation(
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
                        ref.read(searchQueryProvider.notifier).state = value;
                        homeNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث بالاسم أو رقم الجوال أو الموقع',
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildSortButton(context, ref),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilterChips(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: displayedUsers.isEmpty
                    ? _buildEmptyState()
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
                              onEdit: () => showEditUserDialog(
                                  context, ref, selectedUser),
                              onDelete: () => _showDeleteConfirmation(
                                  context, ref, selectedUser),
                            ),
                          ],
                        ],
                      ),
              ),
              // Stats footer for larger screens
              if (!isMobile)
                _buildStatsFooter(
                    context, filteredUsers.length, snapshot.docs.length),
            ],
          );
        }
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
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
  Widget _buildSortButton(BuildContext context, WidgetRef ref) {
    final sortField = ref.watch(sortFieldProvider);
    final sortAscending = ref.watch(sortDirectionProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    String getSortFieldName() {
      switch (sortField) {
        case 'aliasName':
          return 'الاسم';
        case 'mobileNumber':
          return 'رقم الجوال';
        case 'location':
          return 'الموقع';
        case 'reviews':
          return 'التقييمات';
        default:
          return 'الاسم';
      }
    }

    return PopupMenuButton<String>(
      tooltip: 'ترتيب',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.sort_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              'ترتيب حسب: ${getSortFieldName()}',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(width: 8),
            Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 18,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'aliasName',
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 18,
                color: sortField == 'aliasName' ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text('الاسم', style: GoogleFonts.cairo()),
              const Spacer(),
              if (sortField == 'aliasName')
                Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: primaryColor,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'mobileNumber',
          child: Row(
            children: [
              Icon(
                Icons.phone,
                size: 18,
                color: sortField == 'mobileNumber' ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text('رقم الجوال', style: GoogleFonts.cairo()),
              const Spacer(),
              if (sortField == 'mobileNumber')
                Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: primaryColor,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'location',
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: sortField == 'location' ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text('الموقع', style: GoogleFonts.cairo()),
              const Spacer(),
              if (sortField == 'location')
                Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: primaryColor,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reviews',
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 18,
                color: sortField == 'reviews' ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text('التقييمات', style: GoogleFonts.cairo()),
              const Spacer(),
              if (sortField == 'reviews')
                Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: primaryColor,
                ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (sortField == value) {
          // Toggle direction if same field
          homeNotifier.setSort(value);
        } else {
          // Set new field and reset to ascending
          homeNotifier.setSort(value, ascending: true);
        }
      },
    );
  }

  // Filter chips
  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final filterMode = ref.watch(filterModeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final locations = ref.watch(locationsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == FilterMode.all,
            onSelected: (selected) {
              if (selected) {
                homeNotifier.setFilterMode(FilterMode.all);
              }
            },
            context: context,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'لديهم تقييمات',
            icon: Icons.star_rounded,
            selected: filterMode == FilterMode.withReviews,
            onSelected: (selected) {
              if (selected) {
                homeNotifier.setFilterMode(FilterMode.withReviews);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'بدون تيليجرام',
            icon: Icons.telegram,
            selected: filterMode == FilterMode.withoutTelegram,
            onSelected: (selected) {
              if (selected) {
                homeNotifier.setFilterMode(FilterMode.withoutTelegram);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == FilterMode.byLocation,
            onSelected: (selected) {
              if (selected) {
                _showLocationFilterDialog(context, ref);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return InkWell(
      onTap: () => onSelected(!selected),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  .map((size) => DropdownMenuItem<int>(
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

  // Stats footer
  Widget _buildStatsFooter(
      BuildContext context, int filteredCount, int totalCount) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Text(
            'عرض $filteredCount من إجمالي $totalCount',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            'آخر تحديث: ${DateTime.now().toString().substring(0, 16)}',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetailBottomSheet(
      BuildContext context, WidgetRef ref, UserModel user) {
    final homeNotifier = ref.read(homeProvider.notifier);
    final isAdmin = ref.watch(isAdminProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Expanded(
                    child: UserDetailSidebar(
                      user: user,
                      onClose: () {
                        Navigator.pop(context);
                        homeNotifier.closeBar();
                      },
                      onEdit: isAdmin
                          ? () {
                              Navigator.pop(context);
                              showEditUserDialog(context, ref, user);
                            }
                          : null,
                      onDelete: isAdmin
                          ? () {
                              Navigator.pop(context);
                              _showDeleteConfirmation(context, ref, user);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لم يتم العثور على أي نتائج',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول البحث بكلمات مفتاحية أخرى',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog to filter by location
  void _showLocationFilterDialog(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);
    final locations = ref.watch(locationsProvider);

    // Show loading if locations are loading
    if (locations.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

    // Show error if locations failed to load
    if (locations.hasError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('فشل تحميل المواقع: ${locations.error}',
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    // Show locations dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تصفية حسب الموقع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر الموقع للتصفية',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            if (locations.value!.isEmpty)
              Text(
                'لا توجد مواقع متاحة',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              )
            else
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.value!.length,
                  itemBuilder: (context, index) {
                    final location = locations.value![index];
                    return ListTile(
                      title: Text(location, style: GoogleFonts.cairo()),
                      leading: const Icon(Icons.location_on_outlined),
                      onTap: () {
                        homeNotifier.setLocationFilter(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              homeNotifier.setFilterMode(FilterMode.all);
              Navigator.pop(context);
            },
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'المساعدة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                title: 'البحث',
                description: 'يمكنك البحث بالاسم أو رقم الجوال أو الموقع',
                icon: Icons.search,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'التصفية',
                description: 'استخدم خيارات التصفية لعرض نتائج محددة',
                icon: Icons.filter_list,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'الترتيب',
                description: 'يمكنك ترتيب النتائج حسب الاسم أو الموقع أو غيرها',
                icon: Icons.sort,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'التفاصيل',
                description: 'انقر على "المزيد" لعرض جميع تفاصيل المستخدم',
                icon: Icons.info_outline,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'نسخ البيانات',
                description: 'انقر على أي معلومة لنسخها إلى الحافظة',
                icon: Icons.content_copy,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(
                color: primaryColor,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Helper for building help items
  Widget _buildHelpItem({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dialog for exporting data
  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);
    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، فقط المشرفين يمكنهم تصدير البيانات',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'تصدير البيانات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر صيغة التصدير:',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            _buildExportOption(
              context,
              title: 'Excel (XLSX)',
              icon: Icons.table_chart,
              onTap: () async {
                Navigator.pop(context);
                final result = await homeNotifier.exportData('xlsx');
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            _buildExportOption(
              context,
              title: 'CSV',
              icon: Icons.description,
              onTap: () async {
                Navigator.pop(context);
                final result = await homeNotifier.exportData('csv');
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            _buildExportOption(
              context,
              title: 'PDF',
              icon: Icons.picture_as_pdf,
              onTap: () async {
                Navigator.pop(context);
                final result = await homeNotifier.exportData('pdf');
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Export option item
  Widget _buildExportOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: GoogleFonts.cairo()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
      hoverColor: primaryColor.withOpacity(0.1),
    );
  }


  // Confirmation dialog for deleting a user
  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, UserModel user) {
    final homeNotifier = ref.read(homeProvider.notifier);
    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، فقط المشرفين يمكنهم حذف المستخدمين',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'حذف مستخدم',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من أنك تريد حذف هذا المستخدم؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.aliasName,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user.mobileNumber,
                          style: GoogleFonts.cairo(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه.',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await homeNotifier.deleteUser(user.id);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف المستخدم بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

