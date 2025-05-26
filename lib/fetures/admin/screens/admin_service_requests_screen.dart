// lib/fetures/admin/screens/admin_service_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:trustedtallentsvalley/fetures/services/providers/service_requests_provider.dart';

import '../../../fetures/services/service_model.dart';

class AdminServiceRequestsScreen extends ConsumerStatefulWidget {
  const AdminServiceRequestsScreen({super.key});

  @override
  ConsumerState<AdminServiceRequestsScreen> createState() =>
      _AdminServiceRequestsScreenState();
}

class _AdminServiceRequestsScreenState
    extends ConsumerState<AdminServiceRequestsScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final requestsStream = ref.watch(allServiceRequestsProvider);
    final pendingRequestsCount = ref.watch(newRequestsCountProvider);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1200;
    final isDesktop = screenSize.width >= 1200;

    if (!isAdmin) {
      return Scaffold(
        body: Center(
          child: Text(
            'غير مصرح بالوصول',
            style: GoogleFonts.cairo(fontSize: 18),
          ),
        ),
      );
    }

    // Get admin info for request assignments
    final authState = ref.watch(authProvider);
    final adminId = authState.user?.uid ?? '';
    final adminName = authState.user?.email?.split('@').first ?? 'مشرف';

    return requestsStream.when(
      data: (requests) {
        if (isMobile) {
          return _buildMobileLayout(
            context,
            ref,
            requests,
            adminId,
            adminName,
            pendingRequestsCount,
          );
        } else {
          return _buildWebLayout(
            context,
            ref,
            requests,
            adminId,
            adminName,
            pendingRequestsCount,
            isTablet,
          );
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text(
            'حدث خطأ: $error',
            style: GoogleFonts.cairo(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // Mobile Layout - Tab-based navigation
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRequestModel> requests,
    String adminId,
    String adminName,
    int pendingRequestsCount,
  ) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            'إدارة طلبات الخدمات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            _buildMobileRequestsList(
                context,
                ref,
                _filterRequestsByStatus(requests, ServiceRequestStatus.pending),
                adminId,
                adminName,
                ServiceRequestStatus.pending),
            _buildMobileRequestsList(
                context,
                ref,
                _filterRequestsByStatus(
                    requests, ServiceRequestStatus.inProgress),
                adminId,
                adminName,
                ServiceRequestStatus.inProgress),
            _buildMobileRequestsList(
                context,
                ref,
                _filterRequestsByStatus(
                    requests, ServiceRequestStatus.completed),
                adminId,
                adminName,
                ServiceRequestStatus.completed),
            _buildMobileRequestsList(
                context,
                ref,
                _filterRequestsByStatus(
                    requests, ServiceRequestStatus.cancelled),
                adminId,
                adminName,
                ServiceRequestStatus.cancelled),
          ],
        ),
      ),
    );
  }

  // Web Layout - Sidebar navigation with main content area
  Widget _buildWebLayout(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRequestModel> requests,
    String adminId,
    String adminName,
    int pendingRequestsCount,
    bool isTablet,
  ) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: isTablet ? 250 : 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                right: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'إدارة طلبات الخدمات',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Navigation Items
                _buildWebNavItem(
                  icon: Icons.pending_actions,
                  label: 'قيد الانتظار',
                  badge: pendingRequestsCount,
                  isSelected: selectedIndex == 0,
                  onTap: () => setState(() => selectedIndex = 0),
                ),
                _buildWebNavItem(
                  icon: Icons.hourglass_top,
                  label: 'قيد المعالجة',
                  isSelected: selectedIndex == 1,
                  onTap: () => setState(() => selectedIndex = 1),
                ),
                _buildWebNavItem(
                  icon: Icons.check_circle,
                  label: 'مكتملة',
                  isSelected: selectedIndex == 2,
                  onTap: () => setState(() => selectedIndex = 2),
                ),
                _buildWebNavItem(
                  icon: Icons.cancel,
                  label: 'ملغية/مرفوضة',
                  isSelected: selectedIndex == 3,
                  onTap: () => setState(() => selectedIndex = 3),
                ),

                const Spacer(),

                // Admin Info
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Text(
                          adminName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adminName,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'مشرف',
                              style: GoogleFonts.cairo(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Content Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getSelectedTabTitle(selectedIndex),
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildStatusSummary(requests),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildWebRequestsContent(
                    context,
                    ref,
                    _getFilteredRequests(requests, selectedIndex),
                    adminId,
                    adminName,
                    _getStatusFromIndex(selectedIndex),
                    isTablet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNavItem({
    required IconData icon,
    required String label,
    int? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.teal.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: Colors.teal.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.teal : Colors.grey.shade600,
                      size: 20,
                    ),
                    if (badge != null && badge > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badge.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.cairo(
                      color: isSelected ? Colors.teal : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildStatusSummary(List<ServiceRequestModel> requests) {
    final pending =
        requests.where((r) => r.status == ServiceRequestStatus.pending).length;
    final processing = requests
        .where((r) => r.status == ServiceRequestStatus.inProgress)
        .length;
    final completed = requests
        .where((r) => r.status == ServiceRequestStatus.completed)
        .length;
    final cancelled = requests
        .where((r) => r.status == ServiceRequestStatus.cancelled)
        .length;

    return Row(
      children: [
        _buildSummaryChip('قيد الانتظار', pending, Colors.amber),
        const SizedBox(width: 8),
        _buildSummaryChip('قيد المعالجة', processing, Colors.blue),
        const SizedBox(width: 8),
        _buildSummaryChip('مكتملة', completed, Colors.green),
        const SizedBox(width: 8),
        _buildSummaryChip('ملغية', cancelled, Colors.grey),
      ],
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRequestsContent(
    BuildContext context,
    WidgetRef ref,
    List<ServiceRequestModel> requests,
    String adminId,
    String adminName,
    ServiceRequestStatus status,
    bool isTablet,
  ) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طلبات ${_getStatusText(status)}',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ستظهر الطلبات الجديدة هنا عند وصولها',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Grid layout for web
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 1 : 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio:
              isTablet ? 2.8 : 2.2, // Increased height for content
        ),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return _buildWebRequestCard(
            context,
            ref,
            requests[index],
            adminId,
            adminName,
          );
        },
      ),
    );
  }

  Widget _buildMobileRequestsList(
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
        return _buildMobileRequestCard(
          context,
          ref,
          request,
          adminId,
          adminName,
        );
      },
    );
  }

  Widget _buildWebRequestCard(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
    String adminId,
    String adminName,
  ) {
    final notifier = ref.read(serviceRequestsProvider.notifier);
    final formattedDate = _formatDate(request.createdAt);
    final statusColor = _getStatusColor(request.status);
    final canProcess = _canProcess(request, adminId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16), // Reduced padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              statusColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4), // Reduced padding
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(request.status),
                          size: 12, // Smaller icon
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            request.status.displayName,
                            style: GoogleFonts.cairo(
                              fontSize: 10, // Smaller text
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '#${request.id.substring(0, 6)}', // Shorter ID
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Service Info
            Text(
              request.serviceName,
              style: GoogleFonts.cairo(
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.clientName,
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Actions
            Wrap(
              // Changed from Row to Wrap for better responsiveness
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                if (request.status == ServiceRequestStatus.pending) ...[
                  TextButton(
                    onPressed: () =>
                        _showRejectDialog(context, ref, request.id),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                    ),
                    child: Text(
                      'رفض',
                      style: GoogleFonts.cairo(
                        color: Colors.red,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _startProcessing(
                        context, ref, request.id, adminId, adminName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 28),
                    ),
                    child: Text(
                      'بدء المعالجة',
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),
                  ),
                ],
                if (request.status == ServiceRequestStatus.inProgress &&
                    canProcess) ...[
                  ElevatedButton(
                    onPressed: () =>
                        _showCompleteDialog(context, ref, request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 28),
                    ),
                    child: Text(
                      'إكمال',
                      style: GoogleFonts.cairo(fontSize: 10),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        _showCancelProcessingDialog(context, ref, request.id),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                    ),
                    child: Text(
                      'إلغاء المعالجة',
                      style: GoogleFonts.cairo(
                        color: Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
                if (!canProcess &&
                    request.status == ServiceRequestStatus.inProgress)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      'معالج بواسطة آخر',
                      style: GoogleFonts.cairo(
                        color: Colors.orange.shade700,
                        fontSize: 9,
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

  Widget _buildMobileRequestCard(
    BuildContext context,
    WidgetRef ref,
    ServiceRequestModel request,
    String adminId,
    String adminName,
  ) {
    final notifier = ref.read(serviceRequestsProvider.notifier);
    final formattedDate = _formatDate(request.createdAt);
    final statusColor = _getStatusColor(request.status);
    final canProcess = _canProcess(request, adminId);

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
                    mainAxisSize: MainAxisSize.min,
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
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
                const SizedBox(width: 8),
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
                    onPressed: () => _startProcessing(
                        context, ref, request.id, adminId, adminName),
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
                  TextButton.icon(
                    onPressed: () =>
                        _showCancelProcessingDialog(context, ref, request.id),
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(
                      'إلغاء المعالجة',
                      style: GoogleFonts.cairo(),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
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

  // Helper methods
  List<ServiceRequestModel> _filterRequestsByStatus(
      List<ServiceRequestModel> requests, ServiceRequestStatus status) {
    return requests.where((request) => request.status == status).toList();
  }

  String _formatDate(dynamic timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return Colors.amber;
      case ServiceRequestStatus.inProgress:
        return Colors.blue;
      case ServiceRequestStatus.completed:
        return Colors.green;
      case ServiceRequestStatus.cancelled:
        return Colors.grey;
    }
  }

  bool _canProcess(ServiceRequestModel request, String adminId) {
    if (request.status == ServiceRequestStatus.inProgress &&
        request.assignedAdminId != null &&
        request.assignedAdminId != adminId) {
      return false;
    }
    return true;
  }

  String _getSelectedTabTitle(int index) {
    switch (index) {
      case 0:
        return 'الطلبات قيد الانتظار';
      case 1:
        return 'الطلبات قيد المعالجة';
      case 2:
        return 'الطلبات المكتملة';
      case 3:
        return 'الطلبات الملغية والمرفوضة';
      default:
        return 'الطلبات';
    }
  }

  List<ServiceRequestModel> _getFilteredRequests(
      List<ServiceRequestModel> requests, int index) {
    switch (index) {
      case 0:
        return requests
            .where((r) => r.status == ServiceRequestStatus.pending)
            .toList();
      case 1:
        return requests
            .where((r) => r.status == ServiceRequestStatus.inProgress)
            .toList();
      case 2:
        return requests
            .where((r) => r.status == ServiceRequestStatus.completed)
            .toList();
      case 3:
        return requests
            .where((r) => r.status == ServiceRequestStatus.cancelled)
            .toList();
      default:
        return [];
    }
  }

  ServiceRequestStatus _getStatusFromIndex(int index) {
    switch (index) {
      case 0:
        return ServiceRequestStatus.pending;
      case 1:
        return ServiceRequestStatus.inProgress;
      case 2:
        return ServiceRequestStatus.completed;
      case 3:
        return ServiceRequestStatus.cancelled;
      default:
        return ServiceRequestStatus.pending;
    }
  }

  Future<void> _startProcessing(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String adminId,
    String adminName,
  ) async {
    final notifier = ref.read(serviceRequestsProvider.notifier);
    final success = await notifier.startProcessing(
      requestId,
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

  void _showCancelProcessingDialog(
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
              const Icon(Icons.cancel_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'إلغاء معالجة الطلب',
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
                'هل أنت متأكد من إلغاء معالجة هذا الطلب؟ سيتم إرجاع الطلب إلى حالة "قيد الانتظار".',
                style: GoogleFonts.cairo(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'سبب الإلغاء (اختياري)',
                  hintText: 'أدخل سبب إلغاء معالجة الطلب',
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

                      final success = await notifier.cancelRequest(
                        requestId,
                        // reasonController.text.isEmpty
                        //     ? null
                        //     : reasonController.text,
                      );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إلغاء معالجة الطلب وإرجاعه إلى قائمة الانتظار',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else if (context.mounted) {
                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تعذر إلغاء معالجة الطلب',
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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
                      'إلغاء المعالجة',
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
    }
  }
}
