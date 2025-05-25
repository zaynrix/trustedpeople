import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/core/widgets/empty_state_widget.dart';
import 'package:trustedtallentsvalley/core/widgets/footer_state_widget.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/trusted_help_dialog.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/user_info_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/users_data_table.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class UsersListScreen extends ConsumerWidget {
  final String title;
  final AsyncValue<QuerySnapshot> usersStream;
  final Color primaryColor;
  final Color backgroundColor;

  UsersListScreen({
    Key? key,
    required this.title,
    required this.usersStream,
    this.primaryColor = Colors.green,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                return Container(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMainContent(
                    context,
                    ref,
                    constraints,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                );
              },
            ),
      // FAB for adding new users (if admin)
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () {
                _showAddUserDialog(context, ref);
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  final visiblePhoneNumberProvider = StateProvider<String?>((ref) => null);

  // Method to toggle phone number visibility
  void _togglePhoneNumberVisibility(WidgetRef ref, String userId) {
    final currentVisibleId = ref.read(visiblePhoneNumberProvider);

    if (currentVisibleId == userId) {
      // Hide the current visible number
      ref.read(visiblePhoneNumberProvider.notifier).state = null;
    } else {
      // Show this user's number (and hide any other)
      ref.read(visiblePhoneNumberProvider.notifier).state = userId;
    }
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
    final visiblePhoneNumberId = ref.watch(visiblePhoneNumberProvider);

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
                    ? const EmptyStateWidget()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: UsersDataTable(
                                          users: displayedUsers,
                                          visiblePhoneNumberId:
                                              visiblePhoneNumberId,
                                          onTogglePhoneNumber: (userId) =>
                                              _togglePhoneNumberVisibility(
                                                  ref, userId),
                                          onEditUser: (user) =>
                                              _showEditUserDialog(
                                                  context, ref, user),
                                          onDeleteUser: (user) =>
                                              _showDeleteConfirmation(
                                                  context, ref, user),
                                        )),
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
                              onEdit: () => _showEditUserDialog(
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
                                        visiblePhoneNumberId:
                                            visiblePhoneNumberId,
                                        onTogglePhoneNumber: (userId) =>
                                            _togglePhoneNumberVisibility(
                                                ref, userId),
                                        onTap: () {
                                          homeNotifier.visibleBar(
                                              selected: user);
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
                              onEdit: () => _showEditUserDialog(
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
              ElevatedButton(
                onPressed: () async {
                  final homeNotifier = ref.read(homeProvider.notifier);
                  final success = await ref
                      .read(homeProvider.notifier)
                      .batchAddPredefinedUsers(ref: ref);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('تم إضافة جميع المستخدمين بنجاح!')),
                    );
                  }
                },
                child: Text('إضافة جميع المستخدمين'),
              ),
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
                    ? const EmptyStateWidget()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: UsersDataTable(
                                    users: displayedUsers,
                                    visiblePhoneNumberId: visiblePhoneNumberId,
                                    onTogglePhoneNumber: (userId) =>
                                        _togglePhoneNumberVisibility(
                                            ref, userId),
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
                              onEdit: () => _showEditUserDialog(
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
                FooterStateWidget(
                    filteredCount: filteredUsers.length,
                    totalCount: snapshot.docs.length),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomFilterChip(
            primaryColor: Colors.green,
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == FilterMode.all,
            onSelected: (selected) {
              if (selected) {
                homeNotifier.setFilterMode(FilterMode.all);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.green,
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
          CustomFilterChip(
            primaryColor: Colors.green,
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
          CustomFilterChip(
            primaryColor: Colors.green,
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

  // Dialog for adding a new user
  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final homeNotifier = ref.read(homeProvider.notifier);

    String aliasName = '';
    String mobileNumber = '';
    String location = '';
    String? servicesProvided;
    String? telegramAccount;
    String? otherAccounts;
    String? reviews;
    bool isTrusted = true;
    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، فقط المشرفين يمكنهم إضافة مستخدمين جدد',
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
            Icon(Icons.person_add, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'إضافة مستخدم جديد',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الاسم المستعار',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الجوال';
                    }
                    return null;
                  },
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الموقع';
                    }
                    return null;
                  },
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => servicesProvided = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => telegramAccount = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => otherAccounts = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => reviews = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'الحالة:',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isTrusted,
                            onChanged: (value) {
                              setState(() => isTrusted = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('موثوق', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isTrusted,
                            onChanged: (value) {
                              setState(() => isTrusted = value!);
                            },
                            activeColor: Colors.red,
                          ),
                          Text('نصاب', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final success = await homeNotifier.addUser(
                  ref: ref,
                  aliasName: aliasName,
                  mobileNumber: mobileNumber,
                  location: location,
                  servicesProvided: servicesProvided,
                  telegramAccount: telegramAccount,
                  otherAccounts: otherAccounts,
                  reviews: reviews,
                  isTrusted: isTrusted,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تمت إضافة المستخدم بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'إضافة',
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

  // Dialog for editing a user
  void _showEditUserDialog(
      BuildContext context, WidgetRef ref, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final homeNotifier = ref.read(homeProvider.notifier);

    String aliasName = user.aliasName;
    String mobileNumber = user.mobileNumber;
    String location = user.location;
    String servicesProvided = user.servicesProvided;
    String telegramAccount = user.telegramAccount;
    String otherAccounts = user.otherAccounts;
    String reviews = user.reviews;
    bool isTrusted = user.isTrusted;
    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عذراً، فقط المشرفين يمكنهم تعديل المستخدمين',
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
            Icon(Icons.edit, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'تعديل مستخدم',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: aliasName,
                  decoration: InputDecoration(
                    labelText: 'الاسم المستعار',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mobileNumber,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الجوال';
                    }
                    return null;
                  },
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: location,
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الموقع';
                    }
                    return null;
                  },
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: servicesProvided,
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => servicesProvided = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: telegramAccount,
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => telegramAccount = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: otherAccounts,
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => otherAccounts = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: reviews,
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => reviews = value ?? '',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'الحالة:',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isTrusted,
                            onChanged: (value) {
                              setState(() => isTrusted = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('موثوق', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isTrusted,
                            onChanged: (value) {
                              setState(() => isTrusted = value!);
                            },
                            activeColor: Colors.red,
                          ),
                          Text('نصاب', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final success = await homeNotifier.updateUser(
                  id: user.id,
                  aliasName: aliasName,
                  mobileNumber: mobileNumber,
                  location: location,
                  servicesProvided: servicesProvided,
                  telegramAccount: telegramAccount,
                  otherAccounts: otherAccounts,
                  reviews: reviews,
                  isTrusted: isTrusted,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تحديث المستخدم بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: Text(
              'حفظ',
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

// Make sure to update the UserDetailSidebar to include edit and delete options
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
                StatusChip(
                  isTrusted: user.isTrusted,
                  role: (user.role as num?)
                      ?.toInt(), // Convert to int if it exists
                  compact: true,
                ),
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
