import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            HelpItem(
              title: 'البحث',
              description: 'يمكنك البحث بالاسم أو رقم الجوال أو الموقع',
              icon: Icons.search,
            ),
            Divider(),
            HelpItem(
              title: 'التصفية',
              description: 'استخدم خيارات التصفية لعرض نتائج محددة',
              icon: Icons.filter_list,
            ),
            Divider(),
            HelpItem(
              title: 'الترتيب',
              description: 'يمكنك ترتيب النتائج حسب الاسم أو الموقع أو غيرها',
              icon: Icons.sort,
            ),
            Divider(),
            HelpItem(
              title: 'التفاصيل',
              description: 'انقر على "المزيد" لعرض جميع تفاصيل المستخدم',
              icon: Icons.info_outline,
            ),
            Divider(),
            HelpItem(
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

class HelpItem extends StatelessWidget {
  const HelpItem({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

   final String title;
     final   String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}