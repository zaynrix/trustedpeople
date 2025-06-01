import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';

PreferredSizeWidget buildAppBar(
    BuildContext context, WidgetRef ref, bool isMobile, bool isAdmin) {
  if (isMobile) {
    // Enhanced mobile app bar with gradient
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAdmin
                ? [Colors.green.shade600, Colors.green.shade700]
                : [Colors.teal.shade600, Colors.teal.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Text(
        'كيف تحمي نفسك؟',
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  } else {
    // Web: Enhanced app bar
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'دليل الحماية من النصب والاحتيال',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        if (isAdmin)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => AddEditTipDialog.show(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text('إضافة نصيحة', style: GoogleFonts.cairo()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        const SizedBox(width: 16),
      ],
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    );
  }
}
