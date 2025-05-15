import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;
    final isAdmin = ref.watch(isAdminProvider);

    // Track page view
    // final analyticsService = ref.read(visitorAnalyticsProvider);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   analyticsService.trackPageView('home_screen');
    //   // OR possibly one of these:
    //   // analyticsService.logVisit('home_screen');
    //   // analyticsService.recordVisit('home_screen');
    //   // analyticsService.trackScreen('home_screen');
    // });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          isAdmin ? 'ترست فالي - لوحة التحكم' : 'ترست فالي - الصفحة الرئيسية',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'إعدادات النظام',
              onPressed: () {
                // Navigate to admin settings screen
                // You can implement this later
              },
            ),
        ],
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
                  child: isAdmin
                      ? _buildAdminDashboard(context, constraints, ref)
                      : _buildHomeContent(context, constraints),
                ),
              ),
            ],
          );
        },
      ),
      // Show quick action FAB for admins
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                _showQuickActionsMenu(context);
              },
              backgroundColor: Colors.green.shade700,
              icon: const Icon(Icons.add),
              label: Text(
                'إضافة سريعة',
                style: GoogleFonts.cairo(),
              ),
            )
          : null,
    );
  }

  void _showQuickActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'إضافة سريعة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.green),
                title: Text('إضافة مستخدم موثوق', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(ScreensNames.trusted);
                  // You can add logic to automatically open the add user dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text('إضافة مستخدم نصاب', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(ScreensNames.untrusted);
                  // You can add logic to automatically open the add user dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.announcement, color: Colors.blue),
                title: Text('إضافة تحديث جديد', style: GoogleFonts.cairo()),
                onTap: () {
                  Navigator.pop(context);
                  _showAddUpdateDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddUpdateDialog(BuildContext context) {
    // This is a placeholder - you would implement a dialog to add a new update
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة تحديث جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'عنوان التحديث',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'وصف التحديث',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement save logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Admin dashboard with analytics
  Widget _buildAdminDashboard(
      BuildContext context, BoxConstraints constraints, WidgetRef ref) {
    final analyticsData = ref.watch(analyticsDataProvider);
    final analyticsChartData = ref.watch(analyticsChartDataProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Welcome Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade600],
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
                    const Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Text(
                      'لوحة تحكم المشرف',
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'مرحباً بك في لوحة التحكم، يمكنك إدارة المستخدمين ومراقبة النشاط هنا',
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

          // Visitor Analytics Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تحليلات الزيارات',
                      style: GoogleFonts.cairo(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Refresh analytics data
                        ref.refresh(analyticsServiceProvider);
                        ref.refresh(analyticsChartDataProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('تحديث', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Display analytics data with loading state handling
                analyticsData.when(
                  data: (data) {
                    return constraints.maxWidth > 768
                        ? _buildAnalyticsRowWithData(data)
                        : _buildAnalyticsColumnWithData(data);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'حدث خطأ أثناء تحميل البيانات: $error',
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Display chart with loading state handling
                analyticsChartData.when(
                  data: (chartData) {
                    return SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: _buildVisitsChart(chartData),
                    );
                  },
                  loading: () => Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'حدث خطأ في تحميل الرسم البياني',
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Quick CRUD Activities
          Row(
            children: [
              Expanded(
                child: _buildAdminActionCard(
                  'إدارة الموثوقين',
                  'عرض وتعديل وإضافة مستخدمين موثوقين',
                  Icons.verified_user,
                  Colors.green,
                  ScreensNames.trusted,
                  context,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAdminActionCard(
                  'إدارة النصابين',
                  'عرض وتعديل وإضافة مستخدمين نصابين',
                  Icons.block,
                  Colors.red,
                  ScreensNames.untrusted,
                  context,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Recent activity with admin controls
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'آخر النشاطات',
                      style: GoogleFonts.cairo(
                        textStyle: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'إضافة نشاط جديد',
                      onPressed: () {
                        _showAddUpdateDialog(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAdminActivityList(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildAnalyticsColumn() {
    return Column(
      children: [
        _buildAnalyticItem(
          '1,245',
          'زيارة اليوم',
          Icons.trending_up,
          Colors.green,
          '+12% عن أمس',
        ),
        const SizedBox(height: 16),
        _buildAnalyticItem(
          '32,567',
          'إجمالي الزيارات',
          Icons.people,
          Colors.blue,
          '8.5K زيارة هذا الشهر',
        ),
        const SizedBox(height: 16),
        _buildAnalyticItem(
          '3:42',
          'متوسط مدة الزيارة',
          Icons.timer,
          Colors.orange,
          '+1:15 عن المتوسط',
        ),
      ],
    );
  }

  Widget _buildAnalyticItem(
      String value, String label, IconData icon, Color color, String subtext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard(String title, String description, IconData icon,
      Color color, String routeName, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => context.goNamed(routeName),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 32, color: color),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'إدارة',
                      style: GoogleFonts.cairo(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'عرض',
                    style: GoogleFonts.cairo(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActivityList() {
    return Column(
      children: [
        _buildAdminActivityItem(
          'تم إضافة 5 مستخدمين جدد إلى قائمة الموثوقين',
          '12 مايو 2025',
          true,
        ),
        const Divider(),
        _buildAdminActivityItem(
          'تم تحديث معايير التوثيق والتحقق من الهوية',
          '10 مايو 2025',
          true,
        ),
        const Divider(),
        _buildAdminActivityItem(
          'إضافة خاصية البحث المتقدم للمستخدمين',
          '5 مايو 2025',
          true,
        ),
      ],
    );
  }

  Widget _buildAdminActivityItem(String title, String date, bool isVisible) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 12, color: Colors.green.shade700),
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
          // Admin controls
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: isVisible ? Colors.green : Colors.grey,
                  size: 20,
                ),
                tooltip: isVisible ? 'إخفاء' : 'إظهار',
                onPressed: () {
                  // Toggle visibility
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                  size: 20,
                ),
                tooltip: 'تعديل',
                onPressed: () {
                  // Edit update
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 20,
                ),
                tooltip: 'حذف',
                onPressed: () {
                  // Delete update
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Regular user home content (your existing method)
  Widget _buildHomeContent(BuildContext context, BoxConstraints constraints) {
    // This is your existing _buildHomeContent method unchanged
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
                isLargeScreen ? _buildStatsRow() : _buildStatsColumn(),
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

  // Keep all your existing methods below
  Widget _buildFeatureCardsRow() {
    // Your existing implementation
    return Row(
      children: [
        Expanded(
            child: _buildFeatureCard(
                'قائمة الموثوقين',
                'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                Icons.verified_user,
                Colors.green,
                ScreensNames.trusted)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildFeatureCard(
                'قائمة النصابين',
                'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                Icons.block,
                Colors.red,
                ScreensNames.untrusted)),
        const SizedBox(width: 16),
        Expanded(
            child: _buildFeatureCard(
                'كيف تحمي نفسك؟',
                'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
                Icons.security,
                Colors.blue,
                ScreensNames.instruction)),
      ],
    );
  }

  Widget _buildFeatureCardsMediumGrid() {
    // Your existing implementation
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildFeatureCard(
                    'قائمة الموثوقين',
                    'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
                    Icons.verified_user,
                    Colors.green,
                    ScreensNames.trusted)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildFeatureCard(
                    'قائمة النصابين',
                    'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
                    Icons.block,
                    Colors.red,
                    ScreensNames.untrusted)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'كيف تحمي نفسك؟',
            'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            Icons.security,
            Colors.blue,
            ScreensNames.instruction),
      ],
    );
  }

  Widget _buildFeatureCardsColumn() {
    // Your existing implementation
    return Column(
      children: [
        _buildFeatureCard(
            'قائمة الموثوقين',
            'تصفح قائمة الأشخاص الموثوقين للتعامل معهم',
            Icons.verified_user,
            Colors.green,
            ScreensNames.trusted),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'قائمة النصابين',
            'تحقق من قائمة الأشخاص غير الموثوقين لتجنب التعامل معهم',
            Icons.block,
            Colors.red,
            ScreensNames.untrusted),
        const SizedBox(height: 16),
        _buildFeatureCard(
            'كيف تحمي نفسك؟',
            'تعلم كيفية إجراء تعاملات آمنة والحماية من النصب',
            Icons.security,
            Colors.blue,
            ScreensNames.instruction),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon,
      Color color, String routeName) {
    // Your existing implementation
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
    // Your existing implementation
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
    // Your existing implementation
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
    // Your existing implementation
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
    // Your existing implementation
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

  Widget _buildAnalyticsRowWithData(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: _buildAnalyticItem(
            data['todayVisits'].toString(),
            'زيارة اليوم',
            Icons.trending_up,
            Colors.green,
            '${data['percentChange'].toStringAsFixed(1)}% عن أمس',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticItem(
            data['totalVisitors'].toString(),
            'إجمالي الزيارات',
            Icons.people,
            Colors.blue,
            '${data['monthlyVisits']} زيارة هذا الشهر',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAnalyticItem(
            data['avgSessionDuration'],
            'متوسط مدة الزيارة',
            Icons.timer,
            Colors.orange,
            'تحديث لحظي',
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsColumnWithData(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildAnalyticItem(
          data['todayVisits'].toString(),
          'زيارة اليوم',
          Icons.trending_up,
          Colors.green,
          '${data['percentChange'].toStringAsFixed(1)}% عن أمس',
        ),
        const SizedBox(height: 16),
        _buildAnalyticItem(
          data['totalVisitors'].toString(),
          'إجمالي الزيارات',
          Icons.people,
          Colors.blue,
          '${data['monthlyVisits']} زيارة هذا الشهر',
        ),
        const SizedBox(height: 16),
        _buildAnalyticItem(
          data['avgSessionDuration'],
          'متوسط مدة الزيارة',
          Icons.timer,
          Colors.orange,
          'تحديث لحظي',
        ),
      ],
    );
  }

  Widget _buildVisitsChart(List<Map<String, dynamic>> chartData) {
    return VisitorChart(chartData: chartData);
  }
}

class VisitorChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const VisitorChart({Key? key, required this.chartData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
      ),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: chartData,
          xValueMapper: (Map<String, dynamic> data, _) => data['day'] as String,
          yValueMapper: (Map<String, dynamic> data, _) => data['visits'] as int,
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade600],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: GoogleFonts.cairo(fontSize: 10),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}
