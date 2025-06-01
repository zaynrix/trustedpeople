import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

class ApplicationStatusScreen extends ConsumerStatefulWidget {
  const ApplicationStatusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ApplicationStatusScreen> createState() =>
      _ApplicationStatusScreenState();
}

class _ApplicationStatusScreenState
    extends ConsumerState<ApplicationStatusScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _applicationData;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _applicationData = null;
    });

    try {
      final authNotifier = ref.read(authProvider.notifier);
      final data =
          await authNotifier.getApplicationStatus(_emailController.text.trim());

      setState(() {
        _applicationData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'لم يتم العثور على طلب بهذا البريد الإلكتروني';
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
          'حالة الطلب',
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: isMobile ? _buildMobileLayout() : _buildWebLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            _buildSearchForm(),
            if (_applicationData != null) ...[
              const SizedBox(height: 30),
              _buildApplicationDetails(),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
            Colors.grey.shade700,
          ],
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            elevation: 20,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildSearchForm(),
                    if (_applicationData != null) ...[
                      const SizedBox(height: 30),
                      _buildApplicationDetails(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.search,
            size: 40,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'تحقق من حالة طلبك',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'أدخل بريدك الإلكتروني للاستعلام عن حالة طلب التسجيل',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            labelStyle: GoogleFonts.cairo(),
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          style: GoogleFonts.cairo(),
          keyboardType: TextInputType.emailAddress,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.cairo(
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _checkStatus,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'جارٍ البحث...',
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'البحث',
                      style: GoogleFonts.cairo(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildApplicationDetails() {
    if (_applicationData == null) return const SizedBox();

    final status = _applicationData!['status'] ?? 'pending';
    final adminComment = _applicationData!['adminComment'] ?? '';
    final createdAt = _applicationData!['createdAt'];
    final updatedAt = _applicationData!['updatedAt'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
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
                          'حالة الطلب',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _getStatusText(status),
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Application Details
            Text(
              'بيانات الطلب',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
                'الاسم الكامل', _applicationData!['fullName'] ?? ''),
            _buildDetailRow(
                'البريد الإلكتروني', _applicationData!['email'] ?? ''),
            _buildDetailRow(
                'رقم الهاتف', _applicationData!['phoneNumber'] ?? ''),
            if (_applicationData!['additionalPhone']?.isNotEmpty == true)
              _buildDetailRow(
                  'رقم هاتف إضافي', _applicationData!['additionalPhone']),
            _buildDetailRow(
                'مقدم الخدمة', _applicationData!['serviceProvider'] ?? ''),
            _buildDetailRow('الموقع', _applicationData!['location'] ?? ''),

            if (createdAt != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('تاريخ التقديم', _formatDate(createdAt)),
            ],

            if (updatedAt != null && updatedAt != createdAt) ...[
              _buildDetailRow('آخر تحديث', _formatDate(updatedAt)),
            ],

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

            const SizedBox(height: 20),

            // Action based on status
            if (status.toLowerCase() == 'approved' || status == 'مقبول') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.celebration,
                        color: Colors.green.shade600, size: 32),
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
                      'يمكنك الآن تسجيل الدخول باستخدام بيانات حسابك',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.go('/secure-trusted-895623/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status.toLowerCase() == 'rejected' ||
                status == 'مرفوض') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cancel_outlined,
                        color: Colors.red.shade600, size: 32),
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
                      'يمكنك تقديم طلب جديد بعد مراجعة الملاحظات',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
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
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year}';
      }
      // Handle Firestore Timestamp if needed
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
  }
}
