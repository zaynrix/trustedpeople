import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfoItem extends StatelessWidget {
  final IconData? iconData;
  final String? title;
  final String? subtitle;

  const UserInfoItem({
    super.key,
    this.iconData,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      child: ListTile(
        leading: Icon(iconData, color: Colors.blue),
        title: Text(
          title ?? '',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ).tr(),
        subtitle: GestureDetector(
          onTap: () {
            if (subtitle != null && subtitle!.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: subtitle!));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم النسخ').tr(),
                  backgroundColor: Colors.blue,
                  behavior: SnackBarBehavior.floating,
                  shape: const StadiumBorder(),
                  width: 300,
                ),
              );
            }
          },
          child: Text(
            subtitle ?? '',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
