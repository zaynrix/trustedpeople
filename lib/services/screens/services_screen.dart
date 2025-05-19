// lib/fetures/Services/screens/services_screen.dart
// lib/fetures/Services/screens/service_request_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// lib/fetures/Services/screens/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/search_bar.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/services/service_model.dart';

import '../providers/service_requests_provider.dart';
import '../widgets/service_card.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final servicesState = ref.watch(servicesProvider);
    final filteredServices = ref.watch(filteredServicesProvider);
    final categories = ref.watch(serviceCategoriesProvider);
// Add at the beginning of ServicesScreen build method
    print(
        "Building ServicesScreen with ${filteredServices.length} filtered services");
    print("Filter category: ${ref.watch(servicesProvider).categoryFilter}");
    print(
        "isActive services: ${filteredServices.where((s) => s.isActive).length}");
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        title: Text(
          "اطلب خدمتك",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        shape: isMobile
            ? null
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Side drawer for larger screens
              if (!isMobile) const AppDrawer(isPermanent: true),

              // Main content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: servicesState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _buildHeroSection(context),
                            const SizedBox(height: 24),

                            // Search and filter
                            Row(
                              children: [
                                Expanded(
                                  child: SearchField(
                                    onChanged: (value) {
                                      ref
                                          .read(servicesProvider.notifier)
                                          .setSearchQuery(value);
                                    },
                                    hintText: 'البحث في الخدمات المتوفرة...',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                categories.when(
                                  data: (categoryStrings) {
                                    final serviceCategories = categoryStrings
                                        .map(
                                            ServiceCategoryExtension.fromString)
                                        .toList();

                                    return _buildCategoryFilter(
                                        context, ref, serviceCategories);
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (error, _) => Center(
                                      child: Text(
                                          'حدث خطأ أثناء تحميل التصنيفات')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Services grid
                            if (servicesState.errorMessage != null)
                              Center(
                                child: Text(
                                  servicesState.errorMessage!,
                                  style: GoogleFonts.cairo(color: Colors.red),
                                ),
                              )
                            else if (filteredServices.isEmpty)
                              _buildEmptyState()
                            else
                              Expanded(
                                child: _buildServicesGrid(
                                  ref,
                                  context,
                                  filteredServices,
                                  isMobile,
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade200.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.design_services,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'خدمات متميزة تلبي احتياجاتك',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تصفح خدماتنا المتنوعة واطلب ما يناسبك، وسنتواصل معك في أقرب وقت!',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Scroll to services section
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.arrow_downward),
            label: Text(
              'تصفح الخدمات',
              style: GoogleFonts.cairo(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal.shade700,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    List<ServiceCategory> categories,
  ) {
    final selectedCategory = ref.watch(servicesProvider).categoryFilter;

    return PopupMenuButton<ServiceCategory?>(
      tooltip: 'فلترة حسب التصنيف',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list),
            const SizedBox(width: 8),
            Text(
              selectedCategory == null ? 'جميع التصنيفات' : selectedCategory,
              style: GoogleFonts.cairo(),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: null,
          child: Row(
            children: [
              Icon(
                Icons.all_inclusive,
                color: selectedCategory == null
                    ? Colors.teal
                    : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'جميع التصنيفات',
                style: GoogleFonts.cairo(
                  fontWeight: selectedCategory == null ? FontWeight.bold : null,
                  color: selectedCategory == null
                      ? Colors.teal
                      : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        ...categories.map((category) {
          return PopupMenuItem(
            value: category,
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: selectedCategory == category
                      ? Colors.teal
                      : Colors.grey.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  category.displayName,
                  style: GoogleFonts.cairo(
                    fontWeight:
                        selectedCategory == category ? FontWeight.bold : null,
                    color: selectedCategory == category
                        ? Colors.teal
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
      onSelected: (category) {
        ref.read(servicesProvider.notifier).setCategoryFilter(category!.name);
      },
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
      default:
        return Icons.work;
    }
  }

  Widget _buildServicesGrid(
    ref,
    BuildContext context,
    List<ServiceModel> services,
    bool isMobile,
  ) {
    int crossAxisCount;
    if (MediaQuery.of(context).size.width > 1200) {
      crossAxisCount = 4; // Large desktop screens
    } else if (MediaQuery.of(context).size.width > 900) {
      crossAxisCount = 3; // Desktop screens
    } else if (MediaQuery.of(context).size.width > 600) {
      crossAxisCount = 2; // Tablet screens
    } else {
      crossAxisCount = 1; // Mobile screens
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          onTap: () {
            ref.read(servicesProvider.notifier).selectService(service);
            context.goNamed(
              ScreensNames.serviceDetail,
              pathParameters: {'serviceId': service.id},
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لم يتم العثور على خدمات',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حاول تغيير معايير البحث أو التصفية',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceDetailScreen extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(servicesProvider);

    // Find the service by ID
    final service = servicesState.services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => servicesState.selectedService!,
    );

    if (service == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'خدمة غير موجودة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'الخدمة غير موجودة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.goNamed(ScreensNames.services);
                },
                child: Text(
                  'العودة إلى الخدمات',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          service.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image
            if (service.imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(service.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.teal.shade100,
                child: Center(
                  child: Icon(
                    _getCategoryIcon(service.category),
                    size: 120,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),

            // Service details
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service title and price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          service.title,
                          style: GoogleFonts.cairo(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category and delivery time
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(
                          _getCategoryIcon(service.category),
                          size: 16,
                          color: Colors.teal.shade700,
                        ),
                        label: Text(
                          service.category.displayName,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        backgroundColor: Colors.teal.shade50,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 0),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مدة التنفيذ: ${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
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
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional details if available
                  if (service.additionalDetails != null &&
                      service.additionalDetails!.isNotEmpty) ...[
                    Text(
                      'معلومات إضافية',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...service.additionalDetails!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${entry.key}: ',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                  ],

                  // Request button
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
              ),
            ),
          ],
        ),
      ),
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
      default:
        return Icons.work;
    }
  }
}

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceRequestScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  ConsumerState<ServiceRequestScreen> createState() =>
      _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String _errorMessage = '';

  // Form values
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest(ServiceModel service) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = '';
    });

    try {
      final request = ServiceRequestModel(
        id: '', // Will be set by Firestore
        serviceId: service.id,
        serviceName: service.title,
        clientName: _nameController.text.trim(),
        clientEmail: _emailController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        requirements: _requirementsController.text.trim(),
        status: ServiceRequestStatus.pending,
        createdAt: Timestamp.now(),
      );

      final success = await ref
          .read(serviceRequestsProvider.notifier)
          .createServiceRequest(request);

      if (success) {
        // Request submitted successfully
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // Error submitting request
        setState(() {
          _errorMessage = 'حدث خطأ أثناء إرسال الطلب. يرجى المحاولة مرة أخرى.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ: $e';
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              'تم إرسال الطلب بنجاح',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم استلام طلبك وسيتم التواصل معك قريباً.',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 8),
            Text(
              'تقوم فرق العمل لدينا بمراجعة الطلبات والرد عليها في غضون 15 دقيقة خلال ساعات العمل.',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed(ScreensNames.services);
            },
            child: Text(
              'العودة للخدمات',
              style: GoogleFonts.cairo(),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);

    // Find the service
    final service = servicesState.services.firstWhere(
      (s) => s.id == widget.serviceId,
      orElse: () => servicesState.selectedService!,
    );

    if (service == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'خدمة غير موجودة',
            style: GoogleFonts.cairo(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'الخدمة غير موجودة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.goNamed(ScreensNames.services);
                },
                child: Text(
                  'العودة إلى الخدمات',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'طلب خدمة: ${service.title}',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service info card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(service.category),
                            size: 40,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.category.displayName,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'السعر: \$${service.price.toStringAsFixed(0)}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'مدة التنفيذ: ${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form title
              Text(
                'يرجى تعبئة النموذج التالي لطلب الخدمة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Request form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        hintText: 'أدخل اسمك الكامل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'أدخل بريدك الإلكتروني',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        hintText: 'أدخل رقم هاتفك',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _requirementsController,
                      decoration: InputDecoration(
                        labelText: 'متطلبات الخدمة',
                        hintText: 'أدخل تفاصيل ومتطلبات الخدمة المطلوبة',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال متطلبات الخدمة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          _errorMessage,
                          style: GoogleFonts.cairo(
                            color: Colors.red.shade800,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitRequest(service),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'إرسال الطلب',
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                ),
              ),
            ],
          ),
        ),
      ),
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
      default:
        return Icons.work;
    }
  }
}
