import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/help_item_widget.dart';

void showHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.help_outline, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            'المساعدة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            HelpItemWidget(
              primaryColor: Colors.green,
              title: 'البحث',
              description: 'يمكنك البحث بالاسم أو رقم الجوال أو الموقع',
              icon: Icons.search,
            ),
            Divider(),
            HelpItemWidget(
              primaryColor: Colors.green,
              title: 'التصفية',
              description: 'استخدم خيارات التصفية لعرض نتائج محددة',
              icon: Icons.filter_list,
            ),
            Divider(),
            HelpItemWidget(
              primaryColor: Colors.green,
              title: 'الترتيب',
              description: 'يمكنك ترتيب النتائج حسب الاسم أو الموقع أو غيرها',
              icon: Icons.sort,
            ),
            Divider(),
            HelpItemWidget(
              primaryColor: Colors.green,
              title: 'التفاصيل',
              description: 'انقر على "المزيد" لعرض جميع تفاصيل المستخدم',
              icon: Icons.info_outline,
            ),
            Divider(),
            HelpItemWidget(
              primaryColor: Colors.green,
              title: 'نسخ البيانات',
              description: 'انقر على أي معلومة لنسخها إلى الحافظة',
              icon: Icons.content_copy,
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
              color: Colors.green,
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