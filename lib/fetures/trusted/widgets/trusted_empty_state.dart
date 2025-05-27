import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';

class TrustedEmptyStateWidget extends StatelessWidget {
  final bool isFiltered;
  final String searchQuery;
  final FilterMode filterMode;

  const TrustedEmptyStateWidget({
    Key? key,
    required this.isFiltered,
    required this.searchQuery,
    required this.filterMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltered ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isFiltered ? 'لا توجد نتائج للبحث' : 'لا توجد مستخدمين للعرض',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (isFiltered) ...[
            Text(
              searchQuery.isNotEmpty
                  ? 'جرب البحث بكلمات مختلفة أو قم بإزالة المرشحات'
                  : 'قم بتغيير معايير التصفية',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'تأكد من أن قاعدة البيانات تحتوي على مستخدمين',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}