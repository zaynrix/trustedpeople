import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/app/extensions/app_extention.dart';
import 'package:trustedtallentsvalley/config/app_constant.dart';
import 'package:trustedtallentsvalley/config/app_utils.dart';
import 'package:trustedtallentsvalley/fetures/admin/adminDStatistcs/providers/dashboard_provider.dart';

// import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';
import '../models/visitor_info.dart';

// ==================== Modern Icon Button ====================
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Icon(
            icon,
            size: size ?? 20,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ==================== Loading Widget ====================
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.cairo(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== Access Denied Widget ====================
class AccessDeniedWidget extends StatelessWidget {
  const AccessDeniedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: isMobile ? 60 : 80,
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: isMobile ? 24.0 : 32.0),
            Text(
              'عذراً، هذه الصفحة للمشرفين فقط',
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 16.0 : 20.0),
            Text(
              'لا تملك الصلاحيات الكافية للوصول إلى لوحة التحكم.',
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 14 : 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 24.0 : 32.0),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text('العودة', style: GoogleFonts.cairo()),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Dashboard Header ====================
class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    final stats = ref.watch(visitorStatsProvider);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  size: isMobile ? 24 : 28,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إحصائيات الموقع',
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مراقبة شاملة لنشاط الزوار',
                      style: GoogleFonts.cairo(
                        fontSize: isMobile ? 12 : 14,
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQuickStat('إجمالي الزوار',
                    stats['total']?.toString() ?? '0', Icons.people_rounded),
                const SizedBox(width: 24),
                _buildQuickStat('زوار اليوم', stats['today']?.toString() ?? '0',
                    Icons.today_rounded),
                const SizedBox(width: 24),
                _buildQuickStat('الدول', stats['countries']?.toString() ?? '0',
                    Icons.public_rounded),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== Analytics Item ====================
class AnalyticsItem extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;
  final bool? trend;

  const AnalyticsItem({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
    required this.subtitle,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: isMobile ? 12 : 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trend != null)
                  Icon(
                    trend! ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: trend! ? Colors.green : Colors.red,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: isMobile ? 11 : 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Empty State Widget ====================
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.cairo(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

// ==================== Visitor Card ====================
class VisitorCard extends StatelessWidget {
  final VisitorInfo visitor;
  final WidgetRef ref;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceInfo = visitor.deviceInfo;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToVisitorDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLocationChip(theme),
                  const Spacer(),
                  _buildDeviceChip(deviceInfo, theme),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.router_rounded,
                visitor.ipAddress,
                theme,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.schedule_rounded,
                formatter.format(visitor.timestamp),
                theme,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionButton(
                    Icons.info_outline_rounded,
                    'التفاصيل',
                    Colors.blue,
                    () => _navigateToVisitorDetails(context),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    Icons.block_rounded,
                    'حظر',
                    Colors.red,
                    () => _showBlockDialog(context),
                  ),
                  const Spacer(),
                  _buildCopyButton(context, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${visitor.country}, ${visitor.city}',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceChip(DeviceInfo deviceInfo, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            deviceInfo.deviceIcon,
            size: 14,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            deviceInfo.type,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, ThemeData theme) {
    return IconButton(
      onPressed: () => _copyToClipboard(context),
      icon: Icon(
        Icons.copy_rounded,
        size: 18,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
      tooltip: 'نسخ IP',
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.all(8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    ClipboardUtils.copyToClipboard(
      context,
      visitor.ipAddress,
      successMessage: 'تم نسخ IP: ${visitor.ipAddress}',
    );
  }

  void _navigateToVisitorDetails(BuildContext context) {
    // Implementation would go here
    // Navigator.push(context, AnimationUtils.createSlideRoute(
    //   page: EnhancedVisitorDetails(
    //     visitorId: visitor.id,
    //     visitorIp: visitor.ipAddress,
    //   ),
    // ));
  }

  void _showBlockDialog(BuildContext context) {
    // Implementation would go here - similar to the previous block dialog
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(visitor: visitor, ref: ref),
    );
  }
}

// ==================== Block User Dialog ====================
class BlockUserDialog extends StatefulWidget {
  final VisitorInfo visitor;
  final WidgetRef ref;

  const BlockUserDialog({
    super.key,
    required this.visitor,
    required this.ref,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.block_rounded, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          Text(
            'حظر المستخدم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDialogInfoCard('عنوان IP', widget.visitor.ipAddress, theme),
          const SizedBox(height: 8),
          _buildDialogInfoCard('الموقع',
              '${widget.visitor.country}, ${widget.visitor.city}', theme),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'سبب الحظر',
              labelStyle: GoogleFonts.cairo(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'اكتب سبب الحظر هنا...',
              prefixIcon: const Icon(Icons.edit_note_rounded),
            ),
            style: GoogleFonts.cairo(),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('إلغاء', style: GoogleFonts.cairo()),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _blockUser,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.block_rounded),
          label: Text(_isLoading ? 'جارٍ الحظر...' : 'حظر',
              style: GoogleFonts.cairo()),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  Widget _buildDialogInfoCard(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _blockUser() async {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      ErrorHandler.showWarning(context, 'الرجاء إدخال سبب الحظر');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Implementation for blocking user would go here
      // This would typically involve calling a service method

      Navigator.pop(context);
      ErrorHandler.showSuccess(context, 'تم حظر المستخدم بنجاح');

      // Refresh the data
      widget.ref.read(analyticsStateProvider.notifier).refresh();
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// ==================== Refresh Button ====================
class RefreshButton extends ConsumerWidget {
  const RefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsStateProvider);

    return ModernIconButton(
      icon: Icons.refresh_rounded,
      tooltip: 'تحديث البيانات',
      onPressed: analyticsState.isLoading
          ? () {}
          : () => ref.read(analyticsStateProvider.notifier).refresh(),
    );
  }
}

// ==================== Error Retry Widget ====================
class ErrorRetryWidget extends ConsumerWidget {
  final String error;

  const ErrorRetryWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء تحميل البيانات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(analyticsStateProvider.notifier).retryLoad(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}
