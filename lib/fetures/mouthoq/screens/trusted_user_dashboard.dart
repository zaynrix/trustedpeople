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
    print("🏠 Dashboard: Starting to load user data");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);

      print("🏠 Dashboard: Auth state:");
      print("  - isAuthenticated: ${authState.isAuthenticated}");
      print("  - isApproved: ${authState.isApproved}");
      print("  - isTrustedUser: ${authState.isTrustedUser}");
      print("  - user: ${authState.user?.email}");
      print("  - userEmail: ${authState.userEmail}");
      print("  - userData available: ${authState.userData != null}");
      print(
          "  - applicationData available: ${authState.applicationData != null}");

      if (authState.isApproved && authState.user != null) {
        print("🏠 Dashboard: Loading data for APPROVED user");
        // Approved user - get Firebase user data
        final authNotifier = ref.read(authProvider.notifier);
        _userData = await authNotifier.getCurrentUserData();

        print("🏠 Dashboard: Got user data: ${_userData != null}");

        if (_userData != null && _userData!['email'] != null) {
          try {
            _applicationData =
                await authNotifier.getApplicationStatus(_userData!['email']);
            print(
                "🏠 Dashboard: Got application data: ${_applicationData != null}");
          } catch (e) {
            print('🏠 Dashboard: No application data found: $e');
          }
        }
      } else if (!authState.isApproved && authState.applicationData != null) {
        print("🏠 Dashboard: Loading data for PENDING user");
        // Pending user - use application data
        _applicationData = authState.applicationData;
        _userData =
            authState.userData; // This should now be set from the signin method

        print("🏠 Dashboard: Pending user data:");
        print("  - userData: ${_userData != null}");
        print("  - applicationData: ${_applicationData != null}");
        print("  - user name: ${_userData?['fullName']}");
      } else {
        print("🏠 Dashboard: No valid auth state found");
        setState(() {
          _errorMessage = 'لم يتم العثور على بيانات المستخدم';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      print("🏠 Dashboard: Data loading completed successfully");
    } catch (e) {
      print("🏠 Dashboard: Error loading user data: $e");
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
    final authState = ref.watch(authProvider);
    final isApproved = authState.isApproved;
    final userStatus = _userData?['status']?.toLowerCase() ?? '';
    // Determine dashboard theme based on status
    Color getAppBarColor() {
      switch (userStatus) {
        case 'approved':
          return Colors.green.shade800;
        case 'rejected':
          return Colors.red.shade800;
        case 'in_progress':
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
                        // Show status banner for pending users
                        if (!isApproved) _buildPendingStatusBanner(),
                        _buildWelcomeSection(isApproved),
                        const SizedBox(height: 20),
                        if (_applicationData != null) ...[
                          _buildApplicationStatusCard(),
                          const SizedBox(height: 20),
                        ],
                        _buildUserInfoCard(isApproved),
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

  Widget _buildPendingStatusBanner() {
    final status = _applicationData?['status'] ?? 'in_progress';

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

  Widget _buildWelcomeSection(bool isApproved) {
    final userName = _userData?['fullName'] ?? 'المستخدم';

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
                  onTap: isApproved
                      ? () {
                          // Navigate to update profile
                        }
                      : null,
                ),
                _buildActionButton(
                  icon: Icons.history,
                  title: 'تاريخ الطلبات',
                  subtitle: isApproved ? 'عرض الطلبات' : 'غير متاح',
                  color: isApproved ? Colors.green : Colors.grey,
                  enabled: isApproved,
                  onTap: isApproved
                      ? () {
                          // Navigate to history
                        }
                      : null,
                ),
                _buildActionButton(
                  icon: Icons.info,
                  title: 'حالة الطلب',
                  subtitle: 'عرض التفاصيل',
                  color: Colors.orange,
                  enabled: true,
                  onTap: () {
                    // Show application status
                  },
                ),
                _buildActionButton(
                  icon: Icons.support,
                  title: 'الدعم الفني',
                  subtitle: 'تواصل معنا',
                  color: Colors.purple,
                  enabled: true,
                  onTap: () {
                    // Contact support
                  },
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

  // Widget _buildWelcomeSection() {
  //   final userName =
  //       _userData?['fullName'] ?? _userData?['displayName'] ?? 'المستخدم';
  //
  //   return Card(
  //     elevation: 4,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Container(
  //       width: double.infinity,
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [
  //             Colors.blue.shade700,
  //             Colors.blue.shade500,
  //           ],
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               CircleAvatar(
  //                 radius: 30,
  //                 backgroundColor: Colors.white.withOpacity(0.2),
  //                 child: Icon(
  //                   Icons.verified_user,
  //                   size: 35,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'مرحباً، $userName',
  //                       style: GoogleFonts.cairo(
  //                         fontSize: 20,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'مستخدم موثوق',
  //                       style: GoogleFonts.cairo(
  //                         fontSize: 14,
  //                         color: Colors.white.withOpacity(0.9),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //           Text(
  //             'أهلاً بك في لوحة تحكم المستخدمين الموثوقين',
  //             style: GoogleFonts.cairo(
  //               fontSize: 14,
  //               color: Colors.white.withOpacity(0.9),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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

  Widget _buildUserInfoCard(bool isApproved) {
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
                // Status indicator
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

            if (_userData != null) ...[
              _buildInfoRow(
                'الاسم الكامل',
                _userData!['fullName'] ?? 'غير محدد',
                isEditable: isApproved,
              ),
              _buildInfoRow(
                'البريد الإلكتروني',
                _userData!['email'] ?? 'غير محدد',
                isEditable: false, // Email is never editable
              ),
              _buildInfoRow(
                'رقم الهاتف',
                _userData!['phoneNumber'] ?? 'غير محدد',
                isEditable: isApproved,
              ),
              if (_userData!['additionalPhone']?.isNotEmpty == true)
                _buildInfoRow(
                  'رقم هاتف إضافي',
                  _userData!['additionalPhone'],
                  isEditable: isApproved,
                ),
              _buildInfoRow(
                'مقدم الخدمة',
                _userData!['serviceProvider'] ?? 'غير محدد',
                isEditable: isApproved,
              ),
              _buildInfoRow(
                'الموقع',
                _userData!['location'] ?? 'غير محدد',
                isEditable: isApproved,
              ),

              // Show different date fields based on approval status
              if (isApproved && _userData!['createdAt'] != null)
                _buildInfoRow(
                  'تاريخ إنشاء الحساب',
                  _formatDate(_userData!['createdAt']),
                  isEditable: false,
                ),

              if (!isApproved && _applicationData?['createdAt'] != null)
                _buildInfoRow(
                  'تاريخ تقديم الطلب',
                  _formatDate(_applicationData!['createdAt']),
                  isEditable: false,
                ),

              // Show role/status
              _buildInfoRow(
                'نوع الحساب',
                isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة',
                isEditable: false,
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

            // Show edit button for approved users
            if (isApproved && _userData != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to edit profile screen
                    _showEditProfileDialog();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(
                    'تحديث المعلومات',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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

  // Widget _buildInfoRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(
  //           width: 130,
  //           child: Text(
  //             '$label:',
  //             style: GoogleFonts.cairo(
  //               fontSize: 14,
  //               color: Colors.grey.shade600,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: GoogleFonts.cairo(
  //               fontSize: 14,
  //               color: Colors.grey.shade800,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildQuickActionsCard() {
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
  //               Icon(Icons.dashboard, color: Colors.blue.shade700, size: 24),
  //               const SizedBox(width: 8),
  //               Text(
  //                 'إجراءات سريعة',
  //                 style: GoogleFonts.cairo(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.grey.shade800,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 16),
  //
  //           // Quick action buttons
  //           Wrap(
  //             spacing: 12,
  //             runSpacing: 12,
  //             children: [
  //               _buildQuickActionButton(
  //                 'تحديث البيانات',
  //                 Icons.edit,
  //                 Colors.blue,
  //                 () => _showUpdateDataDialog(),
  //               ),
  //               _buildQuickActionButton(
  //                 'تحقق من الحالة',
  //                 Icons.refresh,
  //                 Colors.green,
  //                 () => _loadUserData(),
  //               ),
  //               _buildQuickActionButton(
  //                 'تواصل معنا',
  //                 Icons.support_agent,
  //                 Colors.orange,
  //                 () => _showContactDialog(),
  //               ),
  //               _buildQuickActionButton(
  //                 'الإعدادات',
  //                 Icons.settings,
  //                 Colors.grey,
  //                 () => _showSettingsDialog(),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isEditable = false,
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
                  if (isEditable) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    // Show dialog or navigate to edit screen
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
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(),
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

  // String _formatDate(dynamic timestamp) {
  //   try {
  //     if (timestamp is String) {
  //       final date = DateTime.parse(timestamp);
  //       return '${date.day}/${date.month}/${date.year}';
  //     }
  //     return timestamp.toString();
  //   } catch (e) {
  //     return 'غير محدد';
  //   }
  // }

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
                ref.read(authProvider.notifier).signOut();
                context.goNamed("trustedUserLogin");

                // context.go('/trusted-login');
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
