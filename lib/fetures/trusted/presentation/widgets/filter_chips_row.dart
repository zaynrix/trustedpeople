import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/app/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/fetures/trusted/presentation/dialogs/location_filter_dialog.dart';

import '../../../Home/providers/home_notifier.dart';

class FilterChipsRow extends StatelessWidget {
  final Color primaryColor;
  final VoidCallback? onFilterChanged;

  const FilterChipsRow({
    Key? key,
    required this.primaryColor,
    this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final filterMode = ref.watch(filterModeProvider);
        final homeNotifier = ref.read(homeProvider.notifier);
        final locations = ref.watch(locationsProvider);


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
                  if (selected) {
                    homeNotifier.setFilterMode(FilterMode.all);
                  }
                },
              ),
              const SizedBox(width: 8),
              CustomFilterChip(
                primaryColor: primaryColor,
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
                primaryColor: primaryColor,
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
                primaryColor: primaryColor,
                label: 'حسب الموقع',
                icon: Icons.location_on_rounded,
                selected: filterMode == FilterMode.byLocation,
                onSelected: (selected) {
                  if (selected) {
                    showLocationFilterDialog(context, ref);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
