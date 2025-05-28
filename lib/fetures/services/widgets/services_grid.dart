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
        debugPrint("Grid using screen width: $screenWidth");
        gridCrossAxisCount = 4;
        gridChildAspectRatio = 1.2;
      } else if (screenWidth > 900) {
        debugPrint("Grid using screen width: $screenWidth");
        gridCrossAxisCount = 3;
        gridChildAspectRatio = 1;
      } else if (screenWidth > 700) {
        gridCrossAxisCount = 2;
        gridChildAspectRatio = 1;
      } else if (screenWidth > 600) {
        debugPrint("Grid using screen width: $screenWidth");
        gridCrossAxisCount = 2;
        gridChildAspectRatio = 1.2;
      } else {
        debugPrint("Grid using screen width: $screenWidth");
        gridCrossAxisCount = 1;
        gridChildAspectRatio = 1.5;
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
