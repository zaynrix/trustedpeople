import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/ActivityUpdate.dart';
import 'package:trustedtallentsvalley/fetures/Home/uis/trusted_screen.dart';

// Modified provider for viewing all public activities
final allPublicActivitiesProvider = StreamProvider<List<Activity>>((ref) {
  return FirebaseFirestore.instance
      .collection('activities')
      .where('isPublic', isEqualTo: true)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Activity.fromFirestore(doc)).toList());
});

class AllUpdatesScreen extends ConsumerWidget {
  const AllUpdatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allPublicActivitiesProvider);

    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: isMobile,
        title: Text(
          'جميع التحديثات',
          style: GoogleFonts.cairo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      drawer: isMobile ? const AppDrawer() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (constraints.maxWidth > 768)
                const AppDrawer(isPermanent: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: activitiesAsync.when(
                    data: (activities) {
                      if (activities.isEmpty) {
                        return Center(
                          child: Text(
                            'لا توجد تحديثات حالياً',
                            style: GoogleFonts.cairo(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final activity = activities[index];
                          return _buildDetailedActivityItem(context, activity);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text(
                        'حدث خطأ: $error',
                        style: GoogleFonts.cairo(color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailedActivityItem(BuildContext context, Activity activity) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd – HH:mm');
    final String formattedDate = formatter.format(activity.date);

    // Get icon based on activity type
    IconData activityIcon;
    Color iconColor;
    String typeText;

    switch (activity.type) {
      case 'announcement':
        activityIcon = Icons.campaign;
        iconColor = Colors.blue;
        typeText = 'إعلان';
        break;
      case 'warning':
        activityIcon = Icons.warning;
        iconColor = Colors.orange;
        typeText = 'تنبيه';
        break;
      case 'update':
        activityIcon = Icons.update;
        iconColor = Colors.green;
        typeText = 'تحديث';
        break;
      default:
        activityIcon = Icons.notifications;
        iconColor = Colors.grey;
        typeText = 'إشعار';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    activityIcon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '$typeText • $formattedDate',
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
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: GoogleFonts.cairo(
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
