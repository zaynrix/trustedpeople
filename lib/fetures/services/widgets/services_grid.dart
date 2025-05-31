// lib/features/services/widgets/services_grid.dart
import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/fetures/services/widgets/service_card.dart';

class ServicesGrid extends StatelessWidget {
  final List<ServiceModel> services;
  final bool isMobile;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final Function(ServiceModel) onServiceTap;

  const ServicesGrid({
    Key? key,
    required this.services,
    required this.isMobile,
    this.crossAxisCount,
    this.childAspectRatio,
    required this.onServiceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int gridCrossAxisCount;
    double gridChildAspectRatio;

    if (crossAxisCount != null && childAspectRatio != null) {
      gridCrossAxisCount = crossAxisCount!;
      gridChildAspectRatio = childAspectRatio!;
    } else {
      final screenWidth = MediaQuery.of(context).size.width;

      if (screenWidth > 1200) {
        gridCrossAxisCount = 4;
        gridChildAspectRatio = 0.75; // Reduced from 1.1
      } else if (screenWidth > 900) {
        gridCrossAxisCount = 3;
        gridChildAspectRatio = 0.8; // Reduced from 1
      } else if (screenWidth > 700) {
        gridCrossAxisCount = 2;
        gridChildAspectRatio = 0.85; // Reduced from 1
      } else if (screenWidth > 600) {
        gridCrossAxisCount = 2;
        gridChildAspectRatio = 0.9; // Reduced from 1.2
      } else {
        gridCrossAxisCount = 1;
        gridChildAspectRatio = 1.2; // Reduced from 1.5
      }
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridCrossAxisCount,
        childAspectRatio: gridChildAspectRatio,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = services[index];
          return ServiceCard(
            service: service,
            onTap: () => onServiceTap(service),
          );
        },
        childCount: services.length,
      ),
    );
  }
}

// Alternative approach using SliverMasonryGrid for better content-based sizing
// Uncomment and use this if you want cards to size based on their content
/*
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ServicesGrid extends StatelessWidget {
  // ... same properties

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;

    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 900) {
      crossAxisCount = 3;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return SliverMasonryGrid.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 12 : 16,
      mainAxisSpacing: isMobile ? 12 : 16,
      childCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          onTap: () => onServiceTap(service),
        );
      },
    );
  }
}
*/
