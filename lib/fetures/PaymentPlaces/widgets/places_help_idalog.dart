import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/help_item_widget.dart';

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(
            'المساعدة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            HelpItemWidget(
              primaryColor: Colors.blue.shade600,
              title: 'البحث',
              description: 'يمكنك البحث باسم المكان أو الموقع أو التصنيف',
              icon: Icons.search,
            ),
            const Divider(),
            HelpItemWidget(
              primaryColor: Colors.blue.shade600,
              title: 'التصفية',
              description:
              'استخدم خيارات التصفية لعرض نتائج محددة (حسب التصنيف، الموقع، أو التقييم)',
              icon: Icons.filter_list,
            ),
            const Divider(),
            HelpItemWidget(
              primaryColor: Colors.blue.shade600,
              title: 'الترتيب',
              description:
              'يمكنك ترتيب النتائج حسب الاسم أو الموقع أو التقييم',
              icon: Icons.sort,
            ),
            const Divider(),
            HelpItemWidget(
              primaryColor: Colors.blue.shade600,
              title: 'التفاصيل',
              description:
              'انقر على "المزيد" أو على بطاقة المكان لعرض جميع التفاصيل',
              icon: Icons.info_outline,
            ),
            const Divider(),
            HelpItemWidget(
              primaryColor: Colors.blue.shade600,
              title: 'طرق الدفع',
              description: 'تظهر طرق الدفع المقبولة لكل متجر بألوان مختلفة',
              icon: Icons.payment,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إغلاق',
            style: GoogleFonts.cairo(
              color: Colors.blue.shade600,
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
