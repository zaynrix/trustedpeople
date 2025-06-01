import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/delete_confirmation_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/tip_details_dialog.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

import '../../models/protection_tip.dart';

Widget buildModernMobileTipCard(
    BuildContext context, WidgetRef ref, ProtectionTip tip) {
  final isAdmin = ref.watch(isAdminProvider);

  return Hero(
    tag: 'tip_${tip.id}',
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => TipDetailsDialog.show(context, tip),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.blue.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tip.icon,
                        color: Colors.white,
                        size: 24,
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
                const SizedBox(height: 12),

                // Title
                Text(
                  tip.title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Description preview
                Expanded(
                  child: Text(
                    tip.description,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                // Tap indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 14,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'اضغط للمزيد',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Admin actions
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () =>
                              AddEditTipDialog.show(context, ref, tip),
                          icon: const Icon(Icons.edit, size: 14),
                          label: Text('تعديل',
                              style: GoogleFonts.cairo(fontSize: 11)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () =>
                              DeleteConfirmationDialog.show(context, ref, tip),
                          icon: const Icon(Icons.delete, size: 14),
                          label: Text('حذف',
                              style: GoogleFonts.cairo(fontSize: 11)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 4),
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
