import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/core/widgets/custom_filter_chip.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/trusted/dialogs/user_dialogs.dart';

class FilterChipsRow extends ConsumerWidget {
  final Color primaryColor;
  final VoidCallback onLocationFilter;

  const FilterChipsRow({
    super.key,
    required this.primaryColor,
    required this.onLocationFilter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              if (selected) LocationFilterDialog.show(context, ref);
            },
          ),
        ],
      ),
    );
  }
}