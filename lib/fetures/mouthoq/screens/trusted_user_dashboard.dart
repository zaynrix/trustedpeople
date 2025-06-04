import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class TrustedUserDashboard extends ConsumerStatefulWidget {
  const TrustedUserDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<TrustedUserDashboard> createState() =>
      _TrustedUserDashboardState();
}

class _TrustedUserDashboardState extends ConsumerState<TrustedUserDashboard> {
  @override
  void initState() {
    super.initState();
    print("🏠 Dashboard: initState called");
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
      case 'pending':
        return Colors.orange;
      case 'needs_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'in_progress':
      case 'pending':
        return 'قيد المراجعة';
      case 'needs_review':
        return 'يحتاج مراجعة';
      default:
        return status;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icon(Icons.check_circle, color: Colors.green, size: 24);
      case 'rejected':
        return Icon(Icons.cancel, color: Colors.red, size: 24);
      case 'in_progress':
      case 'pending':
        return Icon(Icons.hourglass_empty, color: Colors.orange, size: 24);
      case 'needs_review':
        return Icon(Icons.rate_review, color: Colors.blue, size: 24);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    print('🏠 Dashboard build() called');
    print('🏠 Current route: ${GoRouterState.of(context).uri}');
    print('🏠 Auth state check:');
    print('  - isAuthenticated: ${authState.isAuthenticated}');
    print('  - isTrustedUser: ${authState.isTrustedUser}');
    print('  - isApproved: ${authState.isApproved}');
    print('  - user: ${authState.user?.email ?? 'null'}');
    print('  - userEmail: ${authState.userEmail ?? 'null'}');
    print('  - userData: ${authState.userData != null}');
    print('  - applicationData: ${authState.applicationData != null}');

    // FIXED: Check for authentication state properly
    if (!authState.isAuthenticated || !authState.isTrustedUser) {
      print('🏠 ❌ User not authenticated or not trusted, redirecting to login');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/secure-trusted-895623/login');
        }
      });

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // FIXED: Get user data from auth state
    Map<String, dynamic>? userData;
    Map<String, dynamic>? applicationData;
    String? userEmail;
    String? userName;
    String userStatus = 'pending';
    bool isApproved = authState.isApproved;

    // Get data from auth state (much simpler!)
    userData = authState.userData;
    applicationData = authState.applicationData;
    userEmail =
        authState.user?.email ?? authState.userEmail ?? userData?['email'];
    userName =
        userData?['fullName'] ?? authState.user?.displayName ?? 'مستخدم موثوق';

    // Determine status
    if (applicationData != null) {
      userStatus = applicationData['status'] ?? 'pending';
    } else if (userData != null) {
      userStatus = userData['status'] ?? (isApproved ? 'approved' : 'pending');
    }

    print('🏠 ✅ User data resolved:');
    print('  - Email: $userEmail');
    print('  - Name: $userName');
    print('  - Status: $userStatus');
    print('  - isApproved: $isApproved');

    // Dashboard theme based on status
    Color getAppBarColor() {
      switch (userStatus.toLowerCase()) {
        case 'approved':
          return Colors.green.shade800;
        case 'rejected':
          return Colors.red.shade800;
        case 'in_progress':
        case 'pending':
        case 'needs_review':
          return Colors.orange.shade800;
        default:
          return Colors.grey.shade800;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الموثوق',
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: getAppBarColor(),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Just refresh the auth state
              ref.invalidate(authProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh auth state
          ref.invalidate(authProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show status banner for pending users
              if (!isApproved) _buildPendingStatusBanner(userStatus),

              _buildWelcomeSection(isApproved, userName!),
              const SizedBox(height: 20),

              if (applicationData != null) ...[
                _buildApplicationStatusCard(applicationData, userStatus),
                const SizedBox(height: 20),
              ],

              _buildUserInfoCard(
                  isApproved, userData, applicationData, userEmail, userName!),
              const SizedBox(height: 20),

              _buildQuickActionsCard(isApproved),
              const SizedBox(height: 20),

              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingStatusBanner(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.orange.shade700,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'طلبك قيد المراجعة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'سيتم تفعيل جميع الميزات بعد موافقة الإدارة على طلبك',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(bool isApproved, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApproved
              ? [Colors.blue.shade700, Colors.blue.shade500]
              : [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isApproved ? Colors.blue : Colors.orange).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              isApproved ? Icons.verified_user : Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، $userName',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isApproved ? 'مستخدم موثوق ومُفعل' : 'في انتظار الموافقة',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationStatusCard(
      Map<String, dynamic> applicationData, String status) {
    final adminComment = applicationData['adminComment'] ?? '';
    final updatedAt = applicationData['updatedAt'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة طلبك',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Status indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: _getStatusColor(status).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  _getStatusIcon(status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusText(status),
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                        if (updatedAt != null)
                          Text(
                            'آخر تحديث: ${_formatDate(updatedAt)}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Admin comment
            if (adminComment.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملاحظات الإدارة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      adminComment,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(
      bool isApproved,
      Map<String, dynamic>? userData,
      Map<String, dynamic>? applicationData,
      String? userEmail,
      String userName) {
    // Use userData if available, otherwise use applicationData
    final displayData = userData ?? applicationData ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person,
                    color: isApproved
                        ? Colors.blue.shade700
                        : Colors.orange.shade700,
                    size: 24),
                const SizedBox(width: 8),
                Text(
                  'معلوماتك الشخصية',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isApproved
                          ? Colors.green.shade300
                          : Colors.orange.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isApproved ? Icons.verified : Icons.pending,
                        size: 14,
                        color: isApproved
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isApproved ? 'مُفعل' : 'في الانتظار',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isApproved
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (displayData.isNotEmpty) ...[
              _buildInfoRow(
                  'الاسم الكامل', displayData['fullName'] ?? userName),
              _buildInfoRow('البريد الإلكتروني',
                  displayData['email'] ?? userEmail ?? 'غير محدد'),
              _buildInfoRow(
                  'رقم الهاتف', displayData['phoneNumber'] ?? 'غير محدد'),
              if (displayData['additionalPhone']?.isNotEmpty == true)
                _buildInfoRow('رقم هاتف إضافي', displayData['additionalPhone']),
              _buildInfoRow(
                  'مقدم الخدمة', displayData['serviceProvider'] ?? 'غير محدد'),
              _buildInfoRow('الموقع', displayData['location'] ?? 'غير محدد'),
              if (displayData['createdAt'] != null)
                _buildInfoRow(
                    'تاريخ التسجيل', _formatDate(displayData['createdAt'])),
              _buildInfoRow(
                'نوع الحساب',
                isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة',
                showStatusColor: true,
                statusColor: isApproved ? Colors.green : Colors.orange,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'لا توجد معلومات متاحة حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Show note for pending users
            if (!isApproved) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم إتاحة تحديث المعلومات بعد موافقة الإدارة على طلبك',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool showStatusColor = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: showStatusColor
                    ? statusColor?.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: showStatusColor
                      ? statusColor?.withOpacity(0.3) ?? Colors.grey.shade300
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  if (showStatusColor && statusColor != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: showStatusColor
                            ? statusColor
                            : Colors.grey.shade800,
                        fontWeight: showStatusColor
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(bool isApproved) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإجراءات السريعة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  title: 'تحديث البيانات',
                  subtitle: isApproved ? 'تحديث معلوماتك' : 'غير متاح',
                  color: isApproved ? Colors.blue : Colors.grey,
                  enabled: isApproved,
                  onTap: isApproved ? () => _showEditProfileDialog() : null,
                ),
                _buildActionButton(
                  icon: Icons.history,
                  title: 'تاريخ الطلبات',
                  subtitle: isApproved ? 'عرض الطلبات' : 'غير متاح',
                  color: isApproved ? Colors.green : Colors.grey,
                  enabled: isApproved,
                  onTap: isApproved ? () {} : null,
                ),
                _buildActionButton(
                  icon: Icons.info,
                  title: 'حالة الطلب',
                  subtitle: 'عرض التفاصيل',
                  color: Colors.orange,
                  enabled: true,
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.support,
                  title: 'الدعم الفني',
                  subtitle: 'تواصل معنا',
                  color: Colors.purple,
                  enabled: true,
                  onTap: () => _showContactDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                enabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: enabled ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: enabled ? Colors.grey.shade600 : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'مساعدة ودعم',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              'كيفية تحديث البيانات',
              'يمكنك تحديث بياناتك الشخصية بعد موافقة الإدارة على طلبك',
            ),
            _buildHelpItem(
              'حالة الطلب',
              'تحقق من حالة طلبك بانتظام للاطلاع على أي تحديثات من الإدارة',
            ),
            _buildHelpItem(
              'التواصل مع الدعم',
              'في حالة وجود أي استفسارات، يمكنك التواصل مع فريق الدعم',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date is Timestamp) {
        dateTime = date.toDate();
      } else if (date is String) {
        dateTime = DateTime.parse(date);
      } else {
        return 'غير محدد';
      }
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تحديث المعلومات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ستتمكن من تحديث معلوماتك قريباً',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('حسناً', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تواصل معنا', style: GoogleFonts.cairo()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك التواصل معنا عبر:', style: GoogleFonts.cairo()),
            const SizedBox(height: 12),
            Text('• البريد الإلكتروني: support@example.com',
                style: GoogleFonts.cairo()),
            Text('• الهاتف: +966123456789', style: GoogleFonts.cairo()),
            Text('• ساعات العمل: 9 صباحاً - 5 مساءً',
                style: GoogleFonts.cairo()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج', style: GoogleFonts.cairo()),
        content: Text('هل تريد تسجيل الخروج؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (mounted) {
                context.go('/secure-trusted-895623/login');
              }
            },
            child: Text('تسجيل الخروج',
                style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
