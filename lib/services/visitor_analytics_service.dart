// lib/services/visitor_analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitorAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Record a unique daily visit - call this when the app starts
  Future<void> recordUniqueVisit() async {
    try {
      // Get today's date in YYYY-MM-DD format
      final String today = DateTime.now().toString().substring(0, 10);

      // Check if this device/user has already been counted today
      final prefs = await SharedPreferences.getInstance();
      final String visitDateKey = 'last_visit_date';
      final String lastVisitDate = prefs.getString(visitDateKey) ?? '';

      // If already visited today, don't count again
      if (lastVisitDate == today) {
        debugPrint(
            'User already counted today - not incrementing visitor count');
        return;
      }

      // Store today's date as last visit
      await prefs.setString(visitDateKey, today);

      // Increment the unique visitor count for today
      final docRef = _firestore.collection('visitor_stats').doc(today);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // First visitor today
          transaction.set(docRef, {
            'uniqueVisitors': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Another unique visitor today
          final currentCount = snapshot.data()?['uniqueVisitors'] ?? 0;
          transaction.update(docRef, {
            'uniqueVisitors': currentCount + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      // Also update total stats
      final statsRef = _firestore.collection('visitor_stats').doc('totals');

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(statsRef);

        if (!snapshot.exists) {
          // Initialize stats
          final Map<String, dynamic> dailyStats = {};
          dailyStats[today] = 1;

          transaction.set(statsRef, {
            'totalUniqueVisitors': 1,
            'dailyVisitors': dailyStats,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // Update existing stats
          final data = snapshot.data()!;
          final totalCount = (data['totalUniqueVisitors'] ?? 0) + 1;

          // Update daily breakdown
          final Map<String, dynamic> dailyStats =
              Map<String, dynamic>.from(data['dailyVisitors'] ?? {});
          dailyStats[today] = (dailyStats[today] ?? 0) + 1;

          transaction.update(statsRef, {
            'totalUniqueVisitors': totalCount,
            'dailyVisitors': dailyStats,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      debugPrint('Recorded new unique visit for today: $today');
    } catch (e) {
      debugPrint('Error recording unique visit: $e');
    }
  }

  // Get analytics data for dashboard
  Future<Map<String, dynamic>> getVisitorStats() async {
    final String today = DateTime.now().toString().substring(0, 10);
    final String yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .substring(0, 10);

    // Get today's unique visitors
    final todayDoc =
        await _firestore.collection('visitor_stats').doc(today).get();
    int todayVisitors = 0;
    if (todayDoc.exists && todayDoc.data() != null) {
      todayVisitors = todayDoc.data()!['uniqueVisitors'] ?? 0;
    }

    // Get yesterday's unique visitors
    final yesterdayDoc =
        await _firestore.collection('visitor_stats').doc(yesterday).get();
    int yesterdayVisitors = 0;
    if (yesterdayDoc.exists && yesterdayDoc.data() != null) {
      yesterdayVisitors = yesterdayDoc.data()!['uniqueVisitors'] ?? 0;
    }

    // Calculate percentage change
    double percentChange = 0;
    if (yesterdayVisitors > 0) {
      percentChange =
          ((todayVisitors - yesterdayVisitors) / yesterdayVisitors) * 100;
    }

    // Get total unique visitors
    final totalsDoc =
        await _firestore.collection('visitor_stats').doc('totals').get();
    int totalVisitors = 0;
    if (totalsDoc.exists && totalsDoc.data() != null) {
      totalVisitors = totalsDoc.data()!['totalUniqueVisitors'] ?? 0;
    }

    // Calculate monthly unique visitors
    int monthlyVisitors = 0;
    if (totalsDoc.exists &&
        totalsDoc.data() != null &&
        totalsDoc.data()!.containsKey('dailyVisitors')) {
      final Map<String, dynamic> dailyStats =
          Map<String, dynamic>.from(totalsDoc.data()!['dailyVisitors']);

      // Calculate date 30 days ago
      final monthAgo = DateTime.now().subtract(const Duration(days: 30));

      dailyStats.forEach((date, count) {
        try {
          final visitDate = DateTime.parse(date);
          if (visitDate.isAfter(monthAgo)) {
            monthlyVisitors += (count as num).toInt();
          }
        } catch (e) {
          // Skip invalid dates
        }
      });
    }

    return {
      'todayVisitors': todayVisitors,
      'percentChange': percentChange,
      'totalVisitors': totalVisitors,
      'monthlyVisitors': monthlyVisitors,
    };
  }

  // Get chart data for last 7 days
  Future<List<Map<String, dynamic>>> getVisitorChartData() async {
    final List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final String dateStr = date.toString().substring(0, 10);
      final doc =
          await _firestore.collection('visitor_stats').doc(dateStr).get();

      int visitors = 0;
      if (doc.exists && doc.data() != null) {
        visitors = doc.data()!['uniqueVisitors'] ?? 0;
      }

      result.add({
        'date': dateStr,
        'visits': visitors,
        'day': _getDayName(date.weekday),
      });
    }

    return result;
  }

  String _getDayName(int weekday) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد'
    ];
    return days[weekday - 1];
  }
}
