import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Handle loading state
    if (servicesState.isLoading) {
      return Scaffold(
        appBar: _buildLoadingAppBar(context, isMobile),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Handle error state
    if (servicesState.errorMessage != null) {
      return Scaffold(
        appBar: _buildErrorAppBar(context, isMobile),
        body: _buildErrorBody(context, servicesState.errorMessage!),
      );
    }

    // Try to find the service by ID
    ServiceModel? service;
    try {
      service = servicesState.services.firstWhere(
        (s) => s.id == serviceId,
      );
    } catch (e) {
      // If service not found by ID, try selected service as fallback
      service = servicesState.selectedService;
    }

    // Handle service not found
    if (service == null) {
      return Scaffold(
        appBar: _buildErrorAppBar(context, isMobile),
        body: _buildServiceNotFoundBody(context),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context, service, isMobile),
      body: isMobile
          ? _buildMobileLayout(context, service, ref)
          : _buildWebLayout(context, service, ref, isDesktop),
    );
  }

  // Loading state app bar
  PreferredSizeWidget _buildLoadingAppBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
        title: Text(
          'تحميل...',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 2,
      );
    } else {
      return AppBar(
        title: Text(
          'تحميل الخدمة...',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade800,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade800,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
      );
    }
  }

  // Error state app bar
  PreferredSizeWidget _buildErrorAppBar(BuildContext context, bool isMobile) {
    if (isMobile) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
        title: Text(
          'خطأ',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red.shade600,
        elevation: 2,
      );
    } else {
      return AppBar(
        title: Text(
          'حدث خطأ',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade800,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade800,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
      );
    }
  }

  // Error body widget
  Widget _buildErrorBody(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل الخدمة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.goNamed(ScreensNames.services),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(
                    'العودة للخدمات',
                    style: GoogleFonts.cairo(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Trigger a reload of services
                    // You might want to add a refresh method to your provider
                    context.goNamed(ScreensNames.services);
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'إعادة المحاولة',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Service not found body widget
  Widget _buildServiceNotFoundBody(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'الخدمة غير موجودة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على الخدمة المطلوبة. قد تكون محذوفة أو غير متاحة.',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.goNamed(ScreensNames.services),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                'العودة للخدمات',
                style: GoogleFonts.cairo(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ServiceModel service, bool isMobile) {
    if (isMobile) {
      // Mobile: Traditional mobile app bar
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
        title: Text(
          service.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
      );
    } else {
      // Web: More minimal, integrated app bar
      return AppBar(
        title: Text(
          service.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade800,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade800,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed(ScreensNames.services),
        ),
      );
    }
  }

  Widget _buildMobileLayout(
      BuildContext context, ServiceModel service, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile: Full-width image
          _buildMobileImageSection(service),

          // Mobile: Content in single column
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileServiceInfo(service),
                const SizedBox(height: 20),
                _buildMobileDescription(service),
                const SizedBox(height: 20),
                if (service.additionalDetails != null &&
                    service.additionalDetails!.isNotEmpty)
                  _buildMobileAdditionalDetails(service),
                const SizedBox(height: 24),
                _buildMobileActionButton(context, service),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, ServiceModel service,
      WidgetRef ref, bool isDesktop) {
    final maxWidth = isDesktop ? 1200.0 : 900.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 24.0,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Web: Two-column layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: Image and gallery
                  Expanded(
                    flex: isDesktop ? 3 : 2,
                    child: _buildWebImageSection(service, isDesktop),
                  ),
                  const SizedBox(width: 32),

                  // Right column: Service info and actions
                  Expanded(
                    flex: isDesktop ? 2 : 3,
                    child: _buildWebServiceInfo(context, service, isDesktop),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Web: Full-width description and details
              _buildWebDescription(service, isDesktop),

              if (service.additionalDetails != null &&
                  service.additionalDetails!.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildWebAdditionalDetails(service, isDesktop),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileImageSection(ServiceModel service) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: service.imageUrl.isNotEmpty
          ? BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(service.imageUrl),
                fit: BoxFit.cover,
              ),
            )
          : BoxDecoration(
              color: Colors.teal.shade100,
            ),
      child: service.imageUrl.isEmpty
          ? Center(
              child: Icon(
                _getCategoryIcon(service.category),
                size: 80,
                color: Colors.teal.shade700,
              ),
            )
          : null,
    );
  }

  Widget _buildMobileServiceInfo(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Text(
            '\$${service.price.toStringAsFixed(0)}',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              icon: _getCategoryIcon(service.category),
              label: service.category.displayName,
              color: Colors.teal,
            ),
            _buildChip(
              icon: Icons.access_time,
              label:
                  'مدة التنفيذ: ${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileDescription(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل الخدمة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          service.description,
          style: GoogleFonts.cairo(
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAdditionalDetails(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات إضافية',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...service.additionalDetails!.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMobileActionButton(BuildContext context, ServiceModel service) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.goNamed(
                ScreensNames.serviceRequest,
                pathParameters: {'serviceId': service.id},
              );
            },
            icon: const Icon(Icons.send),
            label: Text(
              'طلب الخدمة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'سيتم الرد على طلبك خلال 15 دقيقة',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Web-specific widgets
  Widget _buildWebImageSection(ServiceModel service, bool isDesktop) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: isDesktop ? 400 : 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: service.imageUrl.isNotEmpty
                ? Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(service, isDesktop);
                    },
                  )
                : _buildPlaceholderImage(service, isDesktop),
          ),
        ),

        // Web: Image thumbnails or additional images could go here
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlaceholderImage(ServiceModel service, bool isDesktop) {
    return Container(
      color: Colors.teal.shade100,
      child: Center(
        child: Icon(
          _getCategoryIcon(service.category),
          size: isDesktop ? 120 : 80,
          color: Colors.teal.shade700,
        ),
      ),
    );
  }

  Widget _buildWebServiceInfo(
      BuildContext context, ServiceModel service, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title,
          style: GoogleFonts.cairo(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),

        const SizedBox(height: 16),

        // Web: Price in a card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سعر الخدمة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${service.price.toStringAsFixed(0)}',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Web: Service metadata
        _buildWebMetadata(service),

        const SizedBox(height: 24),

        // Web: Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.goNamed(
                ScreensNames.serviceRequest,
                pathParameters: {'serviceId': service.id},
              );
            },
            icon: const Icon(Icons.send),
            label: Text(
              'طلب الخدمة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            'سيتم الرد على طلبك خلال 15 دقيقة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebMetadata(ServiceModel service) {
    return Column(
      children: [
        // _buildMetadataRow(
        //   icon: _getCategoryIcon(service.category),
        //   label: 'التصنيف',
        //   value: service.category.displayName,
        // ),
        const SizedBox(height: 12),
        _buildMetadataRow(
          icon: Icons.access_time,
          label: 'مدة التنفيذ',
          value:
              '${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
        ),
      ],
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWebDescription(ServiceModel service, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الخدمة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            service.description,
            style: GoogleFonts.cairo(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebAdditionalDetails(ServiceModel service, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات إضافية',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: service.additionalDetails!.entries.map((entry) {
              return Container(
                constraints: BoxConstraints(
                  minWidth: isDesktop ? 300 : 250,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value.toString(),
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildChip({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: color.shade700,
      ),
      label: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 14,
          color: color.shade700,
        ),
      ),
      backgroundColor: color.shade50,
    );
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
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
}
