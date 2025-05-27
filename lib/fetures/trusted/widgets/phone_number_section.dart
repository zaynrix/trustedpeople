import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/trusted/model/user_model.dart';
import 'package:trustedtallentsvalley/fetures/trusted/widgets/clipboard_utils.dart';

class PhoneNumberSection extends ConsumerWidget {
  final UserModel user;
  final bool isPhoneVisible;

  const PhoneNumberSection({
    super.key,
    required this.user,
    required this.isPhoneVisible,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPhoneVisible) {
      return Row(
        children: [
          GestureDetector(
            onTap: () => ClipboardUtils.copyToClipboard(context, user.mobileNumber),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.mobileNumber,
                    style: GoogleFonts.cairo(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.content_copy,
                      size: 14, color: Colors.green.shade600),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.visibility_off,
                size: 18, color: Colors.grey.shade600),
            onPressed: () => _togglePhoneNumberVisibility(ref, user.id),
            tooltip: 'إخفاء رقم الجوال',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _togglePhoneNumberVisibility(ref, user.id),
      icon: const Icon(Icons.visibility, size: 16),
      label: Text('اظهر رقم الجوال', style: GoogleFonts.cairo(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }

  void _togglePhoneNumberVisibility(WidgetRef ref, String userId) {
    final currentVisibleId = ref.read(visiblePhoneNumberProvider);
    if (currentVisibleId == userId) {
      ref.read(visiblePhoneNumberProvider.notifier).state = null;
    } else {
      ref.read(visiblePhoneNumberProvider.notifier).state = userId;
    }
  }
}