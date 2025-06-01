import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';

// Provider for managing user applications
final userApplicationsProvider = StateNotifierProvider<UserApplicationsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final auth = ref.watch(authProvider.notifier);
  return UserApplicationsNotifier(auth);
});

class UserApplicationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final AuthNotifier _authNotifier;

  UserApplicationsNotifier(this._authNotifier)
      : super(const AsyncValue.loading()) {
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      state = const AsyncValue.loading();
      final applications = await _authNotifier.getAllUserApplications();
      state = AsyncValue.data(applications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateApplicationStatus(String userId, String status,
      {String? comment}) async {
    try {
      await _authNotifier.updateUserApplicationStatus(userId, status,
          comment: comment);
      await loadApplications(); // Reload the list
    } catch (error) {
      // Handle error
      rethrow;
    }
  }
}

class AdminDashboardStatusScreen extends ConsumerStatefulWidget {
  const AdminDashboardStatusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardStatusScreen> createState() =>
      _AdminDashboardStatusScreenState();
}

class _AdminDashboardStatusScreenState
    extends ConsumerState<AdminDashboardStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(userApplicationsProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم الإدارة',
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.read(userApplicationsProvider.notifier).loadApplications(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
        bottom: isMobile
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade300,
                indicatorColor: Colors.white,
                labelStyle: GoogleFonts.cairo(fontSize: 14),
                tabs: const [
                  Tab(text: 'الكل'),
                  Tab(text: 'قيد المراجعة'),
                  Tab(text: 'مقبول'),
                  Tab(text: 'مرفوض'),
                  Tab(text: 'يحتاج مراجعة'),
                ],
              ),
      ),
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error.toString()),
        data: (applications) => isMobile
            ? _buildMobileLayout(applications)
            : _buildDesktopLayout(applications),
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> applications) {
    return Column(
      children: [
        _buildMobileFilterChips(applications),
        Expanded(
          child: _buildApplicationsList(applications, true),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(List<Map<String, dynamic>> applications) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildApplicationsList(applications, false),
        _buildApplicationsList(
            _filterApplications(applications, 'in_progress'), false),
        _buildApplicationsList(
            _filterApplications(applications, 'approved'), false),
        _buildApplicationsList(
            _filterApplications(applications, 'rejected'), false),
        _buildApplicationsList(
            _filterApplications(applications, 'needs_review'), false),
      ],
    );
  }

  Widget _buildMobileFilterChips(List<Map<String, dynamic>> applications) {
    final filters = [
      {'key': 'all', 'label': 'الكل', 'count': applications.length},
      {
        'key': 'in_progress',
        'label': 'قيد المراجعة',
        'count': _filterApplications(applications, 'in_progress').length
      },
      {
        'key': 'approved',
        'label': 'مقبول',
        'count': _filterApplications(applications, 'approved').length
      },
      {
        'key': 'rejected',
        'label': 'مرفوض',
        'count': _filterApplications(applications, 'rejected').length
      },
      {
        'key': 'needs_review',
        'label': 'يحتاج مراجعة',
        'count': _filterApplications(applications, 'needs_review').length
      },
    ];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                '${filter['label']} (${filter['count']})',
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key'] as String;
                });
              },
              selectedColor: Colors.grey.shade700,
              backgroundColor: Colors.grey.shade100,
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationsList(
      List<Map<String, dynamic>> applications, bool isMobile) {
    final filteredApplications = isMobile
        ? (_selectedFilter == 'all'
            ? applications
            : _filterApplications(applications, _selectedFilter))
        : applications;

    if (filteredApplications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(userApplicationsProvider.notifier).loadApplications(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredApplications.length,
        itemBuilder: (context, index) {
          final application = filteredApplications[index];
          return _buildApplicationCard(application, isMobile);
        },
      ),
    );
  }

  Widget _buildApplicationCard(
      Map<String, dynamic> application, bool isMobile) {
    final status = application['status'] ?? 'pending';
    final createdAt = application['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['fullName'] ?? 'غير محدد',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application['email'] ?? 'غير محدد',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),

            const SizedBox(height: 12),

            // Application details
            _buildDetailRow('الهاتف', application['phoneNumber'] ?? 'غير محدد'),
            if (application['additionalPhone']?.isNotEmpty == true)
              _buildDetailRow('هاتف إضافي', application['additionalPhone']),
            _buildDetailRow(
                'مقدم الخدمة', application['serviceProvider'] ?? 'غير محدد'),
            _buildDetailRow('الموقع', application['location'] ?? 'غير محدد'),
            if (createdAt != null)
              _buildDetailRow('تاريخ التقديم', _formatDate(createdAt)),

            if (application['adminComment']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'ملاحظة: ${application['adminComment']}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'عرض التفاصيل',
                    Icons.visibility,
                    Colors.blue,
                    () => _showApplicationDetails(application),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    'إدارة الحالة',
                    Icons.edit,
                    Colors.orange,
                    () => _showStatusManagementDialog(application),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'مقبول';
        break;
      case 'rejected':
        color = Colors.red;
        text = 'مرفوض';
        break;
      case 'in_progress':
        color = Colors.orange;
        text = 'قيد المراجعة';
        break;
      case 'needs_review':
        color = Colors.blue;
        text = 'يحتاج مراجعة';
        break;
      default:
        color = Colors.grey;
        text = 'في الانتظار';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        text,
        style: GoogleFonts.cairo(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلبات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
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
            error,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(userApplicationsProvider.notifier).loadApplications(),
            child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterApplications(
      List<Map<String, dynamic>> applications, String status) {
    return applications
        .where((app) => app['status']?.toLowerCase() == status.toLowerCase())
        .toList();
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

  void _showApplicationDetails(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => ApplicationDetailsDialog(application: application),
    );
  }

  void _showStatusManagementDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => StatusManagementDialog(
        application: application,
        onStatusUpdated: (status, comment) async {
          try {
            // Use the Firestore document ID, not the uid field
            final documentId = application['documentId'];

            if (documentId == null) {
              throw Exception('Document ID not found');
            }

            print(
                '🔧 Dialog: Updating application with document ID: $documentId');
            print('🔧 Dialog: New status: $status');
            print('🔧 Dialog: Comment: $comment');

            await ref
                .read(userApplicationsProvider.notifier)
                .updateApplicationStatus(
                  documentId, // Use the Firestore document ID
                  status,
                  comment: comment,
                );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('تم تحديث الحالة بنجاح', style: GoogleFonts.cairo()),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('🔧 Dialog: Error updating status: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ في تحديث الحالة: ${e.toString()}',
                      style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
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
                // Navigate to login
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

// Dialog for showing full application details
class ApplicationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicationDetailsDialog({Key? key, required this.application})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'تفاصيل الطلب',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailItem('الاسم الكامل', application['fullName']),
                    _buildDetailItem('البريد الإلكتروني', application['email']),
                    _buildDetailItem('رقم الهاتف', application['phoneNumber']),
                    if (application['additionalPhone']?.isNotEmpty == true)
                      _buildDetailItem(
                          'رقم هاتف إضافي', application['additionalPhone']),
                    _buildDetailItem(
                        'مقدم الخدمة', application['serviceProvider']),
                    _buildDetailItem('الموقع', application['location']),
                    _buildDetailItem(
                        'الحالة', _getStatusText(application['status'])),
                    if (application['createdAt'] != null)
                      _buildDetailItem('تاريخ التقديم',
                          _formatDate(application['createdAt'])),
                    if (application['updatedAt'] != null)
                      _buildDetailItem(
                          'آخر تحديث', _formatDate(application['updatedAt'])),
                    if (application['adminComment']?.isNotEmpty == true)
                      _buildDetailItem(
                          'ملاحظات الإدارة', application['adminComment']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              value ?? 'غير محدد',
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

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'needs_review':
        return 'يحتاج مراجعة';
      default:
        return 'في الانتظار';
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
  }
}

// Dialog for managing application status
class StatusManagementDialog extends StatefulWidget {
  final Map<String, dynamic> application;
  final Function(String status, String? comment) onStatusUpdated;

  const StatusManagementDialog({
    Key? key,
    required this.application,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<StatusManagementDialog> createState() => _StatusManagementDialogState();
}

class _StatusManagementDialogState extends State<StatusManagementDialog> {
  late String _selectedStatus;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'in_progress', 'label': 'قيد المراجعة', 'color': Colors.orange},
    {'value': 'approved', 'label': 'مقبول', 'color': Colors.green},
    {'value': 'rejected', 'label': 'مرفوض', 'color': Colors.red},
    {'value': 'needs_review', 'label': 'يحتاج مراجعة', 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.application['status'] ?? 'in_progress';
    _commentController.text = widget.application['adminComment'] ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'إدارة حالة الطلب',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Applicant info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.application['fullName'] ?? 'غير محدد',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    widget.application['email'] ?? 'غير محدد',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status selection
            Text(
              'حالة الطلب',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            ..._statusOptions
                .map((option) => RadioListTile<String>(
                      title: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: option['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option['label'],
                            style: GoogleFonts.cairo(fontSize: 14),
                          ),
                        ],
                      ),
                      value: option['value'],
                      groupValue: _selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ))
                .toList(),

            const SizedBox(height: 20),

            // Comment field
            Text(
              'ملاحظات للمتقدم (اختياري)',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'أدخل ملاحظاتك هنا...',
                hintStyle: GoogleFonts.cairo(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade700, width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: GoogleFonts.cairo(),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(color: Colors.grey.shade700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'حفظ التغييرات',
                            style:
                                GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onStatusUpdated(
          _selectedStatus, _commentController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحالة', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
