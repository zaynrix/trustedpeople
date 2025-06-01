import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/Home/models/ActivityUpdate.dart';
import 'package:trustedtallentsvalley/fetures/Home/providers/home_notifier.dart';
import 'package:trustedtallentsvalley/routs/route_generator.dart';

class UserActivityWidget extends ConsumerWidget {
  const UserActivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(publicActivitiesProvider);

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
          Text(
            'آخر التحديثات',
            style: GoogleFonts.cairo(
              textStyle: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentUpdates (ref),

          // Add the "View All Updates" button
          activitiesAsync.when(
            data: (activities) {
              if (activities.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        // Navigate to all updates screen
                        context.pushNamed(ScreensNames.updates);
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        'عرض جميع التحديثات',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink(); // No button if no activities
              }
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdates(WidgetRef ref) {
    final activitiesAsync = ref.watch(publicActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'لا توجد تحديثات حالياً',
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
            return _buildActivityItem(context, activity);
          },
        );
      },
      loading: () => const Center(
          child: SizedBox(
        height: 50,
        child: CircularProgressIndicator(),
      )),
      error: (error, stackTrace) {
        // Log the error for debugging
        debugPrint('Error loading activities: $error');
        debugPrint('Stack trace: $stackTrace');

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'حدث خطأ في تحميل التحديثات',
                style: GoogleFonts.cairo(color: Colors.red),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Refresh the provider
                  ref.refresh(publicActivitiesProvider);
                },
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, Activity activity) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
