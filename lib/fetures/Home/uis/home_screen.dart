import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/adminActivitiesWidget.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/userRecentUpdatesWidget.dart';
import 'package:trustedtallentsvalley/providers/analytics_provider2.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

import '../../auth/admin_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        backgroundColor: isAdmin ? Colors.green.shade700 : Colors.teal,
        title: Text(
          isAdmin ? 'موثوق - لوحة التحكم' : 'موثوق - الصفحة الرئيسية',
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
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('إضافة تحديث جديد',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان التحديث';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف التحديث';
                    }
                    return null;
                  },
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          // Get a reference to Firestore
                          final FirebaseFirestore firestore =
                              FirebaseFirestore.instance;

                          // Create the update object
                          final Map<String, dynamic> updateData = {
                            'title': titleController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'date': FieldValue.serverTimestamp(),
                            'version':
                                '1.0.${DateTime.now().millisecondsSinceEpoch % 1000}',
                            // Generate a simple version number
                          };

                          // Add the update to Firestore
                          await firestore
                              .collection('app_updates')
                              .add(updateData);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إضافة التحديث بنجاح',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Close the dialog
                          Navigator.pop(context);
                        } catch (e) {
                          // Show error message
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ: ${e.toString()}',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Admin dashboard with analytics
  Widget _buildAdminDashboard(
      BuildContext context, BoxConstraints constraints, WidgetRef ref) {
    final analyticsChartData = ref.watch(analyticsChartDataProvider);
    final analyticsData = ref.watch(analyticsDataProvider);

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
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أدوات تشخيص الزيارات',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text('تحديث البيانات', style: GoogleFonts.cairo()),
                      onPressed: () {
                        // Refresh analytics data
                        ref.refresh(analyticsDataProvider);
                      },
                    ),
                    const SizedBox(width: 16),
                    // ElevatedButton.icon(
                    //   icon: const Icon(Icons.add),
                    //   label:
                    //       Text('تسجيل زيارة جديدة', style: GoogleFonts.cairo()),
                    //   onPressed: () async {
                    //     final success = await ref
                    //         .read(visitorAnalyticsProvider)
                    //         .();
                    //
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Text(
                    //           success
                    //               ? 'تم تسجيل زيارة جديدة بنجاح'
                    //               : 'فشل تسجيل الزيارة الجديدة',
                    //           style: GoogleFonts.cairo(),
                    //         ),
                    //         backgroundColor:
                    //             success ? Colors.green : Colors.red,
                    //       ),
                    //     );
                    //
                    //     // Refresh the data
                    //     ref.refresh(analyticsDataProvider);
                    //   },
                    // ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<String?>(
                  future: Future.value(kIsWeb
                      ? html.window.localStorage['last_visit_date']
                      : null),
                  builder: (context, snapshot) {
                    return Text(
                      'آخر زيارة مسجلة: ${snapshot.data ?? 'غير متوفر'}',
                      style: GoogleFonts.cairo(),
                    );
                  },
                ),
              ],
            ),
          ),
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
                        ? Consumer(
                            builder: (context, ref, child) {
                              final analyticsAsync =
                                  ref.watch(analyticsDataProvider);

                              return analyticsAsync.when(
                                data: (data) =>
                                    _buildAnalyticsRowWithData(data, context),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, stack) => Center(
                                  child: Text(
                                    'Error loading analytics: $error',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildAnalyticsColumnWithData(data, context);
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
          Card(
              child: ListTile(
            leading: Icon(Icons.block, color: Colors.red),
            title: Text('المستخدمين المحظورين', style: GoogleFonts.cairo()),
            subtitle: Text(
              'إدارة المستخدمين المحظورين من الوصول للموقع',
              style: GoogleFonts.cairo(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.pushNamed(ScreensNames.blockedUsers),
            ),
          )),
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
          const AdminActivityWidget(),
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

  Widget _buildAnalyticItem(
    String value,
    String label,
    IconData icon,
    Color color,
    String subtext, {
    VoidCallback? onTap, // Optional callback function
  }) {
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
              // Show arrow icon only if onTap is provided
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: color.withOpacity(0.7),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_updates')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'حدث خطأ في تحميل البيانات: ${snapshot.error}',
                style: GoogleFonts.cairo(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final updates = snapshot.data?.docs ?? [];

        if (updates.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.info_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد تحديثات حتى الآن',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: updates.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final update = updates[index].data() as Map<String, dynamic>;
            final updateId = updates[index].id;

            // Format date
            String formattedDate = 'تاريخ غير محدد';
            if (update['date'] != null) {
              final timestamp = update['date'] as Timestamp;
              final date = timestamp.toDate();
              formattedDate =
                  '${date.day} ${_getArabicMonth(date.month)} ${date.year}';
            }

            return _buildAdminActivityItem(
              update['title'] ?? 'بدون عنوان',
              formattedDate,
              true,
              onEdit: () => _editUpdate(context, updateId, update),
              onDelete: () => _confirmDeleteUpdate(context, updateId),
            );
          },
        );
      },
    );
  }

// Helper method to get Arabic month names
  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

// Add these methods to handle edit and delete functionality
  void _editUpdate(
      BuildContext context, String updateId, Map<String, dynamic> updateData) {
    final titleController = TextEditingController(text: updateData['title']);
    final descriptionController =
        TextEditingController(text: updateData['description']);
    bool isLoading = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تعديل التحديث',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال عنوان التحديث';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف التحديث',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال وصف التحديث';
                    }
                    return null;
                  },
                ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          await FirebaseFirestore.instance
                              .collection('app_updates')
                              .doc(updateId)
                              .update({
                            'title': titleController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'lastEdited': FieldValue.serverTimestamp(),
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم تحديث البيانات بنجاح',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('حدث خطأ: ${e.toString()}',
                                  style: GoogleFonts.cairo()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              child: Text('حفظ التغييرات',
                  style: GoogleFonts.cairo(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUpdate(BuildContext context, String updateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من حذف هذا التحديث؟ لا يمكن التراجع عن هذه العملية.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('app_updates')
                    .doc(updateId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف التحديث بنجاح',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء الحذف: ${e.toString()}',
                        style: GoogleFonts.cairo()),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

// Update the _buildAdminActivityItem to include edit and delete options
  Widget _buildAdminActivityItem(
    String title,
    String date,
    bool isActive, {
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 5, left: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null && onDelete != null)
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'تعديل',
                  iconSize: 20,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                  iconSize: 20,
                ),
              ],
            ),
        ],
      ),
    );
  }

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
                isLargeScreen ? _buildStatsRow() : _buildStatsColumn(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const UserActivityWidget(),
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

  final analyticsDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
    final analytics = ref.watch(visitorAnalyticsProvider);

    // Create a stream that refreshes every 30 seconds
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      final data = await analytics.getVisitorStats();
      return data;
    }).asyncMap((future) => future);
  });

  Widget _buildAnalyticsRowWithData(
      Map<String, dynamic> data, BuildContext context) {
    // Add debug print to see what data is being received
    debugPrint('Analytics data: $data');

    // Handle null or empty data
    if (data == null || data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Fix property name mismatch - monthlyVisits vs monthlyVisitors
    final monthlyVisits = data['monthlyVisitors'] ?? data['monthlyVisits'] ?? 0;

    // Ensure all values are properly formatted to avoid null errors
    final todayVisitors = data['todayVisitors'] ?? 0;
    final percentChange = data['percentChange'] ?? 0.0;
    final totalVisitors = data['totalVisitors'] ?? 0;
    final avgSessionDuration = data['avgSessionDuration'] ?? '0:00';

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              // Use GoRouter.of(context) instead of context extension
              GoRouter.of(context).goNamed(ScreensNames.adminDashboard);
            },
            child: _buildAnalyticItem(
              todayVisitors.toString(),
              'زيارة اليوم',
              Icons.trending_up,
              Colors.green,
              '${percentChange.toStringAsFixed(1)}% عن أمس',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () {
              GoRouter.of(context).goNamed('adminDashboard');
            },
            child: _buildAnalyticItem(
              totalVisitors.toString(),
              'إجمالي الزيارات',
              Icons.people,
              Colors.blue,
              '$monthlyVisits زيارة هذا الشهر',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () {
              GoRouter.of(context).goNamed('adminDashboard');
            },
            child: _buildAnalyticItem(
              avgSessionDuration,
              'متوسط مدة الزيارة',
              Icons.timer,
              Colors.orange,
              'تحديث لحظي',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsColumnWithData(Map<String, dynamic> data, context) {
    return Column(
      children: [
        InkWell(
          onTap: () => context.goNamed('admin_dashboard'),
          child: _buildAnalyticItem(
            onTap: () {
              print("clicked");
              context.goNamed('admin_dashboard');
            }, // Use context from the build method

            data['todayVisits'].toString(),
            'زيارة اليوم',
            Icons.trending_up,
            Colors.green,
            '${data['percentChange'].toStringAsFixed(1)}% عن أمس',
          ),
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
