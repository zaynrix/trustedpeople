import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/delete_confirmation_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/tip_details_dialog.dart';

import '../../models/protection_tip.dart';

Widget buildWebTipCard(BuildContext context, WidgetRef ref, ProtectionTip tip,
    bool isAdmin, bool isDesktop) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            TipDetailsDialog.show(context, tip, isDesktop: true);
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tip.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${tip.order + 1}',
                        style: GoogleFonts.cairo(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  tip.title,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Description
                Expanded(
                  child: Text(
                    tip.description,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: isDesktop ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Add a small indicator that shows this is clickable
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 16,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'اضغط للمزيد',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Admin actions
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              AddEditTipDialog.show(context, ref, tip),
                          icon: const Icon(Icons.edit, size: 16),
                          label: Text('تعديل',
                              style: GoogleFonts.cairo(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              DeleteConfirmationDialog.show(context, ref, tip),
                          icon: const Icon(Icons.delete, size: 16),
                          label: Text('حذف',
                              style: GoogleFonts.cairo(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
