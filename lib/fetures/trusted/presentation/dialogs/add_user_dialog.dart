import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

import '../../../../services/auth_service.dart';

void showAddUserDialog(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  final homeNotifier = ref.read(homeProvider.notifier);

  String aliasName = '';
  String mobileNumber = '';
  String location = '';
  String? servicesProvided;
  String? telegramAccount;
  String? otherAccounts;
  String? reviews;
  bool isTrusted = true;
  if (!ref.read(isAdminProvider)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'عذراً، فقط المشرفين يمكنهم إضافة مستخدمين جدد',
          style: GoogleFonts.cairo(),
        ),
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
          Text(
            'إضافة مستخدم جديد',
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
                  labelText: 'الاسم المستعار',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
                onSaved: (value) => aliasName = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'رقم الجوال',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الجوال';
                  }
                  return null;
                },
                onSaved: (value) => mobileNumber = value ?? '',
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
                decoration: InputDecoration(
                  labelText: 'الخدمات المقدمة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSaved: (value) => servicesProvided = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'حساب تيليجرام',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSaved: (value) => telegramAccount = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'حسابات أخرى',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSaved: (value) => otherAccounts = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'التقييمات',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSaved: (value) => reviews = value,
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
                          groupValue: isTrusted,
                          onChanged: (value) {
                            setState(() => isTrusted = value!);
                          },
                          activeColor: Colors.green,
                        ),
                        Text('موثوق', style: GoogleFonts.cairo()),
                        const SizedBox(width: 16),
                        Radio<bool>(
                          value: false,
                          groupValue: isTrusted,
                          onChanged: (value) {
                            setState(() => isTrusted = value!);
                          },
                          activeColor: Colors.red,
                        ),
                        Text('نصاب', style: GoogleFonts.cairo()),
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

              final success = await homeNotifier.addUser(
                aliasName: aliasName,
                mobileNumber: mobileNumber,
                location: location,
                servicesProvided: servicesProvided,
                telegramAccount: telegramAccount,
                otherAccounts: otherAccounts,
                reviews: reviews,
                isTrusted: isTrusted,
              );

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تمت إضافة المستخدم بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
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