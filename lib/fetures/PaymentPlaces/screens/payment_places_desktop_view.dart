import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/empty_state_widget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/dialogs/payment_places_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/place_detail_sidebar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/places_data_table.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/places_filter_chips.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/payment_places_shared_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPlacesDesktopView extends ConsumerWidget {
  const PaymentPlacesDesktopView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final placesStream = ref.watch(paymentPlacesStreamProvider);
    final searchQuery = ref.watch(placesSearchQueryProvider);
    final showSideBar = ref.watch(showPlaceSideBarProvider);
    final selectedPlace = ref.watch(selectedPlaceProvider);
    final currentPage = ref.watch(placesCurrentPageProvider);
    final pageSize = ref.watch(placesPageSizeProvider);
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);
    final filterMode = ref.watch(placesFilterModeProvider);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: placesStream.when(
        data: (snapshot) {
          // Apply filtering
          var filteredPlaces = _applyFiltering(snapshot.docs, ref);

          // Apply sorting
          filteredPlaces = _applySorting(filteredPlaces, sortField, sortAscending);

          // Apply pagination
          final int startIndex = (currentPage - 1) * pageSize;
          List<DocumentSnapshot> paginatedPlaces = filteredPlaces;

          if (filteredPlaces.length > pageSize) {
            final endIndex = startIndex + pageSize < filteredPlaces.length
                ? startIndex + pageSize
                : filteredPlaces.length;

            if (startIndex < filteredPlaces.length) {
              paginatedPlaces = filteredPlaces.sublist(startIndex, endIndex);
            } else {
              paginatedPlaces = [];
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      onChanged: (value) {
                        ref.read(placesSearchQueryProvider.notifier).state = value;
                        placesNotifier.setSearchQuery(value);
                      },
                      hintText: 'البحث باسم المكان أو الموقع أو التصنيف',
                    ),
                  ),
                  const SizedBox(width: 16),
                  PaymentPlacesSharedWidgets.buildSortButton(context, ref),
                ],
              ),
              const SizedBox(height: 16),
              const PlacesFilterChips(),
              const SizedBox(height: 24),
              Expanded(
                child: paginatedPlaces.isEmpty
                    ? const EmptyStateWidget()
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: PlacesDataTable(
                              places: paginatedPlaces,
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
                            PaymentPlacesSharedWidgets.buildPagination(
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
                        onEdit: () => PaymentPlacesDialogs.showEditPlaceDialog(
                            context, ref, selectedPlace),
                        onDelete: () => PaymentPlacesDialogs.showDeleteConfirmation(
                            context, ref, selectedPlace),
                      ),
                    ],
                  ],
                ),
              ),
              // Stats footer
              _buildStatsFooter(context, filteredPlaces.length, snapshot.docs.length),
            ],
          );
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
      ),
    );
  }

  List<DocumentSnapshot> _applyFiltering(
      List<DocumentSnapshot> docs, WidgetRef ref) {
    final searchQuery = ref.watch(placesSearchQueryProvider);
    final filterMode = ref.watch(placesFilterModeProvider);

    return docs.where((doc) {
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
          final categoryFilter = ref.watch(paymentPlacesProvider).categoryFilter;
          if (categoryFilter == null || categoryFilter.isEmpty) {
            return matchesSearch;
          }
          return matchesSearch &&
              place.category.toLowerCase() == categoryFilter.toLowerCase();
        case PlacesFilterMode.byLocation:
          final locationFilter = ref.watch(paymentPlacesProvider).locationFilter;
          if (locationFilter == null || locationFilter.isEmpty) {
            return matchesSearch;
          }
          return matchesSearch &&
              place.location.toLowerCase().contains(locationFilter.toLowerCase());
      }
    }).toList();
  }

  List<DocumentSnapshot> _applySorting(
      List<DocumentSnapshot> places, String sortField, bool sortAscending) {
    places.sort((a, b) {
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
    return places;
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
}