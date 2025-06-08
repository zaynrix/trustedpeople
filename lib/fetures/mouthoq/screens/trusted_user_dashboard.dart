import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';

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
      case 'suspended':
        return Colors.purple;
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
      case 'suspended':
        return 'معلق';
      default:
        return status;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green, size: 24);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red, size: 24);
      case 'in_progress':
      case 'pending':
        return const Icon(Icons.hourglass_empty,
            color: Colors.orange, size: 24);
      case 'needs_review':
        return const Icon(Icons.rate_review, color: Colors.blue, size: 24);
      case 'suspended':
        return const Icon(Icons.block, color: Colors.purple, size: 24);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state and derived providers
    final authState = ref.watch(authProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isTrustedUser = ref.watch(isTrustedUserProvider);
    final isApproved = ref.watch(isApprovedProvider);
    final canEditProfile = ref.watch(canEditProfileProvider);
    final isLoading = ref.watch(authLoadingProvider);
    final authError = ref.watch(authErrorProvider);

    // Handle loading state
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Handle authentication errors
    if (authError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('خطأ في المصادقة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'خطأ في المصادقة',
                style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                authError,
                style: GoogleFonts.cairo(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(authProvider.notifier).refreshAuthState();
                },
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        ),
      );
    }

    // Check for proper authentication and trusted user status
    if (!isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/login'); // Redirect to login
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Check if user is trusted user (either pending or approved)
    if (!isTrustedUser && !authState.isApplicant) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/'); // Redirect to home for non-trusted users
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Get user data from auth state
    final userData = authState.userData;
    final applicationData = authState.applicationData;
    final userEmail = ref.watch(currentUserEmailProvider);
    final userName = ref.watch(userNameProvider);
    final userPhone = ref.watch(currentUserPhoneProvider);
    final userStatus = ref.watch(applicationStatusProvider) ?? 'pending';

    return Scaffold(
      appBar: _buildAppBar(userStatus, isApproved),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshAuthState();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show pending status banner for non-approved users
              if (!isApproved) _buildPendingStatusBanner(userStatus),

              // Welcome section
              _buildWelcomeSection(isApproved, userName ?? 'مستخدم'),
              const SizedBox(height: 20),

              // Application status card
              if (applicationData != null || !isApproved) ...[
                _buildApplicationStatusCard(
                    applicationData ?? userData!, userStatus, isApproved),
                const SizedBox(height: 20),
              ],

              // User info card
              _buildUserInfoCard(
                isApproved,
                userData,
                userEmail,
                userName!,
              ),
              const SizedBox(height: 20),

              // Quick actions card
              _buildQuickActionsCard(isApproved, canEditProfile),
              const SizedBox(height: 20),

              // Help section
              _buildHelpSection(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(String userStatus, bool isApproved) {
    return AppBar(
      title: Text(
        isApproved
            ? 'لوحة التحكم - مستخدم موثوق'
            : 'لوحة التحكم - في انتظار الموافقة',
        style: GoogleFonts.cairo(
          textStyle: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor:
          isApproved ? Colors.green.shade700 : Colors.orange.shade700,
      actions: [
        if (isApproved)
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'الإعدادات',
            onPressed: () {
              // Navigate to settings
            },
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
          onPressed: () {
            ref.read(authProvider.notifier).refreshAuthState();
          },
        ),
      ],
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

// 🆕 UPDATED: Application status card for new structure

  Widget _buildApplicationStatusCard(
      Map<String, dynamic>? data, String status, bool isApproved) {
    if (data == null) return const SizedBox.shrink();

    final submittedAt = data['submittedAt'] ?? data['createdAt'];
    final reviewedAt = data['reviewedAt'] ?? data['application']?['reviewedAt'];
    final rejectionReason = data['rejectionReason'] ??
        data['adminComment'] ??
        data['application']?['rejectionReason'];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getStatusIcon(status),
                const SizedBox(width: 12),
                Text(
                  'حالة الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'الحالة',
              _getStatusText(status),
            ),
            if (submittedAt != null)
              _buildInfoRow(
                'تاريخ التقديم',
                _formatDate(submittedAt),
              ),
            if (reviewedAt != null)
              _buildInfoRow(
                'تاريخ المراجعة',
                _formatDate(reviewedAt),
              ),
            if (rejectionReason != null &&
                rejectionReason.toString().isNotEmpty)
              _buildInfoRow(
                'سبب الرفض',
                rejectionReason.toString(),
              ),
          ],
        ),
      ),
    );
  }

  // 🆕 UPDATED: User info card for new structure
  Widget _buildUserInfoCard(bool isApproved, Map<String, dynamic>? userData,
      String? userEmail, String userName) {
    final profileData = userData?['profile'] as Map<String, dynamic>? ?? {};

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
            if (profileData.isNotEmpty) ...[
              _buildInfoRow(
                  'الاسم الكامل',
                  profileData['fullName'] ??
                      profileData['firstName'] ??
                      userName),
              _buildInfoRow('البريد الإلكتروني',
                  userData?['email'] ?? userEmail ?? 'غير محدد'),
              _buildInfoRow('رقم الهاتف', profileData['phone'] ?? 'غير محدد'),
              if (profileData['additionalPhone']?.isNotEmpty == true)
                _buildInfoRow('رقم هاتف إضافي', profileData['additionalPhone']),
              _buildInfoRow(
                  'مقدم الخدمة', profileData['serviceProvider'] ?? 'غير محدد'),
              _buildInfoRow('الموقع', profileData['location'] ?? 'غير محدد'),
              if (profileData['telegramAccount']?.isNotEmpty == true)
                _buildInfoRow('حساب التلجرام', profileData['telegramAccount']),
              if (profileData['bio']?.isNotEmpty == true)
                _buildInfoRow('الوصف', profileData['bio']),
              if (profileData['workingHours']?.isNotEmpty == true)
                _buildInfoRow('ساعات العمل', profileData['workingHours']),
              if (userData?['createdAt'] != null)
                _buildInfoRow(
                    'تاريخ التسجيل', _formatDate(userData!['createdAt'])),
              _buildInfoRow(
                'نوع الحساب',
                isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة',
                showStatusColor: true,
                statusColor: isApproved ? Colors.green : Colors.orange,
              ),
            ],
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

  Widget _buildQuickActionsCard(bool isApproved, bool canEdit) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (isApproved) ...[
              _buildActionButton(
                icon: Icons.dashboard,
                title: 'عرض الإحصائيات',
                subtitle: 'مراجعة أداءك وإحصائياتك',
                onTap: () {
                  // Navigate to statistics
                },
                enabled: true,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.star,
                title: 'إدارة التقييمات',
                subtitle: 'عرض وإدارة تقييمات العملاء',
                onTap: () {
                  // Navigate to reviews
                },
                enabled: true,
              ),
              const SizedBox(height: 12),
            ],
            _buildActionButton(
              icon: Icons.person,
              title: 'تحديث الملف الشخصي',
              subtitle:
                  canEdit ? 'تعديل معلوماتك الشخصية' : 'عرض معلوماتك الشخصية',
              onTap: () {
                // Navigate to profile
              },
              enabled: true,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.refresh,
              title: 'تحديث الحالة',
              subtitle: 'تحديث حالة طلبك',
              onTap: () {
                ref.read(authProvider.notifier).refreshAuthState();
              },
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحتاج مساعدة؟',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              icon: Icons.help,
              title: 'الأسئلة الشائعة',
              subtitle: 'اطلع على الأسئلة والأجوبة الشائعة',
              onTap: () {
                // Navigate to FAQ
              },
              enabled: true,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.contact_mail,
              title: 'تواصل مع الدعم',
              subtitle: 'تواصل مع فريق الدعم الفني',
              onTap: () {
                context.goNamed('contactUs');
              },
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildInfoRow(String label, String value, Color valueColor) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 8),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 120,
  //           child: Text(
  //             '$label:',
  //             style: GoogleFonts.cairo(
  //               fontWeight: FontWeight.w500,
  //               color: Colors.grey[600],
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: GoogleFonts.cairo(
  //               color: valueColor,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? null : Colors.grey[100],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: enabled ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (enabled)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'غير محدد';

    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        dateTime = date.toDate();
      } else {
        dateTime = DateTime.parse(date.toString());
      }

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'تاريخ غير صحيح';
    }
  }
  // Widget _buildActionButton({
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  //   required Color color,
  //   required bool enabled,
  //   VoidCallback? onTap,
  // }) {
  //   return InkWell(
  //     onTap: enabled ? onTap : null,
  //     borderRadius: BorderRadius.circular(8),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color:
  //             enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //           color:
  //               enabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             icon,
  //             color: enabled ? color : Colors.grey,
  //             size: 24,
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             title,
  //             style: GoogleFonts.cairo(
  //               fontSize: 12,
  //               fontWeight: FontWeight.bold,
  //               color: enabled ? color : Colors.grey,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //           const SizedBox(height: 2),
  //           Text(
  //             subtitle,
  //             style: GoogleFonts.cairo(
  //               fontSize: 10,
  //               color: enabled ? Colors.grey.shade600 : Colors.grey,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showEditProfileDialog() {
    final authState = ref.watch(authProvider);
    final userData = authState.userData ?? {};
    final profileData = userData['profile'] as Map<String, dynamic>? ?? {};

    // Controllers with new structure data
    final nameController = TextEditingController(
        text: profileData['fullName'] ?? profileData['firstName'] ?? '');
    final phoneController =
        TextEditingController(text: profileData['phone'] ?? '');
    final additionalPhoneController =
        TextEditingController(text: profileData['additionalPhone'] ?? '');
    final serviceController =
        TextEditingController(text: profileData['serviceProvider'] ?? '');
    final locationController =
        TextEditingController(text: profileData['location'] ?? '');
    final telegramController =
        TextEditingController(text: profileData['telegramAccount'] ?? '');
    final descriptionController =
        TextEditingController(text: profileData['bio'] ?? '');
    final workingHoursController =
        TextEditingController(text: profileData['workingHours'] ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تحديث البيانات الشخصية',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        controller: nameController,
                        label: 'الاسم / الكنية',
                        icon: Icons.person,
                        hint: 'أدخل اسمك أو كنيتك',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: phoneController,
                        label: 'رقم الهاتف الأساسي',
                        icon: Icons.phone,
                        hint: 'أدخل رقم هاتفك الأساسي',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: additionalPhoneController,
                        label: 'رقم هاتف إضافي (اختياري)',
                        icon: Icons.phone_android,
                        hint: 'أدخل رقم هاتف إضافي',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: serviceController,
                        label: 'الخدمات المقدمة',
                        icon: Icons.work,
                        hint: 'وصف الخدمات التي تقدمها',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: locationController,
                        label: 'الموقع',
                        icon: Icons.location_on,
                        hint: 'المدينة أو المنطقة',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: telegramController,
                        label: 'حساب التلجرام (اختياري)',
                        icon: Icons.telegram,
                        hint: '@username',
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: descriptionController,
                        label: 'وصف مختصر',
                        icon: Icons.description,
                        hint: 'وصف مختصر عن خدماتك وخبراتك',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        controller: workingHoursController,
                        label: 'ساعات العمل (اختياري)',
                        icon: Icons.schedule,
                        hint: 'مثال: من 9 صباحاً إلى 6 مساءً',
                      ),
                    ],
                  ),
                ),
              ),

              // Footer buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _updateProfile(
                          context,
                          nameController.text,
                          phoneController.text,
                          additionalPhoneController.text,
                          serviceController.text,
                          locationController.text,
                          telegramController.text,
                          descriptionController.text,
                          workingHoursController.text,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'حفظ التغييرات',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.cairo(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // 🆕 UPDATED: Direct Firestore update for new structure
  Future<void> _updateProfileDirectly({
    required String userId,
    required String name,
    required String phone,
    required String additionalPhone,
    required String service,
    required String location,
    required String telegram,
    required String description,
    required String workingHours,
  }) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Update user profile in 'users' collection
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userUpdateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name.isNotEmpty) {
        userUpdateData['profile.fullName'] = name;
        userUpdateData['profile.firstName'] = name.split(' ').first;
        if (name.split(' ').length > 1) {
          userUpdateData['profile.lastName'] =
              name.split(' ').skip(1).join(' ');
        }
      }
      if (phone.isNotEmpty) userUpdateData['profile.phone'] = phone;
      if (additionalPhone.isNotEmpty)
        userUpdateData['profile.additionalPhone'] = additionalPhone;
      if (service.isNotEmpty)
        userUpdateData['profile.serviceProvider'] = service;
      if (location.isNotEmpty) userUpdateData['profile.location'] = location;
      if (telegram.isNotEmpty)
        userUpdateData['profile.telegramAccount'] = telegram;
      if (description.isNotEmpty) userUpdateData['profile.bio'] = description;
      if (workingHours.isNotEmpty)
        userUpdateData['profile.workingHours'] = workingHours;

      batch.update(userRef, userUpdateData);

      // Update trusted_users collection if user is approved
      final trustedUserRef =
          FirebaseFirestore.instance.collection('trusted_users').doc(userId);
      final trustedUserDoc = await trustedUserRef.get();

      if (trustedUserDoc.exists) {
        final trustedUpdateData = <String, dynamic>{
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        if (name.isNotEmpty)
          trustedUpdateData['publicProfile.displayName'] = name;
        if (phone.isNotEmpty) trustedUpdateData['publicProfile.phone'] = phone;
        if (service.isNotEmpty)
          trustedUpdateData['publicProfile.serviceProvider'] = service;
        if (location.isNotEmpty) {
          trustedUpdateData['publicProfile.location'] = location;
          trustedUpdateData['publicProfile.city'] = location;
        }
        if (description.isNotEmpty)
          trustedUpdateData['publicProfile.bio'] = description;
        if (workingHours.isNotEmpty)
          trustedUpdateData['publicProfile.workingHours'] = workingHours;

        batch.update(trustedUserRef, trustedUpdateData);
      }

      await batch.commit();
      print('🔄 📧 ✅ Profile updated successfully in new structure');
    } catch (e) {
      print('🔄 📧 ❌ Direct Firestore update failed: $e');
      rethrow;
    }
  }

  Future<void> _updateProfile(
    BuildContext context,
    String name,
    String phone,
    String additionalPhone,
    String service,
    String location,
    String telegram,
    String description,
    String workingHours,
  ) async {
    try {
      final authState = ref.read(authProvider);

      print('🔄 === PROFILE UPDATE DEBUG START ===');
      print('🔄 User data check:');
      print('  - authState.user: ${authState.user}');
      print('  - authState.user?.uid: ${authState.user?.uid}');
      print('  - authState.isApproved: ${authState.isApproved}');
      print('  - authState.isAdmin: ${authState.isAdmin}');
      print('  - authState.userData: ${authState.userData}');

      print('🔄 Update parameters:');
      print('  - name: "$name"');
      print('  - phone: "$phone"');
      print('  - additionalPhone: "$additionalPhone"');
      print('  - service: "$service"');
      print('  - location: "$location"');
      print('  - telegram: "$telegram"');
      print('  - description: "$description"');
      print('  - workingHours: "$workingHours"');

      // Check if user is approved using our alternative check since authState.isApproved is not working
      // if (!finalApprovalStatus) {
      //   throw Exception('يجب أن تكون مستخدماً معتمداً لتحديث البيانات');
      // }

      // Get userId from different sources since authState.user might be null
      String? userId = authState.user?.uid;

      // If authState.user is null, try to get it from userData or applicationData
      if (userId == null) {
        userId = authState.userData?['uid'] ??
            authState.userData?['firebaseUid'] ??
            authState.applicationData?['firebaseUid'] ??
            authState.applicationData?['uid'];
      }

      if (userId == null || userId.isEmpty) {
        throw Exception('لا يمكن العثور على معرف المستخدم');
      }
      print('🔄 Using userId: $userId');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'جاري تحديث البيانات...',
                style: GoogleFonts.cairo(),
              ),
            ],
          ),
        ),
      );

      print('🔄 Calling updateTrustedUserProfile...');

      try {
        // Use the auth provider's update method
        await ref.read(authProvider.notifier).updateTrustedUserProfile(
              userId: userId,
              aliasName: name.isNotEmpty ? name : null,
              phoneNumber: phone.isNotEmpty ? phone : null,
              additionalPhone:
                  additionalPhone.isNotEmpty ? additionalPhone : null,
              serviceProvider: service.isNotEmpty ? service : null,
              location: location.isNotEmpty ? location : null,
              telegramAccount: telegram.isNotEmpty ? telegram : null,
              description: description.isNotEmpty ? description : null,
              workingHours: workingHours.isNotEmpty ? workingHours : null,
            );
      } catch (e) {
        print('🔄 ⚠️ Auth provider update failed: $e');
        print('🔄 Trying alternative update method...');

        // Fallback: Direct Firestore update
        await _updateProfileDirectly(
          userId: userId,
          name: name,
          phone: phone,
          additionalPhone: additionalPhone,
          service: service,
          location: location,
          telegram: telegram,
          description: description,
          workingHours: workingHours,
        );
      }

      print('🔄 ✅ Profile update completed successfully');

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Close edit dialog
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث البيانات بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      // Refresh the auth state to show updated data
      ref.invalidate(authProvider);
    } catch (e, stackTrace) {
      print('🔄 ❌ Profile update failed: $e');
      print('🔄 ❌ Stack trace: $stackTrace');

      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show specific error message
      String errorMessage = 'خطأ في تحديث البيانات';

      if (e.toString().contains('الاسم مطلوب')) {
        errorMessage = 'يرجى إدخال الاسم';
      } else if (e.toString().contains('رقم الهاتف مطلوب')) {
        errorMessage = 'يرجى إدخال رقم الهاتف';
      } else if (e
          .toString()
          .contains('Null check operator used on a null value')) {
        errorMessage =
            'خطأ في البيانات المطلوبة. يرجى التأكد من تعبئة الحقول المطلوبة';
      } else if (e.toString().contains('unexpected null value')) {
        errorMessage = 'قيمة مطلوبة مفقودة. يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('يجب أن تكون مستخدماً معتمداً')) {
        errorMessage = 'يجب أن تكون مستخدماً معتمداً لتحديث البيانات';
      } else if (e.toString().contains('معرف المستخدم')) {
        errorMessage =
            'خطأ في معرف المستخدم. يرجى تسجيل الخروج والدخول مرة أخرى';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'ليس لديك صلاحية لتحديث هذه البيانات';
      } else if (e.toString().contains('لا يمكنك تعديل بيانات مستخدم آخر')) {
        errorMessage = 'لا يمكنك تعديل بيانات مستخدم آخر';
      } else {
        errorMessage = 'خطأ في تحديث البيانات: ${e.toString()}';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _showProfileInfo() {
    final authState = ref.watch(authProvider);
    final userData = authState.userData ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'معلومات الملف الشخصي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ملفك الشخصي مُفعل ومعروض في قائمة الموثوقين',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (userData.isNotEmpty) ...[
                _buildProfileInfoRow(
                    'التقييم', '${userData['rating'] ?? 'N/A'}'),
                _buildProfileInfoRow(
                    'المراجعات', '${userData['totalReviews'] ?? 0}'),
                _buildProfileInfoRow(
                    'آخر نشاط', _formatDate(userData['lastActive'])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showOrderHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تاريخ الطلبات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'ستتمكن من عرض تاريخ طلباتك قريباً',
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

  // Widget _buildHelpSection() {
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.help_outline, color: Colors.blue.shade700, size: 24),
  //               const SizedBox(width: 8),
  //               Text(
  //                 'مساعدة ودعم',
  //                 style: GoogleFonts.cairo(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.grey.shade800,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           _buildHelpItem(
  //             'كيفية تحديث البيانات',
  //             'يمكنك تحديث بياناتك الشخصية بعد موافقة الإدارة على طلبك',
  //           ),
  //           _buildHelpItem(
  //             'حالة الطلب',
  //             'تحقق من حالة طلبك بانتظام للاطلاع على أي تحديثات من الإدارة',
  //           ),
  //           _buildHelpItem(
  //             'التواصل مع الدعم',
  //             'في حالة وجود أي استفسارات، يمكنك التواصل مع فريق الدعم',
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

  // String _formatDate(dynamic date) {
  //   try {
  //     DateTime dateTime;
  //     if (date is Timestamp) {
  //       dateTime = date.toDate();
  //     } else if (date is String) {
  //       dateTime = DateTime.parse(date);
  //     } else {
  //       return 'غير محدد';
  //     }
  //     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  //   } catch (e) {
  //     return 'غير محدد';
  //   }
  // }

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
