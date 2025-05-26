import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/core/widgets/footer_state_widget.dart';
import 'package:trustedtallentsvalley/core/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/trusted_help_dialog.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/sideBarWidget.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/status_chip.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/user_card.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1200;
    final isLoading = ref.watch(isLoadingProvider);
    debugPrint("this truested ${trustedUsersStreamProvider.name}");
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
          if (!isMobile && ref.watch(isAdminProvider))
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => _showExportDialog(context, ref),
              tooltip: 'تصدير البيانات',
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => showHelpDialog(context),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMainContent(context, ref,
              isMobile: isMobile, isTablet: isTablet),
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () => _showAddUserDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref, {
    bool isMobile = false,
    bool isTablet = false,
  }) {
    // Watch state
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
    final homeNotifier = ref.read(homeProvider.notifier);

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

        debugPrint(
            'UsersListScreen: After filtering and sorting: ${filteredUsers.length} users');

        // Apply pagination (only for desktop/tablet)
        List<UserModel> displayedUsers = filteredUsers;
        int totalPages = 1;

        if (!isMobile && filteredUsers.length > pageSize) {
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

        debugPrint(
            'UsersListScreen: Final displayedUsers: ${displayedUsers.length}');

        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Debug info (remove in production)
              if (ref.watch(isAdminProvider))
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    'Debug: Total: ${snapshot.docs.length}, Filtered: ${filteredUsers.length}, Displayed: ${displayedUsers.length}, Page: $currentPage/$totalPages',
                    style: GoogleFonts.cairo(
                        fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),

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
                  if (!isMobile) ...[
                    const SizedBox(width: 16),
                    _buildSortButton(context, ref),
                  ],
                  if (ref.watch(isAdminProvider)) ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final success = await homeNotifier
                            .batchAddPredefinedUsers(ref: ref);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة جميع المستخدمين بنجاح!',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.group_add),
                      label: Text('إضافة المستخدمين الافتراضيين',
                          style: GoogleFonts.cairo()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Filter chips
              _buildFilterChips(context, ref),

              const SizedBox(height: 24),

              // Main content area
              Expanded(
                child: displayedUsers.isEmpty
                    ? _buildEmptyState(
                        filteredUsers.isEmpty, searchQuery, filterMode)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main content
                          Expanded(
                            child: Column(
                              children: [
                                // Content based on screen size
                                Expanded(
                                  child: isMobile
                                      ? _buildMobileView(context, ref,
                                          displayedUsers, visiblePhoneNumberId)
                                      : isTablet
                                          ? _buildTabletView(
                                              context,
                                              ref,
                                              displayedUsers,
                                              visiblePhoneNumberId)
                                          : _buildDesktopView(
                                              context,
                                              ref,
                                              displayedUsers,
                                              visiblePhoneNumberId),
                                ),

                                // Pagination (for desktop/tablet)
                                if (!isMobile &&
                                    filteredUsers.length > pageSize)
                                  _buildPagination(context, ref,
                                      filteredUsers.length, totalPages),
                              ],
                            ),
                          ),

                          // Sidebar
                          if (showSideBar && selectedUser != null) ...[
                            const SizedBox(width: 24),
                            UserDetailSidebar(
                              user: selectedUser,
                              onClose: () => homeNotifier.closeBar(),
                              onEdit: () => _showEditUserDialog(
                                  context, ref, selectedUser),
                              onDelete: () => _showDeleteConfirmation(
                                  context, ref, selectedUser),
                            ),
                          ],
                        ],
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل البيانات',
              style:
                  GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style:
                  GoogleFonts.cairo(color: Colors.grey.shade700, fontSize: 14),
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
      ),
    );
  }

  Widget _buildEmptyState(
      bool isFiltered, String searchQuery, FilterMode filterMode) {
    return Center(
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
              isFiltered ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isFiltered ? 'لا توجد نتائج للبحث' : 'لا توجد مستخدمين للعرض',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (isFiltered) ...[
            Text(
              searchQuery.isNotEmpty
                  ? 'جرب البحث بكلمات مختلفة أو قم بإزالة المرشحات'
                  : 'قم بتغيير معايير التصفية',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'تأكد من أن قاعدة البيانات تحتوي على مستخدمين',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, WidgetRef ref,
      List<UserModel> users, String? visiblePhoneNumberId) {
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          visiblePhoneNumberId: visiblePhoneNumberId,
          onTogglePhoneNumber: (userId) =>
              _togglePhoneNumberVisibility(ref, userId),
          onTap: () =>
              ref.read(homeProvider.notifier).visibleBar(selected: user),
        );
      },
    );
  }

  Widget _buildTabletView(BuildContext context, WidgetRef ref,
      List<UserModel> users, String? visiblePhoneNumberId) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserCard(
          user: user,
          visiblePhoneNumberId: visiblePhoneNumberId,
          onTogglePhoneNumber: (userId) =>
              _togglePhoneNumberVisibility(ref, userId),
          onTap: () =>
              ref.read(homeProvider.notifier).visibleBar(selected: user),
        );
      },
    );
  }

  Widget _buildDesktopView(BuildContext context, WidgetRef ref,
      List<UserModel> users, String? visiblePhoneNumberId) {
    // Convert UserModel list back to DocumentSnapshot format for UsersDataTable
    // This is a temporary solution - ideally UsersDataTable should accept UserModel directly
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
      child: _buildUserTable(context, ref, users, visiblePhoneNumberId),
    );
  }

  Widget _buildUserTable(BuildContext context, WidgetRef ref,
      List<UserModel> users, String? visiblePhoneNumberId) {
    final isAdmin = ref.watch(isAdminProvider);

    return Column(
      children: [
        // Table header
        Container(
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
                  child: Text('الاسم والحالة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text('رقم الجوال',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 2,
                  child: Text('الموقع',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('التقييمات',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
              Expanded(
                  flex: 1,
                  child: Text('تيليجرام',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
              if (isAdmin) ...[
                Expanded(
                    flex: 1,
                    child: Text('تم بواسطة',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 1,
                    child: Text('إجراءات',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
              ] else
                Expanded(
                    flex: 1,
                    child: Text('تفاصيل',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
            ],
          ),
        ),

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
              final selectedUser = ref.watch(selectedUserProvider);
              final isSelected = user.id == selectedUser?.id;

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
                          ? Border.all(
                              color: primaryColor.withOpacity(0.3), width: 1)
                          : null,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => ref
                      .read(homeProvider.notifier)
                      .visibleBar(selected: user),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Name and Status
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: _buildPhoneNumberSection(
                              context, user, isPhoneVisible, ref),
                        ),

                        // Location
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.location.isEmpty
                                      ? 'غير محدد'
                                      : user.location,
                                  style: GoogleFonts.cairo(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Reviews
                        Expanded(
                          flex: 1,
                          child: user.reviews.isNotEmpty
                              ? Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(user.reviews,
                                          style: GoogleFonts.cairo(),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                )
                              : Text('لا يوجد',
                                  style: GoogleFonts.cairo(
                                      color: Colors.grey.shade500,
                                      fontSize: 12)),
                        ),

                        // Telegram
                        Expanded(
                          flex: 1,
                          child: user.telegramAccount.isNotEmpty
                              ? Row(
                                  children: [
                                    const Icon(Icons.telegram,
                                        size: 16, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text('متوفر',
                                        style: GoogleFonts.cairo(
                                            color: Colors.blue.shade600,
                                            fontSize: 12)),
                                  ],
                                )
                              : Text('غير متوفر',
                                  style: GoogleFonts.cairo(
                                      color: Colors.grey.shade500,
                                      fontSize: 12)),
                        ),

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
                                  onPressed: () => ref
                                      .read(homeProvider.notifier)
                                      .visibleBar(selected: user),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  tooltip: 'عرض التفاصيل',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        primaryColor.withOpacity(0.1),
                                    foregroundColor: primaryColor,
                                    minimumSize: const Size(32, 32),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () =>
                                      _showEditUserDialog(context, ref, user),
                                  icon: const Icon(Icons.edit, size: 16),
                                  tooltip: 'تعديل',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.blue.withOpacity(0.1),
                                    foregroundColor: Colors.blue.shade600,
                                    minimumSize: const Size(32, 32),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () => _showDeleteConfirmation(
                                      context, ref, user),
                                  icon: const Icon(Icons.delete, size: 16),
                                  tooltip: 'حذف',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        Colors.red.withOpacity(0.1),
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
                                  onPressed: () => ref
                                      .read(homeProvider.notifier)
                                      .visibleBar(selected: user),
                                  icon: const Icon(Icons.visibility, size: 18),
                                  tooltip: 'عرض التفاصيل',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        primaryColor.withOpacity(0.1),
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

  Widget _buildPhoneNumberSection(BuildContext context, UserModel user,
      bool isPhoneVisible, WidgetRef ref) {
    if (isPhoneVisible) {
      return Row(
        children: [
          GestureDetector(
            onTap: () => _copyToClipboard(context, user.mobileNumber),
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
                    user.mobileNumber,
                    style: GoogleFonts.cairo(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.content_copy,
                      size: 14, color: Colors.green.shade600),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.visibility_off,
                size: 18, color: Colors.grey.shade600),
            onPressed: () => _togglePhoneNumberVisibility(ref, user.id),
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
      onPressed: () => _togglePhoneNumberVisibility(ref, user.id),
      icon: const Icon(Icons.visibility, size: 16),
      label: Text('اظهر رقم الجوال', style: GoogleFonts.cairo(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            Text('تم نسخ رقم الجوال بنجاح', style: GoogleFonts.cairo()),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final filterMode = ref.watch(filterModeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomFilterChip(
            primaryColor: primaryColor,
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == FilterMode.all,
            onSelected: (selected) {
              if (selected) homeNotifier.setFilterMode(FilterMode.all);
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: primaryColor,
            label: 'لديهم تقييمات',
            icon: Icons.star_rounded,
            selected: filterMode == FilterMode.withReviews,
            onSelected: (selected) {
              if (selected) homeNotifier.setFilterMode(FilterMode.withReviews);
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: primaryColor,
            label: 'بدون تيليجرام',
            icon: Icons.telegram,
            selected: filterMode == FilterMode.withoutTelegram,
            onSelected: (selected) {
              if (selected)
                homeNotifier.setFilterMode(FilterMode.withoutTelegram);
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: primaryColor,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == FilterMode.byLocation,
            onSelected: (selected) {
              if (selected) _showLocationFilterDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

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
        case 'role':
          return 'الحالة';
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
            Text('ترتيب حسب: ${getSortFieldName()}',
                style: GoogleFonts.cairo()),
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
        _buildSortMenuItem(
            'aliasName', 'الاسم', Icons.person, sortField, sortAscending),
        _buildSortMenuItem('mobileNumber', 'رقم الجوال', Icons.phone, sortField,
            sortAscending),
        _buildSortMenuItem(
            'location', 'الموقع', Icons.location_on, sortField, sortAscending),
        _buildSortMenuItem(
            'reviews', 'التقييمات', Icons.star, sortField, sortAscending),
        _buildSortMenuItem(
            'role', 'الحالة', Icons.security, sortField, sortAscending),
      ],
      onSelected: (value) {
        if (sortField == value) {
          homeNotifier.setSort(value);
        } else {
          homeNotifier.setSort(value, ascending: true);
        }
      },
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(String value, String label,
      IconData icon, String currentSortField, bool sortAscending) {
    final isSelected = currentSortField == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? primaryColor : Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo()),
          const Spacer(),
          if (isSelected)
            Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildPagination(
      BuildContext context, WidgetRef ref, int totalItems, int totalPages) {
    final currentPage = ref.watch(currentPageProvider);
    final pageSize = ref.watch(pageSizeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

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
                if (value != null) homeNotifier.setPageSize(value);
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
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
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

    if (locations.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية حسب الموقع',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر الموقع للتصفية', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            if (locations.value!.isEmpty)
              Text('لا توجد مواقع متاحة',
                  style: GoogleFonts.cairo(), textAlign: TextAlign.center)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);
    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم تصدير البيانات',
              style: GoogleFonts.cairo()),
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
            Text('تصدير البيانات',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر صيغة التصدير:', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            _buildExportOption(context,
                title: 'Excel (XLSX)',
                icon: Icons.table_chart, onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('xlsx');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
            _buildExportOption(context, title: 'CSV', icon: Icons.description,
                onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('csv');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
            _buildExportOption(context,
                title: 'PDF', icon: Icons.picture_as_pdf, onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('pdf');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title, style: GoogleFonts.cairo()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      hoverColor: primaryColor.withOpacity(0.1),
    );
  }

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
    int role = 1; // 1 = موثوق, 2 = معروف, 3 = نصاب

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم إضافة مستخدمين جدد',
              style: GoogleFonts.cairo()),
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
            Text('إضافة مستخدم جديد',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال رقم الجوال'
                      : null,
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الموقع'
                      : null,
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => servicesProvided = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => telegramAccount = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => otherAccounts = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => reviews = value,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          RadioListTile<int>(
                            title: Text('موثوق', style: GoogleFonts.cairo()),
                            value: 1,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.green,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('معروف', style: GoogleFonts.cairo()),
                            value: 2,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.orange,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('نصاب', style: GoogleFonts.cairo()),
                            value: 3,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.red,
                            dense: true,
                          ),
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
            child: Text('إلغاء', style: GoogleFonts.cairo()),
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
                  role: role, // Fixed parameter name
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text('إضافة', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

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
    int role = user.role; // Fixed variable name

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم تعديل المستخدمين',
              style: GoogleFonts.cairo()),
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
            Text('تعديل مستخدم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mobileNumber,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال رقم الجوال'
                      : null,
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: location,
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الموقع'
                      : null,
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: servicesProvided,
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => servicesProvided = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: telegramAccount,
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => telegramAccount = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: otherAccounts,
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => otherAccounts = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: reviews,
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => reviews = value ?? '',
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          RadioListTile<int>(
                            title: Text('موثوق', style: GoogleFonts.cairo()),
                            value: 1,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.green,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('معروف', style: GoogleFonts.cairo()),
                            value: 2,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.orange,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('نصاب', style: GoogleFonts.cairo()),
                            value: 3,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.red,
                            dense: true,
                          ),
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
            child: Text('إلغاء', style: GoogleFonts.cairo()),
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
                  role: role, // Fixed parameter name
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, UserModel user) {
    final homeNotifier = ref.read(homeProvider.notifier);

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم حذف المستخدمين',
              style: GoogleFonts.cairo()),
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
            Text('حذف مستخدم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من أنك تريد حذف هذا المستخدم؟',
                style: GoogleFonts.cairo()),
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
                        Text(user.aliasName,
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        Text(user.mobileNumber,
                            style:
                                GoogleFonts.cairo(color: Colors.grey.shade700)),
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
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await homeNotifier.deleteUser(user.id);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المستخدم بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Helper class for phone number visibility
final visiblePhoneNumberProvider = StateProvider<String?>((ref) => null);

// UserDetailSidebar widget
