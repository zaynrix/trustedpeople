import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

import '../providers/service_requests_provider.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final String serviceId;

  const ServiceRequestScreen({
    super.key,
    required this.serviceId,
  });

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
          _showSuccessDialog(service);
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

  void _showSuccessDialog(ServiceModel service) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: isMobile ? 24 : 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم إرسال الطلب بنجاح',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم استلام طلبك لخدمة "${service.title}" وسيتم التواصل معك قريباً.',
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الطلب:',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الاسم: ${_nameController.text}',
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                  Text(
                    'البريد: ${_emailController.text}',
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                  Text(
                    'الهاتف: ${_phoneController.text}',
                    style: GoogleFonts.cairo(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تقوم فرق العمل لدينا بمراجعة الطلبات والرد عليها في غضون 15 دقيقة خلال ساعات العمل.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          if (!isMobile)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.goNamed(ScreensNames.services);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    // Find the service
    final service = servicesState.services.firstWhere(
      (s) => s.id == widget.serviceId,
      orElse: () => servicesState.selectedService!,
    );

    return Scaffold(
      appBar: _buildAppBar(context, service, isMobile),
      body: isMobile
          ? _buildMobileLayout(context, service)
          : _buildWebLayout(context, service, isDesktop),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ServiceModel service, bool isMobile) {
    if (isMobile) {
      // Mobile: Traditional mobile app bar
      return AppBar(
        title: Text(
          'طلب خدمة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade600,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () =>  context.goNamed(
            ScreensNames.serviceDetail,
            pathParameters: {'serviceId': service.id},
          ),
        ),
      );
    } else {
      // Web: Clean app bar
      return AppBar(
        title: Text(
          'طلب خدمة: ${service.title}',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.teal.shade800,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade800,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>  context.goNamed(
            ScreensNames.serviceDetail,
            pathParameters: {'serviceId': service.id},
          ),
        ),
      );
    }
  }

  Widget _buildMobileLayout(BuildContext context, ServiceModel service) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileServiceCard(service),
            const SizedBox(height: 20),
            _buildMobileFormSection(service),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(
      BuildContext context, ServiceModel service, bool isDesktop) {
    final maxWidth = isDesktop ? 1000.0 : 800.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32.0 : 24.0,
            vertical: 24.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Service info (sticky)
              Expanded(
                flex: 2,
                child: _buildWebServiceInfo(service, isDesktop),
              ),
              const SizedBox(width: 32),

              // Right column: Form
              Expanded(
                flex: 3,
                child: _buildWebFormSection(service, isDesktop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileServiceCard(ServiceModel service) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(service.category),
                      size: 30,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        service.category.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '\$${service.price.toStringAsFixed(0)}',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مدة التنفيذ',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildMobileFormSection(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'يرجى تعبئة النموذج التالي لطلب الخدمة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildForm(service, true),
      ],
    );
  }

  // Web-specific widgets
  Widget _buildWebServiceInfo(ServiceModel service, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل الخدمة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),

          // Service image/icon
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: service.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildServiceIcon(service);
                      },
                    ),
                  )
                : _buildServiceIcon(service),
          ),

          const SizedBox(height: 16),

          Text(
            service.title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            service.category.displayName,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'السعر:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '\$${service.price.toStringAsFixed(0)}',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مدة التنفيذ:',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (service.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'وصف الخدمة:',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              service.description,
              style: GoogleFonts.cairo(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceIcon(ServiceModel service) {
    return Center(
      child: Icon(
        _getCategoryIcon(service.category),
        size: 50,
        color: Colors.teal.shade700,
      ),
    );
  }

  Widget _buildWebFormSection(ServiceModel service, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نموذج طلب الخدمة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'يرجى تعبئة جميع الحقول المطلوبة لمعالجة طلبك بسرعة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildForm(service, false),
        ],
      ),
    );
  }

  // Shared form widget
  Widget _buildForm(ServiceModel service, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل *',
              hintText: 'أدخل اسمك الكامل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.person_outline),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال الاسم';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),

          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني *',
              hintText: 'example@email.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
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
          SizedBox(height: isMobile ? 16 : 20),

          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف *',
              hintText: '+966 50 000 0000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.phone_outlined),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال رقم الهاتف';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 16 : 20),

          TextFormField(
            controller: _requirementsController,
            decoration: InputDecoration(
              labelText: 'متطلبات الخدمة *',
              hintText: 'اشرح بالتفصيل ما تحتاجه من هذه الخدمة...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              alignLabelWithHint: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMobile ? 12 : 16,
              ),
            ),
            maxLines: isMobile ? 4 : 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال متطلبات الخدمة';
              }
              if (value.length < 20) {
                return 'يرجى إدخال وصف أكثر تفصيلاً (على الأقل 20 حرف)';
              }
              return null;
            },
          ),
          SizedBox(height: isMobile ? 20 : 24),

          // Error message
          if (_errorMessage.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 16 : 20),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () => _submitRequest(service),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'جارٍ الإرسال...',
                          style: GoogleFonts.cairo(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'إرسال الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم الرد على طلبك خلال 15 دقيقة خلال ساعات العمل',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Extra bottom padding for mobile
          SizedBox(height: isMobile ? 32 : 16),
        ],
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
    }
  }
}
