// lib/features/services/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = service.isActive;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isActive ? onTap : null,
        child: Stack(
          children: [
            // Card content - no height constraints for natural sizing
            Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize.min, // KEY: Let content determine size
                children: [
                  // Service icon and category
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(service.category.toString()),
                        color: Colors.teal.shade600,
                        size: isMobile ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCategoryDisplayName(service.category.toString()),
                          style: GoogleFonts.cairo(
                            color: Colors.teal.shade600,
                            fontWeight: FontWeight.w500,
                            fontSize: isMobile ? 11 : 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 10 : 12),

                  // Service title
                  Text(
                    service.title,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isMobile ? 8 : 10),

                  // Service description - adaptive height
                  Text(
                    service.description,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 12 : 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: _getDescriptionMaxLines(screenWidth),
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Price and order button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Price section
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'السعر',
                              style: GoogleFonts.cairo(
                                fontSize: isMobile ? 10 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${service.price} \$',
                              style: GoogleFonts.cairo(
                                fontSize: isMobile ? 13 : 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Order button
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: isActive ? onTap : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 12,
                              vertical: isMobile ? 6 : 8,
                            ),
                            minimumSize: Size(0, isMobile ? 32 : 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 1,
                          ),
                          child: FittedBox(
                            child: Text(
                              'اطلب الآن',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 11 : 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Inactive overlay
            if (!isActive)
              Positioned.fill(
                child: Container(
                  color: Colors.grey.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      'غير متاح حالياً',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Adaptive description max lines based on screen size
  int _getDescriptionMaxLines(double screenWidth) {
    if (screenWidth < 600) {
      return 2; // Mobile
    } else if (screenWidth < 900) {
      return 3; // Small tablet
    } else if (screenWidth < 1200) {
      return 3; // Large tablet
    } else {
      return 4; // Desktop
    }
  }

  IconData _getCategoryIcon(String category) {
    final serviceCategory = ServiceCategoryExtension.fromString(category);

    switch (serviceCategory) {
      case ServiceCategory.webDevelopment:
        return Icons.web;
      case ServiceCategory.mobileDevelopment:
        return Icons.phone_android;
      case ServiceCategory.graphicDesign:
        return Icons.brush;
      case ServiceCategory.marketing:
        return Icons.trending_up;
      case ServiceCategory.writing:
        return Icons.description;
      case ServiceCategory.translation:
        return Icons.translate;
      case ServiceCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryDisplayName(String category) {
    final serviceCategory = ServiceCategoryExtension.fromString(category);
    return serviceCategory.displayName ?? category;
  }
}
