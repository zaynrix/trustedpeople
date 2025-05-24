import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/models/payment_place_model.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/providers/payment_places_provider.dart';
import 'package:trustedtallentsvalley/fetures/PaymentPlaces/widgets/payment_places_shared_widgets.dart';

class PaymentPlacesDialogs {
  // Dialog for exporting data
  static void showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'تصدير البيانات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر صيغة التصدير:',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            PaymentPlacesSharedWidgets.buildExportOption(
              context,
              title: 'Excel (XLSX)',
              icon: Icons.table_chart,
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            PaymentPlacesSharedWidgets.buildExportOption(
              context,
              title: 'CSV',
              icon: Icons.description,
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            PaymentPlacesSharedWidgets.buildExportOption(
              context,
              title: 'PDF',
              icon: Icons.picture_as_pdf,
              onTap: () {
                // Export logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
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
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // Dialog for adding a new place
  static void showAddPlaceDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

    String name = '';
    String phoneNumber = '';
    String location = '';
    String category = '';
    List<String> paymentMethods = [];
    String workingHours = '';
    String description = '';
    String imageUrl = '';
    bool isVerified = true;

    final availablePaymentMethods = [
      'فيزا',
      'ماستركارد',
      'تحويل بنكي',
      'جوال باي',
      'نقد',
    ];

    final categoryController = TextEditingController();

    // Set to track selected payment methods
    final selectedPaymentMethods = <String>{};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_business, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'إضافة متجر جديد',
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
                  decoration: InputDecoration(
                    labelText: 'اسم المكان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المكان';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الموقع';
                    }
                    return null;
                  },
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    labelText: 'التصنيف',
                    hintText: 'مثال: مطعم، سوبرماركت، صيدلية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال التصنيف';
                    }
                    return null;
                  },
                  onSaved: (value) => category = value ?? '',
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طرق الدفع المقبولة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availablePaymentMethods.map((method) {
                          final isSelected =
                          selectedPaymentMethods.contains(method);
                          return FilterChip(
                            label: Text(method, style: GoogleFonts.cairo()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPaymentMethods.add(method);
                                } else {
                                  selectedPaymentMethods.remove(method);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade600,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'ساعات العمل',
                    hintText: 'مثال: 9 صباحاً - 9 مساءً',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => workingHours = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رابط الصورة',
                    hintText: 'اختياري',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => imageUrl = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'وصف',
                    hintText: 'اختياري',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
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
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('متحقق منه', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text('قيد التحقق', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                  ],
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
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final place = PaymentPlaceModel(
                  id: '', // Will be set by Firestore
                  name: name,
                  phoneNumber: phoneNumber,
                  location: location,
                  category: category,
                  paymentMethods: selectedPaymentMethods.toList(),
                  workingHours: workingHours,
                  description: description,
                  imageUrl: imageUrl,
                  isVerified: isVerified,
                  rating: 0,
                  reviewsCount: 0,
                );

                final success = await placesNotifier.addPlace(place);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تمت إضافة المتجر بنجاح',
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

  // Dialog for editing a place
  static void showEditPlaceDialog(
      BuildContext context, WidgetRef ref, PaymentPlaceModel place) {
    final formKey = GlobalKey<FormState>();
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

    String name = place.name;
    String phoneNumber = place.phoneNumber;
    String location = place.location;
    String category = place.category;
    String workingHours = place.workingHours;
    String description = place.description;
    String imageUrl = place.imageUrl;
    bool isVerified = place.isVerified;

    final availablePaymentMethods = [
      'فيزا',
      'ماستركارد',
      'تحويل بنكي',
      'جوال باي',
      'نقد',
    ];

    // Set to track selected payment methods
    final selectedPaymentMethods = place.paymentMethods.toSet();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              'تعديل متجر',
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
                  initialValue: name,
                  decoration: InputDecoration(
                    labelText: 'اسم المكان',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم المكان';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: phoneNumber,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                  onSaved: (value) => phoneNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: location,
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الموقع';
                    }
                    return null;
                  },
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: 'التصنيف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال التصنيف';
                    }
                    return null;
                  },
                  onSaved: (value) => category = value ?? '',
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طرق الدفع المقبولة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availablePaymentMethods.map((method) {
                          final isSelected =
                          selectedPaymentMethods.contains(method);
                          return FilterChip(
                            label: Text(method, style: GoogleFonts.cairo()),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedPaymentMethods.add(method);
                                } else {
                                  selectedPaymentMethods.remove(method);
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.blue.shade100,
                            checkmarkColor: Colors.blue.shade600,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: workingHours,
                  decoration: InputDecoration(
                    labelText: 'ساعات العمل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => workingHours = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: imageUrl,
                  decoration: InputDecoration(
                    labelText: 'رابط الصورة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSaved: (value) => imageUrl = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(
                    labelText: 'وصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) => description = value ?? '',
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
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.green,
                          ),
                          Text('متحقق منه', style: GoogleFonts.cairo()),
                          const SizedBox(width: 16),
                          Radio<bool>(
                            value: false,
                            groupValue: isVerified,
                            onChanged: (value) {
                              setState(() => isVerified = value!);
                            },
                            activeColor: Colors.orange,
                          ),
                          Text('قيد التحقق', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                  ],
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
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final updatedPlace = PaymentPlaceModel(
                  id: place.id,
                  name: name,
                  phoneNumber: phoneNumber,
                  location: location,
                  category: category,
                  paymentMethods: selectedPaymentMethods.toList(),
                  workingHours: workingHours,
                  description: description,
                  imageUrl: imageUrl,
                  isVerified: isVerified,
                  rating: place.rating,
                  reviewsCount: place.reviewsCount,
                );

                final success = await placesNotifier.updatePlace(updatedPlace);

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تحديث المتجر بنجاح',
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
              'حفظ',
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

  // Confirmation dialog for deleting a place
  static void showDeleteConfirmation(
      BuildContext context, WidgetRef ref, PaymentPlaceModel place) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'حذف متجر',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'هل أنت متأكد من أنك تريد حذف هذا المتجر؟',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          place.location,
                          style: GoogleFonts.cairo(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه.',
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
              final success = await placesNotifier.deletePlace(place.id);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حذف المتجر بنجاح',
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

  // Location filter dialog
  static void showLocationFilterDialog(BuildContext context, WidgetRef ref) {
    final placesNotifier = ref.read(paymentPlacesProvider.notifier);
    final locations = ref.watch(placesLocationsProvider);

    if (locations.isLoading) {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      return;
    }

    if (locations.hasError) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('خطأ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text('فشل تحميل المواقع: ${locations.error}',
              style: GoogleFonts.cairo()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تصفية حسب الموقع',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر الموقع للتصفية',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 16),
            if (locations.value!.isEmpty)
              Text(
                'لا توجد مواقع متاحة',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              )
            else
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: locations.value!.length,
                  itemBuilder: (context, index) {
                    final location = locations.value![index];
                    return ListTile(
                      title: Text(location, style: GoogleFonts.cairo()),
                      leading: const Icon(Icons.location_on_outlined),
                      onTap: () {
                        placesNotifier.setLocationFilter(location);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              placesNotifier.setFilterMode(PlacesFilterMode.all);
              Navigator.pop(context);
            },
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}