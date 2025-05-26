// File: lib/features/maintenance/widgets/maintenance_management_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/maintenance/maintenance_service.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class MaintenanceManagementWidget extends ConsumerStatefulWidget {
  const MaintenanceManagementWidget({super.key});

  @override
  ConsumerState<MaintenanceManagementWidget> createState() =>
      _MaintenanceManagementWidgetState();
}

class _MaintenanceManagementWidgetState
    extends ConsumerState<MaintenanceManagementWidget> {
  bool _isLoading = false;

  // Define all available screens with their display names
  final Map<String, String> _availableScreens = {
    ScreensNames.trusted: 'إدارة الموثوقين',
    ScreensNames.untrusted: 'إدارة النصابين',
    ScreensNames.instruction: 'دليل الحماية',
    ScreensNames.ort: 'أماكن الدفع البنكي',
    ScreensNames.contactUs: 'تواصل معنا',
    ScreensNames.services: 'الخدمات',
    ScreensNames.blockedUsers: 'المستخدمين المحظورين',
    ScreensNames.adminServices: 'إدارة الخدمات',
    ScreensNames.adminServiceRequests: 'طلبات الخدمة',
    ScreensNames.updates: 'التحديثات',
  };

  Future<void> _toggleMaintenance(String screenName, bool newValue) async {
    setState(() => _isLoading = true);

    try {
      await ref
          .read(maintenanceServiceProvider)
          .updateScreenMaintenanceStatus(screenName, newValue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue
                  ? 'تم تفعيل وضع الصيانة للشاشة'
                  : 'تم إلغاء وضع الصيانة للشاشة',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: newValue ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _enableAllScreens() async {
    setState(() => _isLoading = true);

    try {
      final updates = Map<String, bool>.fromEntries(
          _availableScreens.keys.map((screen) => MapEntry(screen, false)));

      await ref
          .read(maintenanceServiceProvider)
          .bulkUpdateMaintenanceStatus(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تفعيل جميع الشاشات',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceStatusAsync = ref.watch(maintenanceStatusProvider);

    return Container(
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'إدارة وضع الصيانة',
                    style: GoogleFonts.cairo(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _enableAllScreens,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  'تفعيل جميع الشاشات',
                  style: GoogleFonts.cairo(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'يمكنك من هنا تعطيل أو تفعيل الشاشات عند القيام بأعمال الصيانة',
            style: GoogleFonts.cairo(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          // Maintenance status list
          maintenanceStatusAsync.when(
            data: (maintenanceStatus) {
              return Column(
                children: _availableScreens.entries.map((entry) {
                  final screenName = entry.key;
                  final displayName = entry.value;
                  final isUnderMaintenance =
                      maintenanceStatus[screenName] ?? false;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isUnderMaintenance
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isUnderMaintenance ? Icons.build : Icons.check_circle,
                          color:
                              isUnderMaintenance ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        isUnderMaintenance
                            ? 'تحت الصيانة - غير متاح للمستخدمين'
                            : 'متاح للمستخدمين',
                        style: GoogleFonts.cairo(
                          color:
                              isUnderMaintenance ? Colors.orange : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Switch(
                        value:
                            !isUnderMaintenance, // Inverted for UX (true = active/available)
                        onChanged: _isLoading
                            ? null
                            : (value) => _toggleMaintenance(screenName, !value),
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.orange,
                        inactiveTrackColor: Colors.orange.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade600),
                  const SizedBox(height: 8),
                  Text(
                    'حدث خطأ في تحميل حالة الصيانة',
                    style: GoogleFonts.cairo(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.toString(),
                    style: GoogleFonts.cairo(
                      color: Colors.red.shade500,
                      fontSize: 12,
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
}
