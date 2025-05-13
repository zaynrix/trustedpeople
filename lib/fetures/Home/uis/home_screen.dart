import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/routs/screens_name.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: Colors.teal,
        title: Text(
          'ترست فالي - الصفحة الرئيسية',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth > 768)
                const AppDrawer(isPermanent: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildHomeContent(context, constraints),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, BoxConstraints constraints) {
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
                  'مرحباً بك في منصة ترست فالي',
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
                  'إحصائيات منصة ترست فالي',
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                isLargeScreen
                    ? _buildStatsRow()
                    : _buildStatsColumn(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Recent activity
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخر التحديثات',
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildRecentUpdates(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCardsRow() {
    return Row(
      children: [
        Expanded(child: _buildFeatureCard(
            'قائمة الموثوقين',
            'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
            Icons.verified_user,
            Colors.green,
            ScreensNames.trusted
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildFeatureCard(
            'قائمة النصابين',
            'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
            Icons.block,
            Colors.red,
            ScreensNames.untrusted
        )),
        const SizedBox(width: 16),
        Expanded(child: _buildFeatureCard(
            'كيف تحمي نفسك؟',
            'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            Icons.security,
            Colors.blue,
            ScreensNames.instruction
        )),
      ],
    );
  }

  Widget _buildFeatureCardsMediumGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFeatureCard(
                'قائمة الموثوقين',
                'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                Icons.verified_user,
                Colors.green,
                ScreensNames.trusted
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildFeatureCard(
                'قائمة النصابين',
                'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                Icons.block,
                Colors.red,
                ScreensNames.untrusted
            )),
          ],
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'كيف تحمي نفسك؟',
            'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            Icons.security,
            Colors.blue,
            ScreensNames.instruction
        ),
      ],
    );
  }

  Widget _buildFeatureCardsColumn() {
    return Column(
      children: [
        _buildFeatureCard(
            'قائمة الموثوقين',
            'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
            Icons.verified_user,
            Colors.green,
            ScreensNames.trusted
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'قائمة النصابين',
            'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
            Icons.block,
            Colors.red,
            ScreensNames.untrusted
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'كيف تحمي نفسك؟',
            'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            Icons.security,
            Colors.blue,
            ScreensNames.instruction
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, String routeName) {
    return Builder(
      builder: (context) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => context.goNamed(routeName),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('250+', 'موثوق'),
        _buildStatItem('100+', 'نصاب'),
        _buildStatItem('1000+', 'مستخدم'),
        _buildStatItem('90%', 'معدل الرضا'),
      ],
    );
  }

  Widget _buildStatsColumn() {
    return Column(
      children: [
        _buildStatItem('250+', 'موثوق'),
        const SizedBox(height: 16),
        _buildStatItem('100+', 'نصاب'),
        const SizedBox(height: 16),
        _buildStatItem('1000+', 'مستخدم'),
        const SizedBox(height: 16),
        _buildStatItem('90%', 'معدل الرضا'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            textStyle: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUpdates() {
    return Column(
      children: [
        _buildUpdateItem(
          'تم إضافة 5 مستخدمين جدد إلى قائمة الموثوقين',
          '12 مايو 2025',
        ),
        const Divider(),
        _buildUpdateItem(
          'تم تحديث معايير التوثيق والتحقق من الهوية',
          '10 مايو 2025',
        ),
        const Divider(),
        _buildUpdateItem(
          'إضافة خاصية البحث المتقدم للمستخدمين',
          '5 مايو 2025',
        ),
      ],
    );
  }

  Widget _buildUpdateItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 12, color: Colors.teal.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.cairo(
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}