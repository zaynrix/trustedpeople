// lib/features/services/widgets/service_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

class ServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceTile({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = service.isActive;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? onTap : null,
          child: Stack(
            children: [
              // Tile content with horizontal layout
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Category icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(service.category.toString()),
                          color: Colors.teal.shade600,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Middle: Title, description, and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category as a small chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getCategoryDisplayName(service.category.toString()),
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Title
                          Text(
                            service.title,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Description
                          Text(
                            service.description,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Price
                          Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.teal,
                              ),
                              Text(
                                '${service.price}',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right side: Action button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        onPressed: isActive ? onTap : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(40, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
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
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
      default:
        return Icons.category;
    }
  }

  String _getCategoryDisplayName(String category) {
    final serviceCategory = ServiceCategoryExtension.fromString(category);
    return serviceCategory?.displayName ?? category;
  }
}