import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/place_card.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/place_detail_sidebar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/places_data_table.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class PaymentPlacesScreen extends ConsumerWidget {
  const PaymentPlacesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesStream = ref.watch(paymentPlacesStreamProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 768,
        title: Text(
          "أماكن تقبل الدفع البنكي",
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
          return Expanded(
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
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.blue.shade600,
              onPressed: () => _showAddPlaceDialog(context, ref),
              tooltip: 'إضافة متجر جديد',
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
    final searchQuery = ref.watch(placesSearchQueryProvider);
    final showSideBar = ref.watch(showPlaceSideBarProvider);
    final selectedPlace = ref.watch(selectedPlaceProvider);
    final currentPage = ref.watch(placesCurrentPageProvider);
    final pageSize = ref.watch(placesPageSizeProvider);
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);
    final filterMode = ref.watch(placesFilterModeProvider);

    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final placesStream = ref.watch(paymentPlacesStreamProvider);

    // Error handling
    final errorMessage = ref.watch(placesErrorMessageProvider);
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
      data: (snapshot) {
        // Apply filtering
        var filteredPlaces = snapshot.docs.where((doc) {
          final place = PaymentPlaceModel.fromFirestore(doc);
          final query = searchQuery.toLowerCase();

          // Search filter
          bool matchesSearch = query.isEmpty ||
              place.name.toLowerCase().contains(query) ||
              place.phoneNumber.contains(query) ||
              place.location.toLowerCase().contains(query) ||
              place.category.toLowerCase().contains(query);

          // Additional filters
          switch (filterMode) {
            case PlacesFilterMode.all:
              return matchesSearch;
            case PlacesFilterMode.highRated:
              return matchesSearch && place.rating >= 4.0;
            case PlacesFilterMode.category:
              final categoryFilter =
                  ref.watch(paymentPlacesProvider).categoryFilter;
              if (categoryFilter == null || categoryFilter.isEmpty) {
                return matchesSearch;
              }
              return matchesSearch &&
                  place.category.toLowerCase() == categoryFilter.toLowerCase();
            case PlacesFilterMode.byLocation:
              final locationFilter =
                  ref.watch(paymentPlacesProvider).locationFilter;
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
          final placeA = PaymentPlaceModel.fromFirestore(a);
          final placeB = PaymentPlaceModel.fromFirestore(b);

          switch (sortField) {
            case 'name':
              return sortAscending
                  ? placeA.name.compareTo(placeB.name)
                  : placeB.name.compareTo(placeA.name);
            case 'category':
              return sortAscending
                  ? placeA.category.compareTo(placeB.category)
                  : placeB.category.compareTo(placeA.category);
            case 'location':
              return sortAscending
                  ? placeA.location.compareTo(placeB.location)
                  : placeB.location.compareTo(placeA.location);
            case 'phoneNumber':
              return sortAscending
                  ? placeA.phoneNumber.compareTo(placeB.phoneNumber)
                  : placeB.phoneNumber.compareTo(placeA.phoneNumber);
            case 'rating':
              return sortAscending
                  ? placeA.rating.compareTo(placeB.rating)
                  : placeB.rating.compareTo(placeA.rating);
            default:
              return sortAscending
                  ? placeA.name.compareTo(placeB.name)
                  : placeB.name.compareTo(placeA.name);
          }
        });

        // Apply pagination (except for mobile)
        final int startIndex = (currentPage - 1) * pageSize;
        List<DocumentSnapshot> paginatedPlaces = filteredPlaces;

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
                  ref.read(placesSearchQueryProvider.notifier).state = value;
                  placesNotifier.setSearchQuery(value);
                },
                hintText: 'البحث باسم المكان أو الموقع أو التصنيف',
              ),
              const SizedBox(height: 16),
              _buildFilterChips(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: displayedPlaces.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Refresh the data
                          ref.refresh(paymentPlacesStreamProvider);
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
                            final place = PaymentPlaceModel.fromFirestore(
                                displayedPlaces[index]);
                            return PlaceCard(
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
                        ref.read(placesSearchQueryProvider.notifier).state =
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
                                      final place =
                                          PaymentPlaceModel.fromFirestore(
                                              displayedPlaces[index]);
                                      return PlaceCard(
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
                            PlaceDetailSidebar(
                              place: selectedPlace,
                              onClose: () {
                                placesNotifier.closeBar();
                              },
                              onEdit: () => _showEditPlaceDialog(
                                  context, ref, selectedPlace),
                              onDelete: () => _showDeleteConfirmation(
                                  context, ref, selectedPlace),
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
                        ref.read(placesSearchQueryProvider.notifier).state =
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
                                  child: PlacesDataTable(
                                    places: displayedPlaces,
                                    onSort: (field, ascending) {
                                      placesNotifier.setSort(field,
                                          ascending: ascending);
                                    },
                                    onPlaceTap: (place) {
                                      placesNotifier.selectPlace(place);
                                    },
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
                            PlaceDetailSidebar(
                              place: selectedPlace,
                              onClose: () {
                                placesNotifier.closeBar();
                              },
                              onEdit: () => _showEditPlaceDialog(
                                  context, ref, selectedPlace),
                              onDelete: () => _showDeleteConfirmation(
                                  context, ref, selectedPlace),
                            ),
                          ],
                        ],
                      ),
              ),
              // Stats footer
              if (!isMobile)
                _buildStatsFooter(
                    context, filteredPlaces.length, snapshot.docs.length),
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
                ref.refresh(paymentPlacesStreamProvider);
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
    final filterMode = ref.watch(placesFilterModeProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final categories = ref.watch(placesCategoriesProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'الكل',
            icon: Icons.all_inclusive,
            selected: filterMode == PlacesFilterMode.all,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(PlacesFilterMode.all);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'التقييم العالي',
            icon: Icons.star_rounded,
            selected: filterMode == PlacesFilterMode.highRated,
            onSelected: (selected) {
              if (selected) {
                placesNotifier.setFilterMode(PlacesFilterMode.highRated);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'حسب التصنيف',
            icon: Icons.category_rounded,
            selected: filterMode == PlacesFilterMode.category,
            onSelected: (selected) {
              if (selected) {
                _showCategoryFilterDialog(context, ref);
              }
            },
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context: context,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == PlacesFilterMode.byLocation,
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
    return FilterChip(
      label: Row(
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
      selected: selected,
      onSelected: onSelected,
      selectedColor: Colors.blue.shade600,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.blue.shade600 : Colors.grey.shade300,
        ),
      ),
    );
  }

  // Sort button with dropdown menu
  Widget _buildSortButton(BuildContext context, WidgetRef ref) {
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

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
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);

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
    final currentPage = ref.watch(placesCurrentPageProvider);
    final pageSize = ref.watch(placesPageSizeProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
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
      BuildContext context, WidgetRef ref, PaymentPlaceModel place) {
    final isAdmin = ref.watch(isAdminProvider);

    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

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
                    child: PlaceDetailSidebar(
                      place: place,
                      onClose: () {
                        Navigator.pop(context);
                        placesNotifier.closeBar();
                      },
                      onEdit: isAdmin
                          ? () => _showEditPlaceDialog(context, ref, place)
                          : null,
                      onDelete: isAdmin
                          ? () => _showDeleteConfirmation(context, ref, place)
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
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final categories = ref.watch(placesCategoriesProvider);

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
              placesNotifier.setFilterMode(PlacesFilterMode.all);
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
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final locations = ref.watch(placesLocationsProvider);

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
              placesNotifier.setFilterMode(PlacesFilterMode.all);
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
                title: 'التفاصيل',
                description:
                    'انقر على "المزيد" أو على بطاقة المكان لعرض جميع التفاصيل',
                icon: Icons.info_outline,
              ),
              const Divider(),
              _buildHelpItem(
                title: 'طرق الدفع',
                description: 'تظهر طرق الدفع المقبولة لكل متجر بألوان مختلفة',
                icon: Icons.payment,
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
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            _buildExportOption(
              context,
              title: 'CSV',
              icon: Icons.description,
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            _buildExportOption(
              context,
              title: 'PDF',
              icon: Icons.picture_as_pdf,
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
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
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

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

    final categoryController = TextEditingController();

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
                  controller: categoryController,
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

                final place = PaymentPlaceModel(
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
      BuildContext context, WidgetRef ref, PaymentPlaceModel place) {
    final formKey = GlobalKey<FormState>();
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

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

                final updatedPlace = PaymentPlaceModel(
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
      BuildContext context, WidgetRef ref, PaymentPlaceModel place) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

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
