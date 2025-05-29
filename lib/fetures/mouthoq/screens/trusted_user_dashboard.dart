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
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _applicationData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    debugPrint("This start load");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final authState = ref.read(authProvider);

      if (authState.user != null) {
        // Get user data
        _userData = await authNotifier.getCurrentUserData();

        // Get application data if available
        if (_userData != null && _userData!['email'] != null) {
          try {
            _applicationData =
                await authNotifier.getApplicationStatus(_userData!['email']);
          } catch (e) {
            // Application data might not exist for some users
            print('No application data found: $e');
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'مقبول':
        return Colors.green;
      case 'rejected':
      case 'مرفوض':
        return Colors.red;
      case 'in_progress':
      case 'قيد المراجعة':
        return Colors.orange;
      case 'needs_review':
      case 'يحتاج مراجعة':
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
      case 'مقبول':
        return Icon(Icons.check_circle, color: Colors.green, size: 24);
      case 'rejected':
      case 'مرفوض':
        return Icon(Icons.cancel, color: Colors.red, size: 24);
      case 'in_progress':
      case 'قيد المراجعة':
        return Icon(Icons.hourglass_empty, color: Colors.orange, size: 24);
      case 'needs_review':
      case 'يحتاج مراجعة':
        return Icon(Icons.rate_review, color: Colors.blue, size: 24);
      default:
        return Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الموثوق',
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 20),
                        if (_applicationData != null) ...[
                          _buildApplicationStatusCard(),
                          const SizedBox(height: 20),
                        ],
                        _buildUserInfoCard(),
                        const SizedBox(height: 20),
                        _buildQuickActionsCard(),
                        const SizedBox(height: 20),
                        _buildHelpSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName =
        _userData?['fullName'] ?? _userData?['displayName'] ?? 'المستخدم';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.verified_user,
                    size: 35,
                    color: Colors.white,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مستخدم موثوق',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'أهلاً بك في لوحة تحكم المستخدمين الموثوقين',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationStatusCard() {
    final status = _applicationData!['status'] ?? 'unknown';
    final adminComment = _applicationData!['adminComment'] ?? '';
    final updatedAt = _applicationData!['updatedAt'];

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

            // Status-based actions
            const SizedBox(height: 16),
            _buildStatusActions(status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusActions(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'مقبول':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.celebration, color: Colors.green.shade600, size: 32),
              const SizedBox(height: 8),
              Text(
                'تهانينا! تم قبول طلبك',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'حسابك نشط ويمكنك الاستفادة من جميع الخدمات',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case 'rejected':
      case 'مرفوض':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red.shade600, size: 32),
              const SizedBox(height: 8),
              Text(
                'تم رفض الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى مراجعة الملاحظات وتقديم طلب جديد',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      case 'needs_review':
      case 'يحتاج مراجعة':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.rate_review, color: Colors.blue.shade600, size: 32),
              const SizedBox(height: 8),
              Text(
                'يحتاج مراجعة إضافية',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى مراجعة الملاحظات وتقديم المعلومات المطلوبة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );

      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.hourglass_empty,
                  color: Colors.orange.shade600, size: 32),
              const SizedBox(height: 8),
              Text(
                'طلبك قيد المراجعة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سيتم إشعارك عند اتخاذ قرار بشأن طلبك',
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
  }

  Widget _buildUserInfoCard() {
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
                Icon(Icons.person, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'معلوماتك الشخصية',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_userData != null) ...[
              _buildInfoRow(
                  'الاسم الكامل', _userData!['fullName'] ?? 'غير محدد'),
              _buildInfoRow(
                  'البريد الإلكتروني', _userData!['email'] ?? 'غير محدد'),
              _buildInfoRow(
                  'رقم الهاتف', _userData!['phoneNumber'] ?? 'غير محدد'),
              if (_userData!['additionalPhone']?.isNotEmpty == true)
                _buildInfoRow('رقم هاتف إضافي', _userData!['additionalPhone']),
              _buildInfoRow(
                  'مقدم الخدمة', _userData!['serviceProvider'] ?? 'غير محدد'),
              _buildInfoRow('الموقع', _userData!['location'] ?? 'غير محدد'),
              if (_userData!['createdAt'] != null)
                _buildInfoRow(
                    'تاريخ إنشاء الحساب', _formatDate(_userData!['createdAt'])),
            ] else ...[
              Text(
                'لا توجد معلومات متاحة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
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
                Icon(Icons.dashboard, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                Text(
                  'إجراءات سريعة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick action buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'تحديث البيانات',
                  Icons.edit,
                  Colors.blue,
                  () => _showUpdateDataDialog(),
                ),
                _buildQuickActionButton(
                  'تحقق من الحالة',
                  Icons.refresh,
                  Colors.green,
                  () => _loadUserData(),
                ),
                _buildQuickActionButton(
                  'تواصل معنا',
                  Icons.support_agent,
                  Colors.orange,
                  () => _showContactDialog(),
                ),
                _buildQuickActionButton(
                  'الإعدادات',
                  Icons.settings,
                  Colors.grey,
                  () => _showSettingsDialog(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 140,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: GoogleFonts.cairo(fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              'يمكنك تحديث بياناتك الشخصية من خلال النقر على "تحديث البيانات"',
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'خطأ غير معروف',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
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
                context.go('/trusted-login');
              }
            },
            child: Text('تسجيل الخروج',
                style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديث البيانات', style: GoogleFonts.cairo()),
        content: Text(
          'سيتم إضافة هذه الميزة قريباً. يمكنك التواصل مع الدعم لتحديث بياناتك حالياً.',
          style: GoogleFonts.cairo(),
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإعدادات', style: GoogleFonts.cairo()),
        content: Text(
          'إعدادات الحساب ستكون متاحة قريباً.',
          style: GoogleFonts.cairo(),
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
}
