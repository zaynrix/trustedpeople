import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/ActivityUpdate.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';

class AdminActivityWidget extends ConsumerWidget {
  const AdminActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آخر النشاطات',
                style: GoogleFonts.cairo(
                  textStyle: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'إضافة نشاط جديد',
                onPressed: () {
                  _showAddUpdateDialog(context, ref);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdminActivityList(ref),
        ],
      ),
    );
  }

  Widget _buildAdminActivityList(WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'لا توجد نشاطات حالياً',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityItem(context, ref, activity);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'حدث خطأ: $error',
          style: GoogleFonts.cairo(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, WidgetRef ref, Activity activity) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd – HH:mm');
    final String formattedDate = formatter.format(activity.date);

    // Get icon based on activity type
    IconData activityIcon;
    Color iconColor;

    switch (activity.type) {
      case 'announcement':
        activityIcon = Icons.campaign;
        iconColor = Colors.blue;
        break;
      case 'warning':
        activityIcon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'update':
        activityIcon = Icons.update;
        iconColor = Colors.green;
        break;
      default:
        activityIcon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activityIcon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.cairo(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Visibility status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: activity.isPublic
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: activity.isPublic
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Text(
                        activity.isPublic ? 'عام' : 'خاص',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: activity.isPublic
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Toggle visibility
                    IconButton(
                      icon: Icon(
                        activity.isPublic
                            ? Icons.visibility
                            : Icons.visibility_off,
                        size: 18,
                        color: activity.isPublic ? Colors.green : Colors.red,
                      ),
                      tooltip: activity.isPublic ? 'إخفاء' : 'إظهار',
                      onPressed: () {
                        ref
                            .read(activityServiceProvider)
                            .toggleActivityVisibility(
                              activity.id,
                              !activity.isPublic,
                            );
                      },
                    ),
                    // Edit button
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue,
                      ),
                      tooltip: 'تعديل',
                      onPressed: () {
                        _showAddUpdateDialog(context, ref, activity);
                      },
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      tooltip: 'حذف',
                      onPressed: () {
                        _showDeleteConfirmation(context, ref, activity);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUpdateDialog(BuildContext context, WidgetRef ref,
      [Activity? existingActivity]) {
    final isEditing = existingActivity != null;

    final titleController = TextEditingController(
      text: isEditing ? existingActivity.title : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? existingActivity.description : '',
    );

    String selectedType = isEditing ? existingActivity.type : 'update';
    bool isPublic = isEditing ? existingActivity.isPublic : true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل النشاط' : 'إضافة نشاط جديد',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'العنوان',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.cairo(),
                    ),
                    const SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'التفاصيل',
                        labelStyle: GoogleFonts.cairo(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.cairo(),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Activity type
                    Text(
                      'نوع النشاط:',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildTypeOption(
                          'تحديث',
                          'update',
                          selectedType,
                          Icons.update,
                          Colors.green,
                          (type) => setState(() => selectedType = type),
                        ),
                        _buildTypeOption(
                          'إعلان',
                          'announcement',
                          selectedType,
                          Icons.campaign,
                          Colors.blue,
                          (type) => setState(() => selectedType = type),
                        ),
                        _buildTypeOption(
                          'تنبيه',
                          'warning',
                          selectedType,
                          Icons.warning,
                          Colors.orange,
                          (type) => setState(() => selectedType = type),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Visibility option
                    SwitchListTile(
                      title: Text(
                        'إظهار للمستخدمين',
                        style: GoogleFonts.cairo(),
                      ),
                      value: isPublic,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء', style: GoogleFonts.cairo()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty || description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء ملء جميع الحقول'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    try {
                      final activityService = ref.read(activityServiceProvider);
                      final authState = ref.read(authProvider);

                      if (isEditing) {
                        // Update existing activity
                        final updatedActivity = existingActivity.copyWith(
                          title: title,
                          description: description,
                          type: selectedType,
                          isPublic: isPublic,
                        );

                        await activityService.updateActivity(updatedActivity);
                      } else {
                        // Create new activity
                        final newActivity = Activity(
                          id: '',
                          title: title,
                          description: description,
                          date: DateTime.now(),
                          type: selectedType,
                          createdBy: authState.user?.email ?? 'مشرف',
                          isPublic: isPublic,
                        );

                        await activityService.addActivity(newActivity);
                      }

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'تم تحديث النشاط بنجاح'
                              : 'تم إضافة النشاط بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('حدث خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(
                    isEditing ? 'تحديث' : 'إضافة',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTypeOption(
    String label,
    String value,
    String selectedValue,
    IconData icon,
    Color color,
    Function(String) onSelect,
  ) {
    final isSelected = value == selectedValue;

    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? color : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? color : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Activity activity) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذا النشاط؟',
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(activityServiceProvider)
                      .deleteActivity(activity.id);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف النشاط بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('حذف', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }
}
