import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/user_model.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

import '../../../../services/auth_service.dart';
// Confirmation dialog for deleting a user
void showDeleteConfirmation(
    BuildContext context, WidgetRef ref, UserModel user) {
  final homeNotifier = ref.read(homeProvider.notifier);
  if (!ref.read(isAdminProvider)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'عذراً، فقط المشرفين يمكنهم حذف المستخدمين',
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
          const Icon(Icons.delete, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            'حذف مستخدم',
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
            'هل أنت متأكد من أنك تريد حذف هذا المستخدم؟',
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
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.aliasName,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.mobileNumber,
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
            final success = await homeNotifier.deleteUser(user.id);
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حذف المستخدم بنجاح',
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