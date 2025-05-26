import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/dialogs/payment_places_dialogs.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/dialogs/places_category_filter_dialog.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';

class PlacesFilterChips extends ConsumerWidget {
  const PlacesFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterMode = ref.watch(placesFilterModeProvider);
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
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
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
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
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب التصنيف',
            icon: Icons.category_rounded,
            selected: filterMode == PlacesFilterMode.category,
            onSelected: (selected) {
              if (selected) {
                showCategoryFilterDialog(context, ref);
              }
            },
          ),
          const SizedBox(width: 8),
          CustomFilterChip(
            primaryColor: Colors.blue.shade600,
            label: 'حسب الموقع',
            icon: Icons.location_on_rounded,
            selected: filterMode == PlacesFilterMode.byLocation,
            onSelected: (selected) {
              if (selected) {
                PaymentPlacesDialogs.showLocationFilterDialog(context, ref);
              }
            },
          ),
        ],
      ),
    );
  }
}
