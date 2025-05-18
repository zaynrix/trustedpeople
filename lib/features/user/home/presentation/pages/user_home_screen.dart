import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/app/core/navigation/app_router.dart';
import 'package:trustedtallentsvalley/app/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/features/user/core/widgets/feature_card.dart';
import 'package:trustedtallentsvalley/features/user/home/domain/entities/home_data.dart';
import 'package:trustedtallentsvalley/features/user/home/presentation/providers/home_provider.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/presentation/widgets/stats_item.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/presentation/widgets/update_item.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;
    final homeData = ref.watch(homeDataProvider);

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
                  child: homeData.when(
                    data: (data) =>
                        _buildHomeContent(context, constraints, data),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Center(
                      child: Text(
                        'Error loading data: $error',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeContent(
      BuildContext context, BoxConstraints constraints, HomeData data) {
    final isLargeScreen = constraints.maxWidth > 900;
    final isMediumScreen =
        constraints.maxWidth > 540 && constraints.maxWidth <= 900;

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
              ? _buildFeatureCardsRow(context)
              : (isMediumScreen
                  ? _buildFeatureCardsMediumGrid(context)
                  : _buildFeatureCardsColumn(context)),

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
                isLargeScreen ? _buildStatsRow(data) : _buildStatsColumn(data),
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
                _buildRecentUpdates(data.recentUpdates),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCardsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FeatureCard(
            title: 'قائمة الموثوقين',
            description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
            icon: Icons.verified_user,
            color: Colors.green,
            onTap: () => context.goNamed(AppRouter.trusted),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FeatureCard(
            title: 'قائمة النصابين',
            description:
                'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
            icon: Icons.block,
            color: Colors.red,
            onTap: () => context.goNamed(AppRouter.untrusted),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FeatureCard(
            title: 'كيف تحمي نفسك؟',
            description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            icon: Icons.security,
            color: Colors.blue,
            onTap: () => context.goNamed(AppRouter.instruction),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCardsMediumGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'قائمة الموثوقين',
                description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                icon: Icons.verified_user,
                color: Colors.green,
                onTap: () => context.goNamed(AppRouter.trusted),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FeatureCard(
                title: 'قائمة النصابين',
                description:
                    'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                icon: Icons.block,
                color: Colors.red,
                onTap: () => context.goNamed(AppRouter.untrusted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FeatureCard(
          title: 'كيف تحمي نفسك؟',
          description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
          icon: Icons.security,
          color: Colors.blue,
          onTap: () => context.goNamed(AppRouter.instruction),
        ),
      ],
    );
  }

  Widget _buildFeatureCardsColumn(BuildContext context) {
    return Column(
      children: [
        FeatureCard(
          title: 'قائمة الموثوقين',
          description: 'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
          icon: Icons.verified_user,
          color: Colors.green,
          onTap: () => context.goNamed(AppRouter.trusted),
        ),
        const SizedBox(height: 16),
        FeatureCard(
          title: 'قائمة النصابين',
          description: 'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
          icon: Icons.block,
          color: Colors.red,
          onTap: () => context.goNamed(AppRouter.untrusted),
        ),
        const SizedBox(height: 16),
        FeatureCard(
          title: 'كيف تحمي نفسك؟',
          description: 'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
          icon: Icons.security,
          color: Colors.blue,
          onTap: () => context.goNamed(AppRouter.instruction),
        ),
      ],
    );
  }

  Widget _buildStatsRow(HomeData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatsItem(value: '${data.trustedCount}+', label: 'موثوق'),
        StatsItem(value: '${data.untrustedCount}+', label: 'نصاب'),
        StatsItem(value: '${data.totalVisitors}+', label: 'مستخدم'),
        StatsItem(value: '90%', label: 'معدل الرضا'),
      ],
    );
  }

  Widget _buildStatsColumn(HomeData data) {
    return Column(
      children: [
        StatsItem(value: '${data.trustedCount}+', label: 'موثوق'),
        const SizedBox(height: 16),
        StatsItem(value: '${data.untrustedCount}+', label: 'نصاب'),
        const SizedBox(height: 16),
        StatsItem(value: '${data.totalVisitors}+', label: 'مستخدم'),
        const SizedBox(height: 16),
        StatsItem(value: '90%', label: 'معدل الرضا'),
      ],
    );
  }

  Widget _buildRecentUpdates(List<AppUpdate> updates) {
    if (updates.isEmpty) {
      return Center(
        child: Text(
          'لا توجد تحديثات حديثة',
          style: GoogleFonts.cairo(),
        ),
      );
    }

    return Column(
      children: updates.map((update) {
        return Column(
          children: [
            UpdateItem(update: update),
            if (update != updates.last) const Divider(),
          ],
        );
      }).toList(),
    );
  }
}
