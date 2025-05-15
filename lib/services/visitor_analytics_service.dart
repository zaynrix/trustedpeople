// lib/services/visitor_analytics_service.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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

      // Silently collect visitor data (IP and location)
      final visitorData = await _collectVisitorData();

      // Increment the unique visitor count for today
      final docRef = _firestore.collection('visitor_stats').doc(today);

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

  // Silently collect visitor data
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
        final geoResponse = await http.get(
          Uri.parse('https://ipapi.co/$ip/json/'),
        );

        if (geoResponse.statusCode == 200) {
          final locationData = json.decode(geoResponse.body);
          visitorData['location'] = {
            'country': locationData['country_name'] ?? 'Unknown',
            'city': locationData['city'] ?? 'Unknown',
            'region': locationData['region'] ?? 'Unknown',
            'latitude': locationData['latitude'] ?? 0.0,
            'longitude': locationData['longitude'] ?? 0.0,
          };
        }
      }
    } catch (e) {
      debugPrint('Error collecting IP/location data: $e');
    }

    return visitorData;
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
      'avgSessionDuration':
          '3:24', // Placeholder - implement actual calculation if needed
    };
  }

  // Get visitor location data for admin dashboard
  Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
    final List<Map<String, dynamic>> result = [];

    try {
      // Get data for the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final String fromDate = thirtyDaysAgo.toString().substring(0, 10);

      final query = _firestore
          .collection('visitor_stats')
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
                  visitor.containsKey('location')) {
                final locationData =
                    visitor['location'] as Map<String, dynamic>;
                result.add({
                  'date': doc.id,
                  'timestamp': visitor['timestamp'],
                  'ipAddress': visitor['ipAddress'],
                  'country': locationData['country'],
                  'city': locationData['city'],
                  'region': locationData['region'],
                  'latitude': locationData['latitude'],
                  'longitude': locationData['longitude'],
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

  // Get chart data for last 7 days (existing method)
  Future<List<Map<String, dynamic>>> getVisitorChartData() async {
    // Your existing implementation
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
// class VisitorAnalyticsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   // Record a unique daily visit - call this when the app starts
//   Future<void> recordUniqueVisit() async {
//     try {
//       // Get today's date in YYYY-MM-DD format
//       final String today = DateTime.now().toString().substring(0, 10);
//
//       // Check if this device/user has already been counted today
//       final prefs = await SharedPreferences.getInstance();
//       final String visitDateKey = 'last_visit_date';
//       final String lastVisitDate = prefs.getString(visitDateKey) ?? '';
//
//       // If already visited today, don't count again
//       if (lastVisitDate == today) {
//         debugPrint(
//             'User already counted today - not incrementing visitor count');
//         return;
//       }
//
//       // Store today's date as last visit
//       await prefs.setString(visitDateKey, today);
//
//       // Collect IP and location data silently
//       Map<String, dynamic> visitorData = await _collectVisitorData();
//
//       // Increment the unique visitor count for today and store visitor data
//       final docRef = _firestore.collection('visitor_stats').doc(today);
//
//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(docRef);
//
//         if (!snapshot.exists) {
//           // First visitor today
//           transaction.set(docRef, {
//             'uniqueVisitors': 1,
//             'lastUpdated': FieldValue.serverTimestamp(),
//             'visitors': FieldValue.arrayUnion([visitorData]),
//           });
//         } else {
//           // Another unique visitor today
//           final currentCount = snapshot.data()?['uniqueVisitors'] ?? 0;
//           transaction.update(docRef, {
//             'uniqueVisitors': currentCount + 1,
//             'lastUpdated': FieldValue.serverTimestamp(),
//             'visitors': FieldValue.arrayUnion([visitorData]),
//           });
//         }
//       });
//
//       // Also update total stats
//       final statsRef = _firestore.collection('visitor_stats').doc('totals');
//
//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(statsRef);
//
//         if (!snapshot.exists) {
//           // Initialize stats
//           final Map<String, dynamic> dailyStats = {};
//           dailyStats[today] = 1;
//
//           transaction.set(statsRef, {
//             'totalUniqueVisitors': 1,
//             'dailyVisitors': dailyStats,
//             'lastUpdated': FieldValue.serverTimestamp(),
//           });
//         } else {
//           // Update existing stats
//           final data = snapshot.data()!;
//           final totalCount = (data['totalUniqueVisitors'] ?? 0) + 1;
//
//           // Update daily breakdown
//           final Map<String, dynamic> dailyStats =
//               Map<String, dynamic>.from(data['dailyVisitors'] ?? {});
//           dailyStats[today] = (dailyStats[today] ?? 0) + 1;
//
//           transaction.update(statsRef, {
//             'totalUniqueVisitors': totalCount,
//             'dailyVisitors': dailyStats,
//             'lastUpdated': FieldValue.serverTimestamp(),
//           });
//         }
//       });
//
//       debugPrint('Recorded new unique visit for today: $today');
//     } catch (e) {
//       debugPrint('Error recording unique visit: $e');
//     }
//   }
//
//   // Collect visitor data silently
//   Future<Map<String, dynamic>> _collectVisitorData() async {
//     Map<String, dynamic> visitorData = {
//       'timestamp': DateTime.now().toIso8601String(),
//       'userAgent': await _getUserAgent(),
//       'deviceInfo': await _getDeviceInfo(),
//     };
//
//     try {
//       // Use an IP API service to get IP address and location
//       // This uses ipify.org for demonstration - consider a more robust solution
//       final response =
//           await http.get(Uri.parse('https://api64.ipify.org?format=json'));
//
//       if (response.statusCode == 200) {
//         final ipData = json.decode(response.body);
//         final ip = ipData['ip'];
//         visitorData['ipAddress'] = ip;
//
//         // Now get geolocation data from the IP
//         final geoResponse = await http.get(
//           Uri.parse('https://ipapi.co/$ip/json/'),
//         );
//
//         if (geoResponse.statusCode == 200) {
//           final locationData = json.decode(geoResponse.body);
//           visitorData['location'] = {
//             'country': locationData['country_name'],
//             'city': locationData['city'],
//             'region': locationData['region'],
//             'latitude': locationData['latitude'],
//             'longitude': locationData['longitude'],
//           };
//         }
//       }
//     } catch (e) {
//       debugPrint('Error collecting visitor data: $e');
//     }
//
//     return visitorData;
//   }
//
//   // Get user agent string
//   Future<String> _getUserAgent() async {
//     try {
//       // This requires a JavaScript bridge or platform channel in real implementation
//       // For web, we could use html package, but for simplicity we'll return a placeholder
//       return 'Flutter App';
//     } catch (e) {
//       return 'Unknown';
//     }
//   }
//
//   // Get device info
//   Future<Map<String, dynamic>> _getDeviceInfo() async {
//     try {
//       // This is a simplified version - you'd use device_info_plus in practice
//       return {
//         'platform': kIsWeb ? 'web' : 'mobile',
//         'isWeb': kIsWeb,
//       };
//     } catch (e) {
//       return {'platform': 'unknown'};
//     }
//   }
//
//   // Get analytics data for dashboard
//   Future<Map<String, dynamic>> getVisitorStats() async {
//     final String today = DateTime.now().toString().substring(0, 10);
//     final String yesterday = DateTime.now()
//         .subtract(const Duration(days: 1))
//         .toString()
//         .substring(0, 10);
//
//     // Get today's unique visitors
//     final todayDoc =
//         await _firestore.collection('visitor_stats').doc(today).get();
//     int todayVisitors = 0;
//     if (todayDoc.exists && todayDoc.data() != null) {
//       todayVisitors = todayDoc.data()!['uniqueVisitors'] ?? 0;
//     }
//
//     // Get yesterday's unique visitors
//     final yesterdayDoc =
//         await _firestore.collection('visitor_stats').doc(yesterday).get();
//     int yesterdayVisitors = 0;
//     if (yesterdayDoc.exists && yesterdayDoc.data() != null) {
//       yesterdayVisitors = yesterdayDoc.data()!['uniqueVisitors'] ?? 0;
//     }
//
//     // Calculate percentage change
//     double percentChange = 0;
//     if (yesterdayVisitors > 0) {
//       percentChange =
//           ((todayVisitors - yesterdayVisitors) / yesterdayVisitors) * 100;
//     }
//
//     // Get total unique visitors
//     final totalsDoc =
//         await _firestore.collection('visitor_stats').doc('totals').get();
//     int totalVisitors = 0;
//     if (totalsDoc.exists && totalsDoc.data() != null) {
//       totalVisitors = totalsDoc.data()!['totalUniqueVisitors'] ?? 0;
//     }
//
//     // Calculate monthly unique visitors
//     int monthlyVisitors = 0;
//     if (totalsDoc.exists &&
//         totalsDoc.data() != null &&
//         totalsDoc.data()!.containsKey('dailyVisitors')) {
//       final Map<String, dynamic> dailyStats =
//           Map<String, dynamic>.from(totalsDoc.data()!['dailyVisitors']);
//
//       // Calculate date 30 days ago
//       final monthAgo = DateTime.now().subtract(const Duration(days: 30));
//
//       dailyStats.forEach((date, count) {
//         try {
//           final visitDate = DateTime.parse(date);
//           if (visitDate.isAfter(monthAgo)) {
//             monthlyVisitors += (count as num).toInt();
//           }
//         } catch (e) {
//           // Skip invalid dates
//         }
//       });
//     }
//
//     return {
//       'todayVisitors': todayVisitors,
//       'percentChange': percentChange,
//       'totalVisitors': totalVisitors,
//       'monthlyVisitors': monthlyVisitors,
//     };
//   }
//
//   // Get chart data for last 7 days
//   Future<List<Map<String, dynamic>>> getVisitorChartData() async {
//     final List<Map<String, dynamic>> result = [];
//
//     for (int i = 6; i >= 0; i--) {
//       final date = DateTime.now().subtract(Duration(days: i));
//       final String dateStr = date.toString().substring(0, 10);
//       final doc =
//           await _firestore.collection('visitor_stats').doc(dateStr).get();
//
//       int visitors = 0;
//       if (doc.exists && doc.data() != null) {
//         visitors = doc.data()!['uniqueVisitors'] ?? 0;
//       }
//
//       result.add({
//         'date': dateStr,
//         'visits': visitors,
//         'day': _getDayName(date.weekday),
//       });
//     }
//
//     return result;
//   }
//
//   String _getDayName(int weekday) {
//     const days = [
//       'الاثنين',
//       'الثلاثاء',
//       'الأربعاء',
//       'الخميس',
//       'الجمعة',
//       'السبت',
//       'الأحد'
//     ];
//     return days[weekday - 1];
//   }
//
//   Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
//     final result = <Map<String, dynamic>>[];
//
//     // Get data for the last 30 days
//     final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
//     final String fromDate = thirtyDaysAgo.toString().substring(0, 10);
//
//     final snapshots = await _firestore
//         .collection('visitor_stats')
//         .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromDate)
//         .get();
//
//     for (var doc in snapshots.docs) {
//       if (doc.id != 'totals' && doc.data().containsKey('visitors')) {
//         final visitors = doc.data()['visitors'] as List<dynamic>;
//         for (var visitor in visitors) {
//           if (visitor is Map<String, dynamic> &&
//               visitor.containsKey('location') &&
//               visitor.containsKey('ipAddress')) {
//             result.add({
//               'date': doc.id,
//               'ipAddress': visitor['ipAddress'],
//               'location': visitor['location'],
//               'timestamp': visitor['timestamp'],
//             });
//           }
//         }
//       }
//     }
//
//     return result;
//   }
// }
