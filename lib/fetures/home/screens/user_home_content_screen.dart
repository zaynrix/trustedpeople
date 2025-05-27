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
    final screenWidth = constraints.maxWidth;

    // Define breakpoints
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isDesktop = screenWidth >= 1024;

    return isMobile
        ? _buildMobileLayout(context)
        : _buildWebLayout(context, isDesktop);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileWelcomeSection(),
            const SizedBox(height: 24),
            _buildMobileFeatureCards(context),
            const SizedBox(height: 24),
            _buildMobileStatsSection(),
            const SizedBox(height: 24),
            _buildMobileActivitySection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, bool isDesktop) {
    final maxWidth = isDesktop ? 1200.0 : 900.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWebHeroSection(isDesktop),
              const SizedBox(height: 48),
              _buildWebFeatureSection(context, isDesktop),
              const SizedBox(height: 48),
              _buildWebStatsSection(isDesktop),
              const SizedBox(height: 48),
              _buildWebActivitySection(isDesktop, context),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile-specific widgets
  Widget _buildMobileWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'مرحباً بك في منصة موثوق',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'المنصة الرائدة للتعاملات الآمنة في غزة',
            style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'آمان وثقة في كل تعامل',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات الرئيسية',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        const Column(
          children: [
            FeatureCard(
              title: 'قائمة الموثوقين',
              description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
              icon: Icons.verified_user,
              color: Colors.green,
              routeName: ScreensNames.trusted,
            ),
            SizedBox(height: 12),
            FeatureCard(
              title: 'قائمة النصابين',
              description:
                  'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
              icon: Icons.block,
              color: Colors.red,
              routeName: ScreensNames.untrusted,
            ),
            SizedBox(height: 12),
            FeatureCard(
              title: 'كيف تحمي نفسك؟',
              description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
              icon: Icons.security,
              color: Colors.blue,
              routeName: ScreensNames.instruction,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.teal.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'إحصائيات منصة موثوق',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const StatsColumn(),
        ],
      ),
    );
  }

  Widget _buildMobileActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحديثات الأخيرة',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const UserActivityWidget(),
        ),
      ],
    );
  }

  // Web-specific widgets
  Widget _buildWebHeroSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade800,
            Colors.teal.shade600,
            Colors.teal.shade400
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'المنصة الأولى في غزة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Text(
                  'مرحباً بك في منصة موثوق',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: isDesktop ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                Text(
                  'المنصة الرائدة للتعاملات الآمنة في غزة. نوفر لك بيئة آمنة وموثوقة للتحقق من سمعة الأشخاص والشركات قبل التعامل معهم، مما يضمن حمايتك من عمليات النصب والاحتيال.',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isDesktop ? 18 : 16,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: isDesktop ? 32 : 24),
                Row(
                  children: [
                    _buildWebActionButton(
                      label: 'ابدأ الآن',
                      icon: Icons.arrow_forward,
                      isPrimary: true,
                    ),
                    const SizedBox(width: 16),
                    _buildWebActionButton(
                      label: 'تعلم المزيد',
                      icon: Icons.info_outline,
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'آمان وثقة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'في كل تعامل',
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWebActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle button press
        },
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.transparent,
          foregroundColor: isPrimary ? Colors.teal.shade700 : Colors.white,
          side: isPrimary ? null : const BorderSide(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildWebFeatureSection(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'خدماتنا الرئيسية',
          style: GoogleFonts.cairo(
            fontSize: isDesktop ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'اكتشف كيف يمكن لمنصة موثوق أن تساعدك في التعاملات الآمنة',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        SizedBox(height: isDesktop ? 32 : 24),
        _buildWebFeatureGrid(isDesktop),
      ],
    );
  }

  Widget _buildWebFeatureGrid(bool isDesktop) {
    if (isDesktop) {
      return const Row(
        children: [
          Expanded(
            child: FeatureCard(
              title: 'قائمة الموثوقين',
              description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم بأمان',
              icon: Icons.verified_user,
              color: Colors.green,
              routeName: ScreensNames.trusted,
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: FeatureCard(
              title: 'قائمة النصابين',
              description:
                  'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
              icon: Icons.block,
              color: Colors.red,
              routeName: ScreensNames.untrusted,
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: FeatureCard(
              title: 'كيف تحمي نفسك؟',
              description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
              icon: Icons.security,
              color: Colors.blue,
              routeName: ScreensNames.instruction,
            ),
          ),
        ],
      );
    } else {
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
                  routeName: ScreensNames.trusted,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: FeatureCard(
                  title: 'قائمة النصابين',
                  description:
                      'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                  icon: Icons.block,
                  color: Colors.red,
                  routeName: ScreensNames.untrusted,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          FeatureCard(
            title: 'كيف تحمي نفسك؟',
            description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            icon: Icons.security,
            color: Colors.blue,
            routeName: ScreensNames.instruction,
          ),
        ],
      );
    }
  }

  Widget _buildWebStatsSection(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 40.0 : 32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.teal.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'إحصائيات منصة موثوق',
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade800,
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'أرقام تعكس ثقة المجتمع في منصتنا',
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 32 : 24),
          const StatsRow(),
        ],
      ),
    );
  }

  Widget _buildWebActivitySection(bool isDesktop, context) {
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
                context.pushNamed(ScreensNames.updates);

                // Handle view all
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
