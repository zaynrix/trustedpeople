import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlockedScreen extends StatelessWidget {
  const BlockedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.block,
                  size: 80,
                  color: Colors.red.shade700,
                ),
                const SizedBox(height: 24),
                Text(
                  'تم حظر الوصول',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'عذراً، تم حظر وصولك إلى هذا الموقع. إذا كنت تعتقد أن هذا خطأ، يرجى التواصل مع مسؤول الموقع.',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
