// lib/features/admin/dashboard/data/datasources/analytics_datasource.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';

class AnalyticsDatasource {
  final FirebaseFirestore _firestore;

  AnalyticsDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Records a unique visit in Firestore
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

      // Silently collect visitor data (IP and location)
      final visitorData = await _collectVisitorData();

      // Increment the unique visitor count for today
      final docRef =
          _firestore.collection(FirebaseConstants.visitorStats).doc(today);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // First visitor today
          transaction.set(docRef, {
            'uniqueVisitors': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'visitors': FieldValue.arrayUnion([visitorData]),
          });
        } else {
          // Another unique visitor today
          final currentCount = snapshot.data()?['uniqueVisitors'] ?? 0;
          transaction.update(docRef, {
            'uniqueVisitors': currentCount + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'visitors': FieldValue.arrayUnion([visitorData]),
          });
        }
      });

      // Also update total stats
      final statsRef =
          _firestore.collection(FirebaseConstants.visitorStats).doc('totals');

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

  // Collect visitor data for analytics
  Future<Map<String, dynamic>> _collectVisitorData() async {
    Map<String, dynamic> visitorData = {
      'timestamp': DateTime.now().toIso8601String(),
      'userAgent': kIsWeb ? 'Web Browser' : 'Mobile App',
    };

    try {
      // Get IP address using a free service
      final ipResponse =
          await http.get(Uri.parse('https://api64.ipify.org?format=json'));

      if (ipResponse.statusCode == 200) {
        final ipData = json.decode(ipResponse.body);
        final ip = ipData['ip'];
        visitorData['ipAddress'] = ip;

        // Get location data from IP address
        final geoResponse =
            await http.get(Uri.parse('https://ipapi.co/$ip/json/'));

        if (geoResponse.statusCode == 200) {
          final locationData = json.decode(geoResponse.body);
          visitorData['country'] = locationData['country_name'] ?? 'Unknown';
          visitorData['city'] = locationData['city'] ?? 'Unknown';
          visitorData['region'] = locationData['region'] ?? 'Unknown';
          visitorData['latitude'] = locationData['latitude'] ?? 0.0;
          visitorData['longitude'] = locationData['longitude'] ?? 0.0;
        }
      }
    } catch (e) {
      debugPrint('Error collecting visitor data: $e');
    }

    return visitorData;
  }

  // Get visitor statistics
  Future<Map<String, dynamic>> getVisitorStats() async {
    final String today = DateTime.now().toString().substring(0, 10);
    final String yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toString()
        .substring(0, 10);

    // Get today's unique visitors
    final todayDoc = await _firestore
        .collection(FirebaseConstants.visitorStats)
        .doc(today)
        .get();
    int todayVisitors = 0;
    if (todayDoc.exists && todayDoc.data() != null) {
      todayVisitors = todayDoc.data()!['uniqueVisitors'] ?? 0;
    }

    // Get yesterday's unique visitors
    final yesterdayDoc = await _firestore
        .collection(FirebaseConstants.visitorStats)
        .doc(yesterday)
        .get();
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
    final totalsDoc = await _firestore
        .collection(FirebaseConstants.visitorStats)
        .doc('totals')
        .get();
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
      'avgSessionDuration':
          '3:24', // Placeholder, implement actual calculation if needed
    };
  }

  // Get chart data for visualizing visitor trends
  Future<List<Map<String, dynamic>>> getVisitorChartData() async {
    final List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final String dateStr = date.toString().substring(0, 10);
      final doc = await _firestore
          .collection(FirebaseConstants.visitorStats)
          .doc(dateStr)
          .get();

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

  // Get visitor location data for the map
  Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
    final List<Map<String, dynamic>> result = [];

    try {
      // Get data for the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final String fromDate = thirtyDaysAgo.toString().substring(0, 10);

      final query = _firestore
          .collection(FirebaseConstants.visitorStats)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromDate)
          .orderBy(FieldPath.documentId, descending: true);

      final querySnapshot = await query.get();

      for (var doc in querySnapshot.docs) {
        // Skip the totals document
        if (doc.id == 'totals') continue;

        final data = doc.data();
        if (data.containsKey('visitors')) {
          final List<dynamic> visitors = data['visitors'];
          for (var visitor in visitors) {
            if (visitor is Map<String, dynamic>) {
              // Only add visitors with IP and location data
              if (visitor.containsKey('ipAddress') &&
                  visitor.containsKey('latitude') &&
                  visitor.containsKey('longitude')) {
                result.add({
                  'date': doc.id,
                  'timestamp': visitor['timestamp'],
                  'ipAddress': visitor['ipAddress'],
                  'country': visitor['country'] ?? 'Unknown',
                  'city': visitor['city'] ?? 'Unknown',
                  'region': visitor['region'] ?? 'Unknown',
                  'latitude': visitor['latitude'] ?? 0.0,
                  'longitude': visitor['longitude'] ?? 0.0,
                });
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting visitor location data: $e');
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
