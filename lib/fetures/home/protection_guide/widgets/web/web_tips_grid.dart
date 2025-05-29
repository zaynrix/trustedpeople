import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/web/web_tip_card.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

import '../../models/protection_tip.dart';

Widget buildWebTipsGrid(BuildContext context, WidgetRef ref,
    List<ProtectionTip> tips, bool isDesktop) {
  final isAdmin = ref.watch(isAdminProvider);
  final crossAxisCount = isDesktop ? 3 : 2;
  final childAspectRatio = isDesktop ? 1.2 : 1.1;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'نصائح الحماية',
            style: GoogleFonts.cairo(
              fontSize: isDesktop ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          if (isAdmin)
            OutlinedButton.icon(
              onPressed: () => AddEditTipDialog.show(context, ref),
              icon: const Icon(Icons.add),
              label: Text('إضافة نصيحة جديدة', style: GoogleFonts.cairo()),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'اتبع هذه النصائح لتحمي نفسك من عمليات النصب والاحتيال',
        style: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 32),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return buildWebTipCard(context, ref, tip, isAdmin, isDesktop);
        },
      ),
    ],
  );
}
