import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChipWidget extends StatelessWidget {
  final bool? isTrusted;
  const ChipWidget({Key? key, this.isTrusted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isTrusted == true
              ? Colors.green.shade50
              : Colors.red.shade50, // تغيير اللون حسب الثقة
          borderRadius: BorderRadius.circular(8.0), // جعل الزوايا دائرية
          border: Border.all(
            color: isTrusted == true
                ? Colors.green
                : Colors.red, // إضافة حدود بلون مطابق
            width: 2.0, // عرض الحدود
          ),
        ),
        child: Text(
          isTrusted == true ? "موثوق" : "نصاب", // النص بناءً على الثقة
          style: GoogleFonts.cairo(
            textStyle: TextStyle(
              color: isTrusted == true
                  ? Colors.green
                  : Colors.red, // تغيير لون النص بناءً على الثقة
              fontWeight: FontWeight.bold,
              fontSize: 14, // حجم الخط
            ),
          ),
        ),
      ),
    );
  }
}
