import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/cards/feature_card.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/stats/stats_column.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/stats/stats_row.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/userRecentUpdatesWidget.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class HomeContentWidget extends StatelessWidget {
  final BoxConstraints constraints;

  const HomeContentWidget({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = constraints.maxWidth > 900;
    final isMediumScreen = constraints.maxWidth > 540 && constraints.maxWidth <= 900;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك في منصة موثوق',
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'المنصة الرائدة للتعاملات الآمنة في غزة',
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Feature Cards
          isLargeScreen
              ? _buildFeatureCardsRow()
              : (isMediumScreen
              ? _buildFeatureCardsMediumGrid()
              : _buildFeatureCardsColumn()),

          const SizedBox(height: 32),

          // Statistics Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات منصة موثوق',
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                isLargeScreen ? const StatsRow() : const StatsColumn(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const UserActivityWidget(),
        ],
      ),
    );
  }

  Widget _buildFeatureCardsRow() {
    return const Row(
      children: [
        Expanded(
            child: FeatureCard(
                title: 'قائمة الموثوقين',
                description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                icon: Icons.verified_user,
                color: Colors.green,
                routeName: ScreensNames.trusted)),
        SizedBox(width: 16),
        Expanded(
            child: FeatureCard(
                title: 'قائمة النصابين',
                description: 'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                icon: Icons.block,
                color: Colors.red,
                routeName: ScreensNames.untrusted)),
        SizedBox(width: 16),
        Expanded(
            child: FeatureCard(
                title: 'كيف تحمي نفسك؟',
                description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
                icon: Icons.security,
                color: Colors.blue,
                routeName: ScreensNames.instruction)),
      ],
    );
  }

  Widget _buildFeatureCardsMediumGrid() {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
                child: FeatureCard(
                    title: 'قائمة الموثوقين',
                    description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                    icon: Icons.verified_user,
                    color: Colors.green,
                    routeName: ScreensNames.trusted)),
            SizedBox(width: 16),
            Expanded(
                child: FeatureCard(
                    title: 'قائمة النصابين',
                    description: 'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                    icon: Icons.block,
                    color: Colors.red,
                    routeName: ScreensNames.untrusted)),
          ],
        ),
        SizedBox(height: 16),
        FeatureCard(
            title: 'كيف تحمي نفسك؟',
            description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            icon: Icons.security,
            color: Colors.blue,
            routeName: ScreensNames.instruction),
      ],
    );
  }

  Widget _buildFeatureCardsColumn() {
    return Column(
      children: const [
        FeatureCard(
            title: 'قائمة الموثوقين',
            description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
            icon: Icons.verified_user,
            color: Colors.green,
            routeName: ScreensNames.trusted),
        SizedBox(height: 16),
        FeatureCard(
            title: 'قائمة النصابين',
            description: 'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
            icon: Icons.block,
            color: Colors.red,
            routeName: ScreensNames.untrusted),
        SizedBox(height: 16),
        FeatureCard(
            title: 'كيف تحمي نفسك؟',
            description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            icon: Icons.security,
            color: Colors.blue,
            routeName: ScreensNames.instruction),
      ],
    );
  }
}