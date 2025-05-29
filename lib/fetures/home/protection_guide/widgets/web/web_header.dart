import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/add_edit_tip_dialog.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/web/web_ab.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

Widget buildWebHeader(
    BuildContext context, WidgetRef ref, int tipsCount, bool isDesktop) {
  final isAdmin = ref.watch(isAdminProvider);

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(isDesktop ? 40.0 : 32.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue.shade600,
          Colors.blue.shade500,
          Colors.teal.shade500,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'دليل شامل للحماية',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              Text(
                'دليل الحماية من النصب والاحتيال',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: isDesktop ? 32 : 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                'تعلم كيفية حماية نفسك ومالك من عمليات النصب والاحتيال من خلال هذه النصائح والإرشادات المهمة التي تساعدك على التعرف على المحتالين وتجنب الوقوع في فخاخهم.',
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isDesktop ? 16 : 14,
                  height: 1.6,
                ),
              ),
              SizedBox(height: isDesktop ? 32 : 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  buildWebActionButton(
                    label: 'ابدأ القراءة',
                    icon: Icons.arrow_downward,
                    isPrimary: true,
                    onPressed: () {
                      // Scroll to tips section
                      Scrollable.ensureVisible(
                        context,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  if (isAdmin)
                    buildWebActionButton(
                      label: 'إدارة النصائح',
                      icon: Icons.settings,
                      isPrimary: false,
                      onPressed: () => AddEditTipDialog.show(context, ref),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(width: 48),
          Expanded(
            flex: 2,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$tipsCount نصيحة مهمة',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'لحمايتك من النصب',
                    style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
