import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/app/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/widgets/filter_option_payment_places.dart';
import 'package:trustedtallentsvalley/app/core/widgets/search_field.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/domain/entities/admin_payment_place.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/domain/repositories/admin_payment_places_repository.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/providers/admin_payment_places_provider.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/widgets/admin_place_card.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/widgets/admin_place_detail_sidebar.dart';
import 'package:trustedtallentsvalley/features/admin/payment_places/presentation/widgets/admin_places_data_table.dart';

class AdminPaymentPlacesScreen extends ConsumerWidget {
  const AdminPaymentPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesStream = ref.watch(adminPaymentPlacesStreamProvider);
    // Admin check is not needed as this screen is admin-only

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 768,
        title: Text(
          "إدارة أماكن الدفع البنكي",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
        actions: [
          if (MediaQuery.of(context).size.width >= 768)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => _showExportDialog(context, ref),
              tooltip: 'تصدير البيانات',
            ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'المساعدة',
          ),
          const SizedBox(width: 8),
        ],
        shape: MediaQuery.of(context).size.width < 768
            ? null
            : const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      drawer:
      MediaQuery.of(context).size.width < 768 ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side drawer for larger screens
              if (constraints.maxWidth >= 768)
                const AppDrawer(isPermanent: true),

              // Main content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildMainContent(
                    context,
                    ref,
                    constraints,
                    isMobile: constraints.maxWidth < 768,
                    isTablet: constraints.maxWidth >= 768 &&
                        constraints.maxWidth < 1200,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () => _showAddPlaceDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'إضافة متجر جديد',
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context,
      WidgetRef ref,
      BoxConstraints constraints, {
        bool isMobile = false,
        bool isTablet = false,
      }) {
    final searchQuery = ref.watch(adminSearchQueryProvider);
    final showSideBar = ref.watch(adminShowSideBarProvider);
    final selectedPlace = ref.watch(adminSelectedPlaceProvider);
    final currentPage = ref.watch(adminCurrentPageProvider);
    final pageSize = ref.watch(adminPageSizeProvider);
    final sortField = ref.watch(adminSortFieldProvider);
    final sortAscending = ref.watch(adminSortDirectionProvider);
    final filterMode = ref.watch(adminFilterModeProvider);

    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final placesStream = ref.watch(adminPaymentPlacesStreamProvider);

    // Error handling
    final errorMessage = ref.watch(adminErrorMessageProvider);
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

    return placesStream.when(
      data: (places) {
        // Apply filtering
        var filteredPlaces = places.where((place) {
          final query = searchQuery.toLowerCase();

          // Search filter
          bool matchesSearch = query.isEmpty ||
              place.name.toLowerCase().contains(query) ||
              place.phoneNumber.contains(query) ||
              place.location.toLowerCase().contains(query) ||
              place.category.toLowerCase().contains(query);

          // Additional filters
          switch (filterMode) {
            case AdminPlacesFilterMode.all:
              return matchesSearch;
            case AdminPlacesFilterMode.verified:
              return matchesSearch && place.isVerified;
            case AdminPlacesFilterMode.unverified:
              return matchesSearch && !place.isVerified;
            case AdminPlacesFilterMode.highRated:
              return matchesSearch && place.rating >= 4.0;
            case AdminPlacesFilterMode.category:
              final categoryFilter =
                  ref.watch(adminPaymentPlacesProvider).categoryFilter;
              if (categoryFilter == null || categoryFilter.isEmpty) {
                return matchesSearch;
              }
              return matchesSearch &&
                  place.category.toLowerCase() == categoryFilter.toLowerCase();
            case AdminPlacesFilterMode.byLocation:
              final locationFilter =
                  ref.watch(adminPaymentPlacesProvider).locationFilter;
              if (locationFilter == null || locationFilter.isEmpty) {
                return matchesSearch;
              }
              return matchesSearch &&
                  place.location
                      .toLowerCase()
                      .contains(locationFilter.toLowerCase());
          }
        }).toList();

        // Apply sorting
        filteredPlaces.sort((a, b) {
          switch (sortField) {
            case 'name':
              return sortAscending
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name);
            case 'category':
              return sortAscending
                  ? a.category.compareTo(b.category)
                  : b.category.compareTo(a.category);
            case 'location':
              return sortAscending
                  ? a.location.compareTo(b.location)
                  : b.location.compareTo(a.location);
            case 'phoneNumber':
              return sortAscending
                  ? a.phoneNumber.compareTo(b.phoneNumber)
                  : b.phoneNumber.compareTo(a.phoneNumber);
            case 'rating':
              return sortAscending
                  ? a.rating.compareTo(b.rating)
                  : b.rating.compareTo(a.rating);
            default:
              return sortAscending
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name);
          }
        });

        // Apply pagination (except for mobile)
        final int startIndex = (currentPage - 1) * pageSize;
        List<AdminPaymentPlace> paginatedPlaces = filteredPlaces;

        if (!isMobile && filteredPlaces.length > pageSize) {
          final endIndex = startIndex + pageSize < filteredPlaces.length
              ? startIndex + pageSize
              : filteredPlaces.length;

          if (startIndex < filteredPlaces.length) {
            paginatedPlaces = filteredPlaces.sublist(startIndex, endIndex);
          } else {
            paginatedPlaces = [];
          }
        }

        final displayedPlaces = isMobile ? filteredPlaces : paginatedPlaces;

        if (isMobile) {
          // Mobile layout with grid view
          return Column(
            children: [
              SearchField(
                onChanged: (value) {
                  ref.read(adminSearchQueryProvider.notifier).state = value;
                  placesNotifier.setSearchQuery(value);
                },
                hintText: 'البحث باسم المكان أو الموقع أو التصنيف',
              ),
              const SizedBox(height: 16),
              const AdminFilterOptions(),
              const SizedBox(height: 24),
              Expanded(
                child: displayedPlaces.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                  onRefresh: () async {
                    // Refresh the data
                    ref.refresh(adminPaymentPlacesStreamProvider);
                    return;
                  },
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 500,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: displayedPlaces.length,
                    itemBuilder: (context, index) {
                      final place = displayedPlaces[index];
                      return AdminPlaceCard(
                        place: place,
                        onTap: () {
                          placesNotifier.selectPlace(place);
                          _showPlaceDetailBottomSheet(
                              context, ref, place);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        } else if (isTablet) {
          // Tablet layout with grid and sidebar
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      onChanged: (value) {
                        ref.read(adminSearchQueryProvider.notifier).state =
                            value;
                        placesNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث باسم المكان أو الموقع أو التصنيف',
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
                child: displayedPlaces.isEmpty
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
                                maxCrossAxisExtent: 300,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: displayedPlaces.length,
                              itemBuilder: (context, index) {
                                final place = displayedPlaces[index];
                                return AdminPlaceCard(
                                  place: place,
                                  onTap: () {
                                    placesNotifier.selectPlace(place);
                                  },
                                );
                              },
                            ),
                          ),
                          if (filteredPlaces.length > pageSize)
                            _buildPagination(
                                context, ref, filteredPlaces.length),
                        ],
                      ),
                    ),
                    if (showSideBar && selectedPlace != null) ...[
                      const SizedBox(width: 24),
                      AdminPlaceDetailSidebar(
                        place: selectedPlace,
                        onClose: () {
                          placesNotifier.closeBar();
                        },
                        onEdit: () => _showEditPlaceDialog(
                            context, ref, selectedPlace),
                        onDelete: () => _showDeleteConfirmation(
                            context, ref, selectedPlace),
                        onVerify: selectedPlace.isVerified
                            ? null
                            : () => _updateVerificationStatus(
                            context, ref, selectedPlace.id, true),
                        onUnverify: selectedPlace.isVerified
                            ? () => _updateVerificationStatus(
                            context, ref, selectedPlace.id, false)
                            : null,
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
                        ref.read(adminSearchQueryProvider.notifier).state =
                            value;
                        placesNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث باسم المكان أو الموقع أو التصنيف',
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildSortButton(context, ref),
                ],
              ),
              const SizedBox(height: 16),
              const AdminFilterOptions(),
              const SizedBox(height: 24),
              Expanded(
                child: displayedPlaces.isEmpty
                    ? _buildEmptyState()
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: AdminPlacesDataTable(
                              places: displayedPlaces,
                              onSort: (field, ascending) {
                                placesNotifier.setSort(field,
                                    ascending: ascending);
                              },
                              onPlaceTap: (place) {
                                placesNotifier.selectPlace(place);
                              },
                              onVerify: (place) =>
                                  _updateVerificationStatus(
                                      context, ref, place.id, true),
                              onUnverify: (place) =>
                                  _updateVerificationStatus(
                                      context, ref, place.id, false),
                              currentSortField: sortField,
                              isAscending: sortAscending,
                            ),
                          ),
                          if (filteredPlaces.length > pageSize)
                            _buildPagination(
                                context, ref, filteredPlaces.length),
                        ],
                      ),
                    ),
                    if (showSideBar && selectedPlace != null) ...[
                      const SizedBox(width: 24),
                      AdminPlaceDetailSidebar(
                        place: selectedPlace,
                        onClose: () {
                          placesNotifier.closeBar();
                        },
                        onEdit: () => _showEditPlaceDialog(
                            context, ref, selectedPlace),
                        onDelete: () => _showDeleteConfirmation(
                            context, ref, selectedPlace),
                        onVerify: selectedPlace.isVerified
                            ? null
                            : () => _updateVerificationStatus(
                            context, ref, selectedPlace.id, true),
                        onUnverify: selectedPlace.isVerified
                            ? () => _updateVerificationStatus(
                            context, ref, selectedPlace.id, false)
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              // Stats footer
              if (!isMobile)
                _buildStatsFooter(
                    context, filteredPlaces.length, places.length),
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
                ref.refresh(adminPaymentPlacesStreamProvider);
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

  // Filter chips
  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final filterMode = ref.watch(adminFilterModeProvider);
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final categories = ref.watch(adminCategoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == AdminPlacesFilterMode.all,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.all);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'متحقق منها',
            icon: Icons.verified_rounded,
            selected: filterMode == AdminPlacesFilterMode.verified,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.verified);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'قيد التحقق',
            icon: Icons.pending_rounded,
            selected: filterMode == AdminPlacesFilterMode.unverified,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.unverified);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'التقييم العالي',
            icon: Icons.star_rounded,
            selected: filterMode == AdminPlacesFilterMode.highRated,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(AdminPlacesFilterMode.highRated);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب التصنيف',
            icon: Icons.category_rounded,
            selected: filterMode == AdminPlacesFilterMode.category,
            onSelected: (selected) {
              if (selected) {
                _showCategoryFilterDialog(context, ref);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == AdminPlacesFilterMode.byLocation,
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

  // Update verification status
  Future<void> _updateVerificationStatus(
      BuildContext context, WidgetRef ref, String id, bool isVerified) async {
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final success = await placesNotifier.updateVerificationStatus(id, isVerified);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isVerified ? 'تم التحقق من المتجر بنجاح' : 'تم إلغاء التحقق من المتجر',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: isVerified ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  // Sort button with dropdown menu
  Widget _buildSortButton(BuildContext context, WidgetRef ref) {
    final sortField = ref.watch(adminSortFieldProvider);
    final sortAscending = ref.watch(adminSortDirectionProvider);
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

    String getSortFieldName() {
      switch (sortField) {
        case 'name':
          return 'الاسم';
        case 'category':
          return 'التصنيف';
        case 'location':
          return 'الموقع';
        case 'phoneNumber':
          return 'رقم الهاتف';
        case 'rating':
          return 'التقييم';
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
        _buildSortMenuItem(
          context,
          ref,
          field: 'name',
          label: 'الاسم',
          icon: Icons.storefront_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'category',
          label: 'التصنيف',
          icon: Icons.category_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'location',
          label: 'الموقع',
          icon: Icons.location_on_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'phoneNumber',
          label: 'رقم الهاتف',
          icon: Icons.phone_rounded,
        ),
        _buildSortMenuItem(
          context,
          ref,
          field: 'rating',
          label: 'التقييم',
          icon: Icons.star_rounded,
        ),
      ],
      onSelected: (value) {
        if (sortField == value) {
          // Toggle direction if same field
          placesNotifier.setSort(value);
        } else {
          // Set new field and reset to ascending
          placesNotifier.setSort(value, ascending: true);
        }
      },
    );
  }

  PopupMenuItem<String> _buildSortMenuItem(
      BuildContext context,
      WidgetRef ref, {
        required String field,
        required String label,
        required IconData icon,
      }) {
    final sortField = ref.watch(adminSortFieldProvider);
    final sortAscending = ref.watch(adminSortDirectionProvider);

    return PopupMenuItem(
      value: field,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: sortField == field ? Colors.blue.shade600 : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.cairo()),
          const Spacer(),
          if (sortField == field)
            Icon(
              sortAscending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
              color: Colors.blue.shade600,
            ),
        ],
      ),
    );
  }

  // Pagination controls
  Widget _buildPagination(BuildContext context, WidgetRef ref, int totalItems) {
    final currentPage = ref.watch(adminCurrentPageProvider);
    final pageSize = ref.watch(adminPageSizeProvider);
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
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
                  placesNotifier.setPageSize(value);
                }
              },
            ),
          ),
          const Spacer(),
          // Page navigation
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed:
            currentPage > 1 ? () => placesNotifier.setCurrentPage(1) : null,
            tooltip: 'الصفحة الأولى',
            color: Colors.blue.shade600,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: currentPage > 1
                ? () => placesNotifier.setCurrentPage(currentPage - 1)
                : null,
            tooltip: 'الصفحة السابقة',
            color: Colors.blue.shade600,
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
                ? () => placesNotifier.setCurrentPage(currentPage + 1)
                : null,
            tooltip: 'الصفحة التالية',
            color: Colors.blue.shade600,
            disabledColor: Colors.grey.shade400,
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => placesNotifier.setCurrentPage(totalPages)
                : null,
            tooltip: 'الصفحة الأخيرة',
            color: Colors.blue.shade600,
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

  // Empty state widget
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

  // Bottom sheet for mobile
  void _showPlaceDetailBottomSheet(
      BuildContext context, WidgetRef ref, AdminPaymentPlace place) {
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

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
                    child: AdminPlaceDetailSidebar(
                      place: place,
                      onClose: () {
                        Navigator.pop(context);
                        placesNotifier.closeBar();
                      },
                      onEdit: () => _showEditPlaceDialog(context, ref, place),
                      onDelete: () => _showDeleteConfirmation(context, ref, place),
                      onVerify: place.isVerified
                          ? null
                          : () {
                        _updateVerificationStatus(
                            context, ref, place.id, true);
                        Navigator.pop(context);
                      },
                      onUnverify: place.isVerified
                          ? () {
                        _updateVerificationStatus(
                            context, ref, place.id, false);
                        Navigator.pop(context);
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

  // Category filter dialog
  void _showCategoryFilterDialog(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final categories = ref.watch(adminCategoriesProvider);

    if (categories.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

    if (categories.hasError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('فشل تحميل التصنيفات: ${categories.error}',
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
        title: Text(
          'تصفية حسب التصنيف',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر التصنيف للتصفية',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            if (categories.value!.isEmpty)
              Text(
                'لا توجد تصنيفات متاحة',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              )
            else
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: categories.value!.length,
                  itemBuilder: (context, index) {
                    final category = categories.value![index];
                    return ListTile(
                      title: Text(category, style: GoogleFonts.cairo()),
                      leading: const Icon(Icons.category_outlined),
                      onTap: () {
                        placesNotifier.setCategoryFilter(category);
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
              placesNotifier.setFilterMode(AdminPlacesFilterMode.all);
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

  // Location filter dialog
  void _showLocationFilterDialog(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);
    final locations = ref.watch(adminLocationsProvider);

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
                        placesNotifier.setLocationFilter(location);
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
              placesNotifier.setFilterMode(AdminPlacesFilterMode.all);
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
            Icon(Icons.help_outline, color: Colors.blue.shade600),
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
                description: 'يمكنك البحث باسم المكان أو الموقع أو التصنيف',
                icon: Icons.search,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'التصفية',
                description:
                'استخدم خيارات التصفية لعرض نتائج محددة (حسب التصنيف، الموقع، أو التقييم)',
                icon: Icons.filter_list,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'الترتيب',
                description:
                'يمكنك ترتيب النتائج حسب الاسم أو الموقع أو التقييم',
                icon: Icons.sort,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'التحقق من المتاجر',
                description:
                'يمكنك تغيير حالة التحقق للمتاجر من خلال الضغط على زر التحقق',
                icon: Icons.verified_user,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'التفاصيل',
                description:
                'انقر على "المزيد" أو على بطاقة المكان لعرض جميع التفاصيل',
                icon: Icons.info_outline,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'الإضافة والتعديل',
                description:
                'يمكنك إضافة متجر جديد من خلال الزر العائم في أسفل الشاشة، أو تعديل متجر حالي من صفحة التفاصيل',
                icon: Icons.edit,
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
                color: Colors.blue.shade600,
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
          Icon(icon, color: Colors.blue.shade600),
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
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue.shade600),
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
                final result = await placesNotifier.exportToExcel();
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
                final result = await placesNotifier.exportToCSV();
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
      leading: Icon(icon, color: Colors.blue.shade600),
      title: Text(title, style: GoogleFonts.cairo()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap,
      hoverColor: Colors.blue.shade50,
    );
  }

  // Dialog for adding a new place
  void _showAddPlaceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

    String name = '';
    String phoneNumber = '';
    String location = '';
    String category = '';
    List<String> paymentMethods = [];
    String workingHours = '';
    String description = '';
    String imageUrl = '';
    bool isVerified = true;

    final availablePaymentMethods = [
      'فيزا',
      'ماستركارد',
      'تحويل بنكي',
      'جوال باي',
      'نقد',
    ];

    // Set to track selected payment methods
    final selectedPaymentMethods = <String>{};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_business, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'إضافة متجر جديد',
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
                    labelText: 'اسم المكان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المكان';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                  onSaved: (value) => phoneNumber = value ?? '',
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
                    labelText: 'التصنيف',
                    hintText: 'مثال: مطعم، سوبرماركت، صيدلية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال التصنيف';
                    }
                    return null;
                  },
                  onSaved: (value) => category = value ?? '',
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طرق الدفع المقبولة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availablePaymentMethods.map((method) {
                          final isSelected =
                          selectedPaymentMethods.contains(method);
                          return FilterChip(
                            label: Text(method, style: GoogleFonts.cairo()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPaymentMethods.add(method);
                                } else {
                                  selectedPaymentMethods.remove(method);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade600,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'ساعات العمل',
                    hintText: 'مثال: 9 صباحاً - 9 مساءً',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => workingHours = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رابط الصورة',
                    hintText: 'اختياري',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => imageUrl = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'وصف',
                    hintText: 'اختياري',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
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
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('متحقق منه', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text('قيد التحقق', style: GoogleFonts.cairo()),
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

                // Create an instance of AdminPaymentPlace from AdminPaymentPlaceModel
                final place = AdminPaymentPlace(
                  id: '', // Will be set by Firestore
                  name: name,
                  phoneNumber: phoneNumber,
                  location: location,
                  category: category,
                  paymentMethods: selectedPaymentMethods.toList(),
                  workingHours: workingHours,
                  description: description,
                  imageUrl: imageUrl,
                  isVerified: isVerified,
                  rating: 0,
                  reviewsCount: 0,
                );

                final success = await placesNotifier.addPlace(place);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تمت إضافة المتجر بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
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

  // Dialog for editing a place
  void _showEditPlaceDialog(
      BuildContext context, WidgetRef ref, AdminPaymentPlace place) {
    final formKey = GlobalKey<FormState>();
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

    String name = place.name;
    String phoneNumber = place.phoneNumber;
    String location = place.location;
    String category = place.category;
    String workingHours = place.workingHours;
    String description = place.description;
    String imageUrl = place.imageUrl;
    bool isVerified = place.isVerified;

    final availablePaymentMethods = [
      'فيزا',
      'ماستركارد',
      'تحويل بنكي',
      'جوال باي',
      'نقد',
    ];

    // Set to track selected payment methods
    final selectedPaymentMethods = place.paymentMethods.toSet();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'تعديل متجر',
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
                  initialValue: name,
                  decoration: InputDecoration(
                    labelText: 'اسم المكان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المكان';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                  onSaved: (value) => phoneNumber = value ?? '',
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
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'التصنيف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال التصنيف';
                    }
                    return null;
                  },
                  onSaved: (value) => category = value ?? '',
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طرق الدفع المقبولة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availablePaymentMethods.map((method) {
                          final isSelected =
                          selectedPaymentMethods.contains(method);
                          return FilterChip(
                            label: Text(method, style: GoogleFonts.cairo()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPaymentMethods.add(method);
                                } else {
                                  selectedPaymentMethods.remove(method);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade600,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: workingHours,
                  decoration: InputDecoration(
                    labelText: 'ساعات العمل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => workingHours = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: imageUrl,
                  decoration: InputDecoration(
                    labelText: 'رابط الصورة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => imageUrl = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(
                    labelText: 'وصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
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
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('متحقق منه', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text('قيد التحقق', style: GoogleFonts.cairo()),
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

                final updatedPlace = AdminPaymentPlace(
                  id: place.id,
                  name: name,
                  phoneNumber: phoneNumber,
                  location: location,
                  category: category,
                  paymentMethods: selectedPaymentMethods.toList(),
                  workingHours: workingHours,
                  description: description,
                  imageUrl: imageUrl,
                  isVerified: isVerified,
                  rating: place.rating,
                  reviewsCount: place.reviewsCount,
                );

                final success = await placesNotifier.updatePlace(updatedPlace);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تحديث المتجر بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
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

  // Confirmation dialog for deleting a place
  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, AdminPaymentPlace place) {
    final placesNotifier = ref.read(adminPaymentPlacesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'حذف متجر',
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
              'هل أنت متأكد من أنك تريد حذف هذا المتجر؟',
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
                  const Icon(Icons.storefront_rounded, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          place.location,
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
              final success = await placesNotifier.deletePlace(place.id);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف المتجر بنجاح',
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