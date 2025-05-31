import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'layouts/desktop_services_layout.dart';
import 'layouts/mobile_services_layout.dart';
import 'layouts/tablet_services_layout.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Debug print
    debugPrint("Current screen width: $screenWidth");

    // Choose the appropriate layout based on screen width
    if (screenWidth >= 1200) {
      return const DesktopServicesLayout();
    } else if (screenWidth >= 768) {
      return const TabletServicesLayout();
    } else {
      return const MobileServicesScreen();
    }
  }
}
