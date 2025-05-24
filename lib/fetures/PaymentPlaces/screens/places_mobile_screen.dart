import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/empty_state_widget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/dialogs/payment_places_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/place_card.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/place_detail_sidebar.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/places_filter_chips.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class PaymentPlacesMobileView extends ConsumerWidget {
  const PaymentPlacesMobileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final placesStream = ref.watch(paymentPlacesStreamProvider);
    final searchQuery = ref.watch(placesSearchQueryProvider);
    final sortField = ref.watch(placesSortFieldProvider);
    final sortAscending = ref.watch(placesSortDirectionProvider);
    final filterMode = ref.watch(placesFilterModeProvider);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: placesStream.when(
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
              const PlacesFilterChips(),
              const SizedBox(height: 24),
              Expanded(
                child: filteredPlaces.isEmpty
                    ? const EmptyStateWidget()
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
                    itemCount: filteredPlaces.length,
                    itemBuilder: (context, index) {
                      final place = PaymentPlaceModel.fromFirestore(
                          filteredPlaces[index]);
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

  // Bottom sheet for mobile place details
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
                          ? () => PaymentPlacesDialogs.showEditPlaceDialog(
                          context, ref, place)
                          : null,
                      onDelete: isAdmin
                          ? () => PaymentPlacesDialogs.showDeleteConfirmation(
                          context, ref, place)
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
}