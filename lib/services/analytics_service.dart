// lib/services/analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Track page views
  Future<void> logPageView(String pageName) async {
    await _analytics.logScreenView(screenName: pageName);
    await _incrementPageViewCount(pageName);
  }

  // Track user login
  Future<void> logLogin() async {
    await _analytics.logLogin();
    await _incrementDailyVisitorCount();
  }

  // Increment visit counter in Firestore
  Future<void> _incrementPageViewCount(String pageName) async {
    // Get current date in YYYY-MM-DD format
    final String today = DateTime.now().toString().substring(0, 10);

    // Reference to the analytics document for today
    final docRef = _firestore.collection('analytics').doc(today);

    // Update the counts using transaction to handle concurrent updates
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // Create new document if it doesn't exist
        transaction.set(docRef, {
          'totalVisits': 1,
          'pageViews': {pageName: 1},
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing document
        final Map<String, dynamic> data = snapshot.data()!;
        final int totalVisits = (data['totalVisits'] ?? 0) + 1;

        // Update or create the page view count
        final Map<String, dynamic> pageViews =
            Map<String, dynamic>.from(data['pageViews'] ?? {});
        pageViews[pageName] = (pageViews[pageName] ?? 0) + 1;

        transaction.update(docRef, {
          'totalVisits': totalVisits,
          'pageViews': pageViews,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Increment daily unique visitor count
  Future<void> _incrementDailyVisitorCount() async {
    final String today = DateTime.now().toString().substring(0, 10);
    final docRef = _firestore.collection('analytics').doc('visitors');

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, {
          'dailyVisitors': {today: 1},
          'totalVisitors': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        final Map<String, dynamic> data = snapshot.data()!;
        final Map<String, dynamic> dailyVisitors =
            Map<String, dynamic>.from(data['dailyVisitors'] ?? {});

        // Increment today's visitor count
        dailyVisitors[today] = (dailyVisitors[today] ?? 0) + 1;

        transaction.update(docRef, {
          'dailyVisitors': dailyVisitors,
          'totalVisitors': FieldValue.increment(1),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Get analytics data for dashboard
  Future<Map<String, dynamic>> getAnalyticsData() async {
    final String today = DateTime.now().toString().substring(0, 10);
    final String yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .substring(0, 10);

    // Get today's analytics
    final todayDoc = await _firestore.collection('analytics').doc(today).get();
    final yesterdayDoc =
        await _firestore.collection('analytics').doc(yesterday).get();
    final visitorsDoc =
        await _firestore.collection('analytics').doc('visitors').get();

    // Calculate visits for today
    int todayVisits = 0;
    if (todayDoc.exists == true && todayDoc.data() != null) {
      final data = todayDoc.data()!;
      if (data.containsKey('totalVisits')) {
        todayVisits = (data['totalVisits'] as num).toInt();
      }
    }

    int yesterdayVisits = 0;
    if (yesterdayDoc.exists == true && yesterdayDoc.data() != null) {
      final data = yesterdayDoc.data()!;
      if (data.containsKey('totalVisits')) {
        yesterdayVisits = (data['totalVisits'] as num).toInt();
      }
    }
    // Calculate percentage change
    final double percentChange = yesterdayVisits > 0
        ? ((todayVisits - yesterdayVisits) / yesterdayVisits) * 100
        : 0.0;

    // Get total visitors
    final int totalVisitors = visitorsDoc.exists == true
        ? (visitorsDoc.data()?['totalVisitors'] as num?)?.toInt() ?? 0
        : 0;

// Get monthly visits (last 30 days)
    int monthlyVisits = 0;
    for (int i = 0; i < 30; i++) {
      final String date = DateTime.now()
          .subtract(Duration(days: i))
          .toString()
          .substring(0, 10);
      final doc = await _firestore.collection('analytics').doc(date).get();
      if (doc.exists == true && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('totalVisits')) {
          monthlyVisits += (data['totalVisits'] as num?)?.toInt() ?? 0;
        }
      }
    }

    // Get average session duration (this would require more complex tracking)
    // For now, we'll use a placeholder value
    const String avgSessionDuration = "3:24";

    return {
      'todayVisits': todayVisits,
      'percentChange': percentChange,
      'totalVisitors': totalVisitors,
      'monthlyVisits': monthlyVisits,
      'avgSessionDuration': avgSessionDuration,
    };
  }

  // Get data for chart (last 7 days)
  Future<List<Map<String, dynamic>>> getChartData() async {
    final List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final String dateStr = date.toString().substring(0, 10);
      final doc = await _firestore.collection('analytics').doc(dateStr).get();

      int visits = 0;
      if (doc.exists) {
        visits = doc.data()?['totalVisits'] ?? 0;
      }

      result.add({
        'date': dateStr,
        'visits': visits,
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
