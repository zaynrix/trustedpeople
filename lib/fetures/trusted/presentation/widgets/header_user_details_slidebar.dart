import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/status_chip.dart';

import '../../../Home/models/user_model.dart';

class HeaderUserDetailSlidebar extends StatelessWidget {
  const HeaderUserDetailSlidebar({
    super.key,
    required this.user,
    required this.onClose,
  });

  final UserModel user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: user.isTrusted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: user.isTrusted ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات التواصل',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                StatusChip(isTrusted: user.isTrusted),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}