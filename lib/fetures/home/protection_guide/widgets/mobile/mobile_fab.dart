import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';

Widget buildModernFAB(BuildContext context, WidgetRef ref) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: LinearGradient(
        colors: [Colors.green.shade600, Colors.green.shade700],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: FloatingActionButton.extended(
      onPressed: () => AddEditTipDialog.show(context, ref),
      backgroundColor: Colors.transparent,
      elevation: 0,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'إضافة نصيحة',
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
