import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';

// Dialog for adding a new user
class AddUserDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final homeNotifier = ref.read(homeProvider.notifier);

    String aliasName = '';
    String mobileNumber = '';
    String location = '';
    String? servicesProvided;
    String? telegramAccount;
    String? otherAccounts;
    String? reviews;
    int role = 1; // 1 = موثوق, 2 = معروف, 3 = نصاب

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم إضافة مستخدمين جدد',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.green),
            const SizedBox(width: 8),
            Text('إضافة مستخدم جديد',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                    labelText: 'الاسم المستعار',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال رقم الجوال'
                      : null,
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الموقع'
                      : null,
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => servicesProvided = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => telegramAccount = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => otherAccounts = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => reviews = value,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          RadioListTile<int>(
                            title: Text('موثوق', style: GoogleFonts.cairo()),
                            value: 1,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.green,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('معروف', style: GoogleFonts.cairo()),
                            value: 2,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.orange,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('نصاب', style: GoogleFonts.cairo()),
                            value: 3,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.red,
                            dense: true,
                          ),
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
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final success = await homeNotifier.addUser(
                  ref: ref,
                  aliasName: aliasName,
                  mobileNumber: mobileNumber,
                  location: location,
                  servicesProvided: servicesProvided,
                  telegramAccount: telegramAccount,
                  otherAccounts: otherAccounts,
                  reviews: reviews,
                  role: role,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تمت إضافة المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('إضافة', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Dialog for editing an existing user
class EditUserDialog {
  static void show(BuildContext context, WidgetRef ref, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final homeNotifier = ref.read(homeProvider.notifier);

    String aliasName = user.aliasName;
    String mobileNumber = user.mobileNumber;
    String location = user.location;
    String servicesProvided = user.servicesProvided;
    String telegramAccount = user.telegramAccount;
    String otherAccounts = user.otherAccounts;
    String reviews = user.reviews;
    int role = user.role;

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم تعديل المستخدمين',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text('تعديل مستخدم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: aliasName,
                  decoration: InputDecoration(
                    labelText: 'الاسم المستعار',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الاسم'
                      : null,
                  onSaved: (value) => aliasName = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: mobileNumber,
                  decoration: InputDecoration(
                    labelText: 'رقم الجوال',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال رقم الجوال'
                      : null,
                  onSaved: (value) => mobileNumber = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: location,
                  decoration: InputDecoration(
                    labelText: 'الموقع',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال الموقع'
                      : null,
                  onSaved: (value) => location = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: servicesProvided,
                  decoration: InputDecoration(
                    labelText: 'الخدمات المقدمة',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => servicesProvided = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: telegramAccount,
                  decoration: InputDecoration(
                    labelText: 'حساب تيليجرام',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => telegramAccount = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: otherAccounts,
                  decoration: InputDecoration(
                    labelText: 'حسابات أخرى',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => otherAccounts = value ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: reviews,
                  decoration: InputDecoration(
                    labelText: 'التقييمات',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onSaved: (value) => reviews = value ?? '',
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الحالة:',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          RadioListTile<int>(
                            title: Text('موثوق', style: GoogleFonts.cairo()),
                            value: 1,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.green,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('معروف', style: GoogleFonts.cairo()),
                            value: 2,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.orange,
                            dense: true,
                          ),
                          RadioListTile<int>(
                            title: Text('نصاب', style: GoogleFonts.cairo()),
                            value: 3,
                            groupValue: role,
                            onChanged: (value) => setState(() => role = value!),
                            activeColor: Colors.red,
                            dense: true,
                          ),
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
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();

                final success = await homeNotifier.updateUser(
                  id: user.id,
                  aliasName: aliasName,
                  mobileNumber: mobileNumber,
                  location: location,
                  servicesProvided: servicesProvided,
                  telegramAccount: telegramAccount,
                  otherAccounts: otherAccounts,
                  reviews: reviews,
                  role: role,
                );

                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Dialog for deleting a user
class DeleteUserDialog {
  static void show(BuildContext context, WidgetRef ref, UserModel user) {
    final homeNotifier = ref.read(homeProvider.notifier);

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم حذف المستخدمين',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text('حذف مستخدم',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من أنك تريد حذف هذا المستخدم؟',
                style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.aliasName,
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                        Text(user.mobileNumber,
                            style:
                                GoogleFonts.cairo(color: Colors.grey.shade700)),
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
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await homeNotifier.deleteUser(user.id);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المستخدم بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Dialog for exporting data
class ExportDialog {
  static void show(BuildContext context, WidgetRef ref, Color primaryColor) {
    final homeNotifier = ref.read(homeProvider.notifier);

    if (!ref.read(isAdminProvider)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('عذراً، فقط المشرفين يمكنهم تصدير البيانات',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: primaryColor),
            const SizedBox(width: 8),
            Text('تصدير البيانات',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر صيغة التصدير:', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            _buildExportOption(context,
                title: 'Excel (XLSX)',
                icon: Icons.table_chart,
                color: primaryColor, onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('xlsx');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
            _buildExportOption(context,
                title: 'CSV',
                icon: Icons.description,
                color: primaryColor, onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('csv');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
            _buildExportOption(context,
                title: 'PDF',
                icon: Icons.picture_as_pdf,
                color: primaryColor, onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('pdf');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تصدير البيانات بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static Widget _buildExportOption(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      required Color color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.cairo()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
      hoverColor: color.withOpacity(0.1),
    );
  }
}

// Dialog for filtering by location
class LocationFilterDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final homeNotifier = ref.read(homeProvider.notifier);
    final locations = ref.watch(locationsProvider);

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
        title: Text('تصفية حسب الموقع',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر الموقع للتصفية', style: GoogleFonts.cairo()),
            const SizedBox(height: 16),
            if (locations.value!.isEmpty)
              Text('لا توجد مواقع متاحة',
                  style: GoogleFonts.cairo(), textAlign: TextAlign.center)
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
                        homeNotifier.setLocationFilter(location);
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
              homeNotifier.setFilterMode(FilterMode.all);
              Navigator.pop(context);
            },
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Help dialog
class HelpDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text('المساعدة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                title: 'البحث والتصفية',
                content:
                    'يمكنك البحث باستخدام حقل البحث في الأعلى. البحث يشمل الاسم ورقم الجوال والموقع والخدمات المقدمة.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                title: 'الترتيب',
                content:
                    'يمكنك ترتيب النتائج حسب الاسم أو رقم الجوال أو الموقع أو التقييمات أو الحالة من خلال النقر على زر الترتيب.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                title: 'التصفية',
                content:
                    'استخدم أزرار التصفية للعرض حسب معايير محددة مثل التقييمات أو الموقع أو حسابات تيليجرام.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                title: 'عرض التفاصيل',
                content:
                    'انقر على أي مستخدم لعرض كافة تفاصيله في الشريط الجانبي.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                title: 'رقم الجوال',
                content:
                    'انقر على زر "اظهر رقم الجوال" لعرض الرقم. ثم يمكنك نسخه بالضغط عليه.',
              ),
              if (true) ...{
                // Replace with isAdmin check if needed
                const SizedBox(height: 16),
                _buildHelpSection(
                  title: 'إدارة المستخدمين (للمشرفين)',
                  content:
                      'يمكنك إضافة مستخدمين جدد أو تعديل المستخدمين الحاليين أو حذفهم. استخدم زر "+" لإضافة مستخدم جديد.',
                ),
              },
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static Widget _buildHelpSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.cairo(fontSize: 14),
        ),
      ],
    );
  }
}
