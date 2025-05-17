import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

import '../../../../services/auth_service.dart';

// Dialog for exporting data
void showExportDialog(BuildContext context, WidgetRef ref) {
  final homeNotifier = ref.read(homeProvider.notifier);
  if (!ref.read(isAdminProvider)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'عذراً، فقط المشرفين يمكنهم تصدير البيانات',
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
          const Icon(Icons.download_rounded, color: Colors.green),
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
          _buildExportOption(
            context,
            title: 'Excel (XLSX)',
            icon: Icons.table_chart,
            onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('xlsx');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildExportOption(
            context,
            title: 'CSV',
            icon: Icons.description,
            onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('csv');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildExportOption(
            context,
            title: 'PDF',
            icon: Icons.picture_as_pdf,
            onTap: () async {
              Navigator.pop(context);
              final result = await homeNotifier.exportData('pdf');
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تصدير البيانات بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
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

// Export option item
Widget _buildExportOption(
    BuildContext context, {
      required String title,
      required IconData icon,
      required VoidCallback onTap,
    }) {
  return ListTile(
    leading: Icon(icon, color: Colors.green),
    title: Text(title, style: GoogleFonts.cairo()),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    onTap: onTap,
    hoverColor: Colors.green.withOpacity(0.1),
  );
}