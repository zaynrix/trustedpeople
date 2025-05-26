// lib/fetures/admin/screens/admin_services_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/services/service_model.dart';

import '../../../fetures/services/providers/service_provider.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final servicesStream = ref.watch(servicesStreamProvider);

    // Add responsive layout detection
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(
            'يجب أن تكون مشرفاً للوصول إلى هذه الصفحة',
            style: GoogleFonts.cairo(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isSmallScreen,
        title: Text(
          'إدارة الخدمات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      drawer: isSmallScreen ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة الخدمات',
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddServiceDialog(context, ref),
                        icon: const Icon(Icons.add),
                        label: Text(
                          'إضافة خدمة جديدة',
                          style: GoogleFonts.cairo(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Services list
                  Expanded(
                    child: servicesStream.when(
                      data: (services) {
                        if (services.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد خدمات حالياً',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'قم بإضافة خدمات جديدة بالضغط على زر "إضافة خدمة جديدة"',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: services.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return _buildServiceItem(context, ref, service);
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Text(
                          'حدث خطأ: $error',
                          style: GoogleFonts.cairo(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: isMobile
            ? _buildMobileLayout(context, ref, service)
            : _buildDesktopLayout(context, ref, service),
      ),
    );
  }

// Mobile layout - stacked vertically for better space usage
  Widget _buildMobileLayout(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Image + Title + Actions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service icon or image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: service.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        service.imageUrl,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                      ),
                    )
                  : Icon(
                      _getCategoryIcon(service.category.name),
                      size: 25,
                      color: Colors.teal,
                    ),
            ),
            const SizedBox(width: 12),

            // Title (expanded to take available space)
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
                ],
              ),
            ),

            // Actions (always visible)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      _showEditServiceDialog(context, ref, service),
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'تعديل',
                  color: Colors.blue,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  onPressed: () =>
                      _showDeleteConfirmation(context, ref, service),
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'حذف',
                  color: Colors.red,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Service details - stacked vertically
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Price row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    service.category.displayName,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${service.price.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rating and Order count row
            // Row(
            //   children: [
            //     const Icon(Icons.star, color: Colors.amber, size: 14),
            //     const SizedBox(width: 4),
            //     Text(
            //       '${service.r}',
            //       style: GoogleFonts.cairo(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 12,
            //       ),
            //     ),
            //     const SizedBox(width: 16),
            //     const Icon(Icons.shopping_bag, color: Colors.blue, size: 14),
            //     const SizedBox(width: 4),
            //     Text(
            //       '${service.orderCount}',
            //       style: GoogleFonts.cairo(
            //         fontSize: 12,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ],
    );
  }

// Desktop layout - original horizontal layout with Wrap to prevent overflow
  Widget _buildDesktopLayout(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Service icon or image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: service.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                )
              : Icon(
                  _getCategoryIcon(service.category.name),
                  size: 30,
                  color: Colors.teal,
                ),
        ),
        const SizedBox(width: 16),

        // Service info
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Fixed the overflow with Wrap
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      service.category.displayName,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Text(
                    '\$${service.price.toStringAsFixed(2)}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     const Icon(Icons.star, color: Colors.amber, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '${service.rating}',
                  //       style: GoogleFonts.cairo(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     const Icon(Icons.shopping_bag, color: Colors.blue, size: 16),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '${service.orderCount}',
                  //       style: GoogleFonts.cairo(),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            IconButton(
              onPressed: () => _showEditServiceDialog(context, ref, service),
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل',
              color: Colors.blue,
            ),
            // Delete button
            IconButton(
              onPressed: () => _showDeleteConfirmation(context, ref, service),
              icon: const Icon(Icons.delete),
              tooltip: 'حذف',
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final timeController = TextEditingController();
    final imageUrlController = TextEditingController();
    bool isLoading = false;

    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_circle, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'إضافة خدمة جديدة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الخدمة',
                      hintText: 'أدخل عنوان الخدمة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال عنوان الخدمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'وصف الخدمة',
                      hintText: 'أدخل وصف الخدمة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال وصف الخدمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'التصنيف',
                      hintText: 'مثال: برمجة، تسويق، تصميم',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال التصنيف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      hintText: 'أدخل السعر بالدولار',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'يرجى إدخال سعر صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'وقت التنفيذ (بالدقائق)',
                      hintText: 'مثال: 30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال وقت التنفيذ';
                      }
                      try {
                        int.parse(value);
                      } catch (e) {
                        return 'يرجى إدخال وقت صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'رابط الصورة (اختياري)',
                      hintText: 'أدخل رابط صورة الخدمة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        // Create new service
                        final service = ServiceModel(
                          isActive: true,
                          deliveryTimeInDays: 2,
                          additionalDetails: {"yahy": "sdsad"},
                          id: '',
                          title: titleController.text,
                          description: descriptionController.text,
                          category: ServiceCategory.graphicDesign,
                          price: double.parse(priceController.text),
                          // estimatedTimeMinutes: int.parse(timeController.text),
                          imageUrl: imageUrlController.text,
                          // status: ServiceStatus.active,
                          createdAt: Timestamp.fromDate(DateTime.now()),
                        );

                        // Add service
                        final success = await notifier.addService(service);
                        await ref
                            .read(servicesProvider.notifier)
                            .loadServices();

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تمت إضافة الخدمة بنجاح',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'حدث خطأ أثناء إضافة الخدمة',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'إضافة',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditServiceDialog(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: service.title);
    final descriptionController =
        TextEditingController(text: service.description);
    final categoryController =
        TextEditingController(text: service.category.displayName);
    final priceController =
        TextEditingController(text: service.price.toString());
    final timeController =
        TextEditingController(text: service.createdAt.toString());
    final imageUrlController = TextEditingController(text: service.imageUrl);
    bool isLoading = false;

    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'تعديل الخدمة',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الخدمة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال عنوان الخدمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'وصف الخدمة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال وصف الخدمة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'التصنيف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال التصنيف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'يرجى إدخال سعر صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'وقت التنفيذ (بالدقائق)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال وقت التنفيذ';
                      }
                      try {
                        int.parse(value);
                      } catch (e) {
                        return 'يرجى إدخال وقت صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: InputDecoration(
                      labelText: 'رابط الصورة (اختياري)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        // Update service
                        final updatedService = service.copyWith(
                          title: titleController.text,
                          description: descriptionController.text,
                          category: categoryController.text,
                          price: double.parse(priceController.text),
                          estimatedTimeMinutes: int.parse(timeController.text),
                          imageUrl: imageUrlController.text,
                          updatedAt: DateTime.now(),
                        );

                        // Update service
                        final success =
                            await notifier.updateService(updatedService);

                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم تحديث الخدمة بنجاح',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'حدث خطأ أثناء تحديث الخدمة',
                                style: GoogleFonts.cairo(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'تحديث',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final notifier = ref.read(servicesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'تأكيد الحذف',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف هذه الخدمة؟ هذا الإجراء لا يمكن التراجع عنه.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Delete service
              final success = await notifier.deleteService(service.id);

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف الخدمة بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'حدث خطأ أثناء حذف الخدمة',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
