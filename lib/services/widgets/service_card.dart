// lib/fetures/Services/widgets/service_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/services/service_model.dart';

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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder
            SizedBox(
              height: 140,
              width: double.infinity,
              child: service.imageUrl.isNotEmpty
                  ? Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.teal.shade100,
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(service.category.displayName),
                          size: 60,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.category.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      service.title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating and time
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        // Text(
                        //   service.rating.toString(),
                        //   style: GoogleFonts.cairo(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        // const SizedBox(width: 4),
                        // Text(
                        //   '(${service.reviewsCount})',
                        //   style: GoogleFonts.cairo(
                        //     color: Colors.grey,
                        //     fontSize: 12,
                        //   ),
                        // ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.timer,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.deliveryTimeInDays} د',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price and order button
                    Row(
                      children: [
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'طلب',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'برمجة':
        return Icons.code;
      case 'تصميم':
        return Icons.design_services;
      case 'تسويق':
        return Icons.campaign;
      case 'كتابة':
        return Icons.edit_note;
      case 'ترجمة':
        return Icons.translate;
      case 'استشارات':
        return Icons.support_agent;
      case 'فيديو':
        return Icons.videocam;
      case 'صوت':
        return Icons.mic;
      default:
        return Icons.miscellaneous_services;
    }
  }
}

// lib/fetures/Services/widgets/service_category_card.dart

class ServiceCategoryCard extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ServiceCategoryCard({
    Key? key,
    required this.category,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/fetures/Services/widgets/featured_service_card.dart

class FeaturedServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const FeaturedServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Background image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: service.imageUrl.isNotEmpty
                  ? Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.teal.shade100,
                      child: Center(
                        child: Icon(
                          _getCategoryIcon(service.category.name),
                          size: 80,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
            ),

            // Gradient overlay
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'خدمة مميزة',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      service.title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Category
                    Text(
                      service.category.displayName,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price and rating
                    Row(
                      children: [
                        Text(
                          '\$${service.price.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "service.rating.toString()",
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'برمجة':
        return Icons.code;
      case 'تصميم':
        return Icons.design_services;
      case 'تسويق':
        return Icons.campaign;
      case 'كتابة':
        return Icons.edit_note;
      case 'ترجمة':
        return Icons.translate;
      case 'استشارات':
        return Icons.support_agent;
      case 'فيديو':
        return Icons.videocam;
      case 'صوت':
        return Icons.mic;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
