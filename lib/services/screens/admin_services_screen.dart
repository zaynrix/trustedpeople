// lib/fetures/Services/screens/admin_services_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';
import 'package:trustedtallentsvalley/services/providers/service_provider.dart';
import 'package:trustedtallentsvalley/services/providers/service_requests_provider.dart'
    as srp;
import 'package:trustedtallentsvalley/services/service_model.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final servicesStream = ref.watch(allServicesStreamProvider);

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'غير مصرح بالوصول',
            style: GoogleFonts.cairo(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'غير مصرح لك بالوصول إلى هذه الصفحة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
          'ssssإدارة الخدمات',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 16),
            Expanded(
              child: servicesStream.when(
                data: (services) => _buildServicesList(context, ref, services),
                loading: () => const Center(child: CircularProgressIndicator()),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context, ref),
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.design_services,
                size: 28,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إدارة خدمات ترست فالي',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  Text(
                    'إضافة وتعديل وحذف الخدمات المعروضة للمستخدمين',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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

  Widget _buildServicesList(
    BuildContext context,
    WidgetRef ref,
    List<ServiceModel> services,
  ) {
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
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
              'اضغط على + لإضافة خدمة جديدة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: service.isActive
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade50,
              child: Icon(
                _getCategoryIcon(service.category),
                color: Colors.teal.shade700,
              ),
            ),
            title: Text(
              service.title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  service.category.displayName,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${service.price.toStringAsFixed(0)}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: service.isActive
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service.isActive ? 'نشط' : 'غير نشط',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: service.isActive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      _showEditServiceDialog(context, ref, service),
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _showDeleteConfirmation(context, ref, service),
                  tooltip: 'حذف',
                ),
              ],
            ),
            onTap: () => _showServiceDetailsDialog(context, service),
          ),
        );
      },
    );
  }

  void _showServiceDetailsDialog(BuildContext context, ServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          service.title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and status
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
                        fontSize: 12,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    backgroundColor: Colors.teal.shade50,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: Icon(
                      service.isActive ? Icons.check_circle : Icons.cancel,
                      size: 16,
                      color: service.isActive ? Colors.green : Colors.red,
                    ),
                    label: Text(
                      service.isActive ? 'نشط' : 'غير نشط',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: service.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    backgroundColor: service.isActive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price and delivery time
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      label: 'السعر',
                      value: '\$${service.price.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      label: 'مدة التنفيذ',
                      value:
                          '${service.deliveryTimeInDays} ${service.deliveryTimeInDays > 1 ? 'أيام' : 'يوم'}',
                      icon: Icons.access_time,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'الوصف:',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service.description,
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 16),

              // Additional details
              if (service.additionalDetails != null &&
                  service.additionalDetails!.isNotEmpty) ...[
                Text(
                  'تفاصيل إضافية:',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                ...service.additionalDetails!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${entry.key}: ',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: GoogleFonts.cairo(),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],

              // Created at
              Text(
                'تاريخ الإنشاء: ${_formatTimestamp(service.createdAt)}',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
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

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: color.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    final deliveryTimeController = TextEditingController(text: '1');
    var isActive = true;
    var selectedCategory = ServiceCategory.other;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: Colors.teal.shade600),
            const SizedBox(width: 8),
            Text(
              'إضافة خدمة جديدة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'السعر',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل السعر';
                          }
                          if (double.tryParse(value) == null) {
                            return 'أدخل رقماً صحيحاً';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: deliveryTimeController,
                        decoration: InputDecoration(
                          labelText: 'مدة التنفيذ (أيام)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل المدة';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 1) {
                            return 'أدخل رقماً صحيحاً';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التصنيف:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ServiceCategory.values.map((category) {
                          return ChoiceChip(
                            label: Text(
                              category.displayName,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: selectedCategory == category
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            },
                            selectedColor: Colors.teal.shade600,
                            backgroundColor: Colors.grey.shade100,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'الحالة:',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                isActive = value;
                              });
                            },
                            activeColor: Colors.teal.shade600,
                          ),
                          Text(
                            isActive ? 'نشط' : 'غير نشط',
                            style: GoogleFonts.cairo(),
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
              if (formKey.currentState!.validate()) {
                final newService = ServiceModel(
                  id: '',
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  category: selectedCategory,
                  imageUrl: imageUrlController.text.trim(),
                  isActive: isActive,
                  deliveryTimeInDays:
                      int.parse(deliveryTimeController.text.trim()),
                  createdAt: Timestamp.now(),
                );

                final success = await ref
                    .read(servicesProvider.notifier)
                    .addService(newService);

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
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
            ),
            child: Text(
              'إضافة',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showEditServiceDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceModel service,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: service.title);
    final descriptionController =
        TextEditingController(text: service.description);
    final priceController =
        TextEditingController(text: service.price.toString());
    final imageUrlController = TextEditingController(text: service.imageUrl);
    final deliveryTimeController =
        TextEditingController(text: service.deliveryTimeInDays.toString());
    var isActive = service.isActive;
    var selectedCategory = service.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'تعديل الخدمة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'السعر',
                          prefixText: '\$ ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل السعر';
                          }
                          if (double.tryParse(value) == null) {
                            return 'أدخل رقماً صحيحاً';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: deliveryTimeController,
                        decoration: InputDecoration(
                          labelText: 'مدة التنفيذ (أيام)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'أدخل المدة';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 1) {
                            return 'أدخل رقماً صحيحاً';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التصنيف:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ServiceCategory.values.map((category) {
                          return ChoiceChip(
                            label: Text(
                              category.displayName,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: selectedCategory == category
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              }
                            },
                            selectedColor: Colors.teal.shade600,
                            backgroundColor: Colors.grey.shade100,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'الحالة:',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Switch(
                            value: isActive,
                            onChanged: (value) {
                              setState(() {
                                isActive = value;
                              });
                            },
                            activeColor: Colors.teal.shade600,
                          ),
                          Text(
                            isActive ? 'نشط' : 'غير نشط',
                            style: GoogleFonts.cairo(),
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
              if (formKey.currentState!.validate()) {
                final updatedService = ServiceModel(
                  id: service.id,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  price: double.parse(priceController.text.trim()),
                  category: selectedCategory,
                  imageUrl: imageUrlController.text.trim(),
                  isActive: isActive,
                  deliveryTimeInDays:
                      int.parse(deliveryTimeController.text.trim()),
                  createdAt: service.createdAt,
                  additionalDetails: service.additionalDetails,
                );

                final success = await ref
                    .read(servicesProvider.notifier)
                    .updateService(updatedService);

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
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
            ),
            child: Text(
              'تحديث',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    ServiceModel service,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'حذف الخدمة',
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
              'هل أنت متأكد من حذف هذه الخدمة؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(service.category),
                    color: Colors.teal.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
            ),
            const SizedBox(height: 16),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه!',
              style: GoogleFonts.cairo(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
              final success = await ref
                  .read(servicesProvider.notifier)
                  .deleteService(service.id);

              if (success && context.mounted) {
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class AdminServiceRequestsScreen extends ConsumerWidget {
  const AdminServiceRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final pendingRequests = ref.watch(srp.pendingServiceRequestsProvider);
    final inProgressRequests = ref.watch(srp.inProgressServiceRequestsProvider);
    final allRequests = ref.watch(srp.allServiceRequestsProvider);
    // final showNewRequestsBadge =
    //     ref.watch(srp.serviceRequestsProvider).showNewRequestsBadge;
    //
    // // When this screen is opened, clear the badge
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (showNewRequestsBadge) {
    //     ref.read(srp.serviceRequestsProvider.notifier).clearSelectedRequest();
    //   }
    // });

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'غير مصرح بالوصول',
            style: GoogleFonts.cairo(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'غير مصرح لك بالوصول إلى هذه الصفحة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إدارة طلبات الخدمات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal.shade700,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.pending_actions),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      'قيد الانتظار',
                      style: GoogleFonts.cairo(),
                    ),
                    if (pendingRequests.hasValue &&
                        pendingRequests.value!.isNotEmpty)
                      Positioned(
                        top: -8,
                        right: -24,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            pendingRequests.value!.length.toString(),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Tab(
                icon: const Icon(Icons.work),
                child: Text(
                  'قيد التنفيذ',
                  style: GoogleFonts.cairo(),
                ),
              ),
              Tab(
                icon: const Icon(Icons.history),
                child: Text(
                  'جميع الطلبات',
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Requests Tab
            pendingRequests.when(
              data: (requests) => _buildRequestsList(
                context,
                ref,
                requests,
                ServiceRequestStatus.pending,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'حدث خطأ: $error',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ),

            // In Progress Requests Tab
            inProgressRequests.when(
              data: (requests) => _buildRequestsList(
                context,
                ref,
                requests,
                ServiceRequestStatus.inProgress,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'حدث خطأ: $error',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ),

            // All Requests Tab
            allRequests.when(
              data: (requests) => _buildRequestsList(
                context,
                ref,
                requests,
                null, // All statuses
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'حدث خطأ: $error',
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRequestModel> requests,
    ServiceRequestStatus? status,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == ServiceRequestStatus.pending
                  ? Icons.pending_actions
                  : status == ServiceRequestStatus.inProgress
                      ? Icons.work
                      : Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              status == ServiceRequestStatus.pending
                  ? 'لا توجد طلبات في انتظار المراجعة'
                  : status == ServiceRequestStatus.inProgress
                      ? 'لا توجد طلبات قيد التنفيذ'
                      : 'لا توجد طلبات خدمة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: _getStatusColor(request.status).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(request.status).withOpacity(0.1),
              child: Icon(
                _getStatusIcon(request.status),
                color: _getStatusColor(request.status),
              ),
            ),
            title: Text(
              'طلب: ${request.serviceName}',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'العميل: ${request.clientName}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        request.status.displayName,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: _getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_formatTimestamp(request.createdAt)}',
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: request.status == ServiceRequestStatus.pending
                ? IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () =>
                        _showStartRequestDialog(context, ref, request),
                    tooltip: 'بدء العمل',
                  )
                : request.status == ServiceRequestStatus.inProgress
                    ? IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.blue),
                        onPressed: () =>
                            _showCompleteRequestDialog(context, ref, request),
                        tooltip: 'إنهاء العمل',
                      )
                    : null,
            children: [
              // Expanded request details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            label: 'البريد الإلكتروني',
                            value: request.clientEmail,
                            icon: Icons.email,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoItem(
                            label: 'رقم الهاتف',
                            value: request.clientPhone,
                            icon: Icons.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'متطلبات الخدمة:',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        request.requirements,
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (request.status == ServiceRequestStatus.inProgress &&
                        request.assignedAdminName != null) ...[
                      _buildInfoItem(
                        label: 'تم البدء بواسطة',
                        value: request.assignedAdminName!,
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تاريخ البدء: ${request.startedAt != null ? _formatTimestamp(request.startedAt!) : 'غير محدد'}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (request.status == ServiceRequestStatus.completed &&
                        request.completedAt != null) ...[
                      Text(
                        'تاريخ الإنجاز: ${_formatTimestamp(request.completedAt!)}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (request.status == ServiceRequestStatus.pending)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showStartRequestDialog(context, ref, request),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'بدء العمل',
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          )
                        else if (request.status ==
                            ServiceRequestStatus.inProgress)
                          ElevatedButton.icon(
                            onPressed: () => _showCompleteRequestDialog(
                                context, ref, request),
                            icon: const Icon(Icons.check_circle),
                            label: Text(
                              'إنهاء العمل',
                              style: GoogleFonts.cairo(),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (request.status != ServiceRequestStatus.cancelled &&
                            request.status != ServiceRequestStatus.completed)
                          TextButton.icon(
                            onPressed: () =>
                                _showCancelRequestDialog(context, ref, request),
                            icon: const Icon(Icons.cancel),
                            label: Text(
                              'إلغاء الطلب',
                              style: GoogleFonts.cairo(),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStartRequestDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text(
              'بدء العمل على الطلب',
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
              'هل تريد البدء بالعمل على هذا الطلب؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخدمة: ${request.serviceName}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'العميل: ${request.clientName}',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ملاحظة: بمجرد البدء في العمل، لن يتمكن المشرفون الآخرون من العمل على هذا الطلب.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
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
              // Get the admin's name from auth state (or use placeholder)
              final adminName = ref.read(authProvider).user?.email ?? 'مشرف';
              final adminId = ref.read(authProvider).user?.uid ?? '00000';

              final success = await ref
                  .read(srp.serviceRequestsProvider.notifier)
                  .startProcessing(request.id, adminId, adminName);

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم بدء العمل على الطلب بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(srp.serviceRequestsProvider).errorMessage ??
                          'حدث خطأ أثناء بدء العمل على الطلب',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text(
              'بدء العمل',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showCompleteRequestDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'إنهاء العمل على الطلب',
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
              'هل انتهيت من العمل على هذا الطلب؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخدمة: ${request.serviceName}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'العميل: ${request.clientName}',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),
          ],
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
              final success = await ref
                  .read(srp.serviceRequestsProvider.notifier)
                  .completeRequest(request.id, "not");

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إنهاء العمل على الطلب بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(srp.serviceRequestsProvider).errorMessage ??
                          'حدث خطأ أثناء إنهاء العمل على الطلب',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'إنهاء العمل',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showCancelRequestDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'إلغاء الطلب',
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
              'هل أنت متأكد من إلغاء هذا الطلب؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخدمة: ${request.serviceName}',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'العميل: ${request.clientName}',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'سيتم تحديث حالة الطلب إلى "ملغي" ولن يتم العمل عليه.',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'تراجع',
              style: GoogleFonts.cairo(),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(srp.serviceRequestsProvider.notifier)
                  .cancelRequest(request.id);

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إلغاء الطلب بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.grey,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'إلغاء الطلب',
              style: GoogleFonts.cairo(
                color: Colors.white,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Color _getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.orange;
      case ServiceRequestStatus.inProgress:
        return Colors.blue;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Icons.pending_actions;
      case ServiceRequestStatus.inProgress:
        return Icons.work;
      case ServiceRequestStatus.completed:
        return Icons.check_circle;
      case ServiceRequestStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
