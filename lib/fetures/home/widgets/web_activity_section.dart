import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/home/widgets/userRecentUpdatesWidget.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class WebActivitySection extends StatelessWidget {
  const WebActivitySection({
    super.key,
    required this.isDesktop
  });

  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'النشاط الحديث',
                  style: GoogleFonts.cairo(
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'آخر التحديثات على المنصة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                context.pushNamed(ScreensNames.updates,);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(),
              ),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const UserActivityWidget(),
        ),
      ],
    );
  }
}
