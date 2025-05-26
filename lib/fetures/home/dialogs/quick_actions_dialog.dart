import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/dialogs/add_update_dialog.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class QuickActionsDialog {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة سريعة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.green),
                title: Text('إضافة مستخدم موثوق', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(ScreensNames.trusted);
                  // You can add logic to automatically open the add user dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text('إضافة مستخدم نصاب', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(ScreensNames.untrusted);
                  // You can add logic to automatically open the add user dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.blue),
                title: Text('إضافة تحديث جديد', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  AddUpdateDialog.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}