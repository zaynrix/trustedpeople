// lib/fetures/admin/screens/admin_service_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';
import 'package:trustedtallentsvalley/services/providers/service_requests_provider.dart';

import '../../../services/service_model.dart';

class AdminServiceRequestsScreen extends ConsumerWidget {
  const AdminServiceRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final requestsStream = ref.watch(allServiceRequestsProvider);
    final pendingRequestsCount = ref.watch(newRequestsCountProvider);

    if (!isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text('غير مصرح بالوصول'),
        ),
      );
    }

    // Get admin info for request assignments
    final authState = ref.watch(authProvider);
    final adminId = authState.user?.uid ?? '';
    final adminName = authState.user?.email?.split('@').first ?? 'مشرف';

    return DefaultTabController(
      length: 4, // For the different request status tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إدارة طلبات الخدمات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.teal,
          bottom: TabBar(
            tabs: [
              Tab(
                icon: Stack(
                  children: [
                    const Icon(Icons.pending_actions),
                    if (pendingRequestsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            pendingRequestsCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                text: 'قيد الانتظار',
              ),
              const Tab(icon: Icon(Icons.hourglass_top), text: 'قيد المعالجة'),
              const Tab(icon: Icon(Icons.check_circle), text: 'مكتملة'),
              const Tab(icon: Icon(Icons.cancel), text: 'ملغية/مرفوضة'),
            ],
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.cairo(),
            indicatorColor: Colors.white,
            unselectedLabelColor: Colors.black,
            labelColor: Colors.white,
          ),
        ),
        body: requestsStream.when(
          data: (requests) {
            // Filter requests based on status for each tab
            final pendingRequests = requests
                .where(
                  (request) => request.status == ServiceRequestStatus.pending,
                )
                .toList();

            final processingRequests = requests
                .where(
                  (request) =>
                      request.status == ServiceRequestStatus.inProgress,
                )
                .toList();

            final completedRequests = requests
                .where(
                  (request) => request.status == ServiceRequestStatus.completed,
                )
                .toList();

            final cancelledRejectedRequests = requests
                .where((request) =>
                    request.status == ServiceRequestStatus.cancelled)
                .toList();

            return TabBarView(
              children: [
                // Pending requests tab
                _buildRequestsTab(
                  context,
                  ref,
                  pendingRequests,
                  adminId,
                  adminName,
                  ServiceRequestStatus.pending,
                ),

                // Processing requests tab
                _buildRequestsTab(
                  context,
                  ref,
                  processingRequests,
                  adminId,
                  adminName,
                  ServiceRequestStatus.inProgress,
                ),

                // Completed requests tab
                _buildRequestsTab(
                  context,
                  ref,
                  completedRequests,
                  adminId,
                  adminName,
                  ServiceRequestStatus.completed,
                ),

                // Cancelled/Rejected requests tab
                _buildRequestsTab(
                  context,
                  ref,
                  cancelledRejectedRequests,
                  adminId,
                  adminName,
                  ServiceRequestStatus
                      .cancelled, // Using cancelled as a representation
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              'حدث خطأ: $error',
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRequestModel> requests,
    String adminId,
    String adminName,
    ServiceRequestStatus status,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد طلبات ${_getStatusText(status)}',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(
          context,
          ref,
          request,
          adminId,
          adminName,
        );
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
    String adminId,
    String adminName,
  ) {
    final notifier = ref.read(serviceRequestsProvider.notifier);

    // Format the timestamp
    final createdDate = request.createdAt;
    String formattedDate = '';
    if (createdDate != null) {
      // Convert Timestamp to DateTime
      final dateTime = createdDate.toDate();

      // Format: DD/MM/YYYY HH:MM
      formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    }
    // Determine card color based on status
    Color statusColor;
    switch (request.status) {
      case ServiceRequestStatus.pending:
        statusColor = Colors.amber;
        break;
      case ServiceRequestStatus.inProgress:
        statusColor = Colors.blue;
        break;
      case ServiceRequestStatus.completed:
        statusColor = Colors.green;
        break;
      // case ServiceRequestStatus.pending:
      //   statusColor = Colors.red;
      //   break;
      case ServiceRequestStatus.cancelled:
        statusColor = Colors.grey;
        break;
    }

    // Determine if this admin can process this request
    bool canProcess = true;
    if (request.status == ServiceRequestStatus.inProgress &&
        request.assignedAdminId != null &&
        request.assignedAdminId != adminId) {
      canProcess = false;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status indicator
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // This is good, keep it
                    children: [
                      Icon(
                        _getStatusIcon(request.status),
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.status.displayName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                        // Add overflow handling
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Make ID flexible with ellipsis
                Flexible(
                  child: Text(
                    '#${request.id.substring(0, 8)}',
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Remove Spacer() if space is tight
                // const Spacer(),
                const SizedBox(width: 8), // Use fixed spacing instead
                // Make date flexible with ellipsis
                Flexible(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Service info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخدمة: ${request.serviceName}',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الطالب: ${request.clientName}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'البريد الإلكتروني: ${request.clientEmail}',
                        style: GoogleFonts.cairo(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'رقم الهاتف: ${request.clientPhone}',
                        style: GoogleFonts.cairo(),
                      ),
                    ],
                  ),
                ),

                // If assigned to admin, show assignment info
                if (request.assignedAdminId != null &&
                    request.status == ServiceRequestStatus.inProgress)
                  Container(
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
                          'قيد المعالجة بواسطة:',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          request.assignedAdminName ?? 'مشرف',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Request description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الطلب:',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.requirements,
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            ),

            // Notes section (if available)
            if (request.requirements != null &&
                request.requirements!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ملاحظات:',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.requirements!,
                      style: GoogleFonts.cairo(),
                    ),
                  ],
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Action buttons based on status
                if (request.status == ServiceRequestStatus.pending)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final success = await notifier.startProcessing(
                        request.id,
                        adminId,
                        adminName,
                      );

                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تعذر بدء معالجة الطلب',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم بدء معالجة الطلب بنجاح',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      'بدء المعالجة',
                      style: GoogleFonts.cairo(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                if (request.status == ServiceRequestStatus.inProgress &&
                    canProcess) ...[
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showCompleteDialog(context, ref, request.id),
                    icon: const Icon(Icons.check),
                    label: Text(
                      'إكمال',
                      style: GoogleFonts.cairo(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                if (request.status == ServiceRequestStatus.pending) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _showRejectDialog(context, ref, request.id),
                    icon: const Icon(Icons.cancel),
                    label: Text(
                      'رفض',
                      style: GoogleFonts.cairo(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],

                if (!canProcess &&
                    request.status == ServiceRequestStatus.inProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'هذا الطلب يتم معالجته بواسطة مشرف آخر',
                      style: GoogleFonts.cairo(
                        color: Colors.orange.shade700,
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

  void _showCompleteDialog(
      BuildContext context, WidgetRef ref, String requestId) {
    final notesController = TextEditingController();
    final notifier = ref.read(serviceRequestsProvider.notifier);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'إكمال الطلب',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل أنت متأكد من إكمال هذا الطلب؟',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  hintText: 'أضف أي ملاحظات حول الطلب هنا',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      final success = await notifier.completeRequest(
                        requestId,
                        notesController.text.isEmpty
                            ? null
                            : notesController.text,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إكمال الطلب بنجاح',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تعذر إكمال الطلب',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'إكمال',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, WidgetRef ref, String requestId) {
    final reasonController = TextEditingController();
    final notifier = ref.read(serviceRequestsProvider.notifier);
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.cancel, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'رفض الطلب',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'هل أنت متأكد من رفض هذا الطلب؟',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'سبب الرفض',
                  hintText: 'أدخل سبب رفض الطلب',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                // : (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'يرجى إدخال سبب الرفض';
                //   }
                //   return null;
                // },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (reasonController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يرجى إدخال سبب الرفض',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      final success = await notifier.rejectRequest(
                        requestId,
                        reasonController.text,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم رفض الطلب بنجاح',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تعذر رفض الطلب',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'رفض',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Icons.pending_actions;
      case ServiceRequestStatus.inProgress:
        return Icons.hourglass_top;
      case ServiceRequestStatus.completed:
        return Icons.check_circle;
      case ServiceRequestStatus.cancelled:
        return Icons.cancel;
      // case ServiceRequestStatus.cancelled:
      //   return Icons.cancel_presentation;
      // case ServiceRequestStatus.inProgress:
      //   // TODO: Handle this case.
      //   throw UnimplementedError();
    }
  }

  String _getStatusText(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'قيد الانتظار';
      case ServiceRequestStatus.inProgress:
        return 'قيد المعالجة';
      case ServiceRequestStatus.completed:
        return 'مكتمل';
      case ServiceRequestStatus.cancelled:
        return 'مرفوض';
      // case ServiceRequestStatus.cancelled:
      //   return 'ملغي';
    }
  }
}
