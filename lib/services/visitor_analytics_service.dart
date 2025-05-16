// lib/services/visitor_analytics_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
//
// class VisitorAnalyticsService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
//       'avgSessionDuration':
//           '3:24', // Placeholder - implement actual calculation if needed
//     };
//   }
//
//   // Get visitor location data for admin dashboard
//   Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
//     final List<Map<String, dynamic>> result = [];
//
//     try {
//       // Get data for the last 30 days
//       final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
//       final String fromDate = thirtyDaysAgo.toString().substring(0, 10);
//
//       final query = _firestore
//           .collection('visitor_stats')
//           .where(FieldPath.documentId, isGreaterThanOrEqualTo: fromDate)
//           .orderBy(FieldPath.documentId, descending: true);
//
//       final querySnapshot = await query.get();
//
//       for (var doc in querySnapshot.docs) {
//         // Skip the totals document
//         if (doc.id == 'totals') continue;
//
//         final data = doc.data();
//         if (data.containsKey('visitors')) {
//           final List<dynamic> visitors = data['visitors'];
//           for (var visitor in visitors) {
//             if (visitor is Map<String, dynamic>) {
//               // Only add visitors with IP and location data
//               if (visitor.containsKey('ipAddress') &&
//                   visitor.containsKey('location')) {
//                 final locationData =
//                     visitor['location'] as Map<String, dynamic>;
//                 result.add({
//                   'date': doc.id,
//                   'timestamp': visitor['timestamp'],
//                   'ipAddress': visitor['ipAddress'],
//                   'country': locationData['country'],
//                   'city': locationData['city'],
//                   'region': locationData['region'],
//                   'latitude': locationData['latitude'],
//                   'longitude': locationData['longitude'],
//                 });
//               }
//             }
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error getting visitor location data: $e');
//     }
//
//     return result;
//   }
//
//   // Get chart data for last 7 days (existing method)
//   Future<List<Map<String, dynamic>>> getVisitorChartData() async {
//     // Your existing implementation
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
//   Future<bool> recordUniqueVisit() async {
//     try {
//       // Get today's date in YYYY-MM-DD format
//       final String today = DateTime.now().toString().substring(0, 10);
//
//       // For web, use localStorage directly
//       if (kIsWeb) {
//         final String lastVisitDate =
//             html.window.localStorage['last_visit_date'] ?? '';
//
//         // If already visited today, don't count again
//         if (lastVisitDate == today) {
//           debugPrint(
//               'User already counted today via localStorage - not incrementing visitor count');
//           return false;
//         }
//
//         // Store today's date as last visit in localStorage
//         html.window.localStorage['last_visit_date'] = today;
//         debugPrint('Saved visit date to localStorage: $today');
//       } else {
//         // For non-web platforms, use SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         final String visitDateKey = 'last_visit_date';
//         final String lastVisitDate = prefs.getString(visitDateKey) ?? '';
//
//         // If already visited today, don't count again
//         if (lastVisitDate == today) {
//           debugPrint(
//               'User already counted today - not incrementing visitor count');
//           return false;
//         }
//
//         // Store today's date as last visit
//         await prefs.setString(visitDateKey, today);
//       }
//
//       // Silently collect visitor data (IP and location)
//       final visitorData = await _collectVisitorData();
//
//       // Increment the unique visitor count for today
//       final docRef = _firestore.collection('visitor_stats').doc(today);
//
//       bool isNewVisit = false;
//
//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(docRef);
//
//         if (!snapshot.exists) {
//           // First visitor today
//           transaction.set(docRef, {
//             'uniqueVisitors': 1,
//             'lastUpdated': FieldValue.serverTimestamp(),
//             'visitors': [visitorData],
//           });
//           isNewVisit = true;
//           debugPrint('Created new document for today with 1 visitor');
//         } else {
//           // Another unique visitor today
//           final currentCount = snapshot.data()?['uniqueVisitors'] ?? 0;
//           transaction.update(docRef, {
//             'uniqueVisitors': currentCount + 1,
//             'lastUpdated': FieldValue.serverTimestamp(),
//             'visitors': FieldValue.arrayUnion([visitorData]),
//           });
//           isNewVisit = true;
//           debugPrint('Updated visitor count to ${currentCount + 1}');
//         }
//       });
//
//       // Also update total stats
//       if (isNewVisit) {
//         final statsRef = _firestore.collection('visitor_stats').doc('totals');
//
//         await _firestore.runTransaction((transaction) async {
//           final snapshot = await transaction.get(statsRef);
//
//           if (!snapshot.exists) {
//             // Initialize stats
//             final Map<String, dynamic> dailyStats = {};
//             dailyStats[today] = 1;
//
//             transaction.set(statsRef, {
//               'totalUniqueVisitors': 1,
//               'dailyVisitors': dailyStats,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             });
//           } else {
//             // Update existing stats
//             final data = snapshot.data()!;
//             final totalCount = (data['totalUniqueVisitors'] ?? 0) + 1;
//
//             // Update daily breakdown
//             final Map<String, dynamic> dailyStats =
//                 Map<String, dynamic>.from(data['dailyVisitors'] ?? {});
//             dailyStats[today] = (dailyStats[today] ?? 0) + 1;
//
//             transaction.update(statsRef, {
//               'totalUniqueVisitors': totalCount,
//               'dailyVisitors': dailyStats,
//               'lastUpdated': FieldValue.serverTimestamp(),
//             });
//           }
//         });
//       }
//
//       debugPrint('Recorded new unique visit for today: $today');
//       return isNewVisit;
//     } catch (e) {
//       debugPrint('Error recording unique visit: $e');
//       return false;
//     }
//   }
//
//   Future<bool> forceRecordVisit() async {
//     try {
//       if (kIsWeb) {
//         // Clear the last visit from localStorage
//         html.window.localStorage.remove('last_visit_date');
//       } else {
//         // For non-web platforms, use SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('last_visit_date');
//       }
//
//       // Record a new visit
//       return await recordUniqueVisit();
//     } catch (e) {
//       debugPrint('Error forcing visit record: $e');
//       return false;
//     }
//   }
//
// // Enhanced data collection for more visitor details
//   // Enhanced data collection for more visitor details
//   Future<Map<String, dynamic>> _collectVisitorData() async {
//     Map<String, dynamic> visitorData = {
//       'timestamp': DateTime.now().toIso8601String(),
//       'visitDate': DateTime.now().toString().substring(0, 10),
//       'visitTime': DateFormat('HH:mm:ss').format(DateTime.now()),
//     };
//
//     if (kIsWeb) {
//       try {
//         // Browser & Device Information
//         visitorData['userAgent'] = html.window.navigator.userAgent;
//         visitorData['appCodeName'] = html.window.navigator.appCodeName;
//         visitorData['appName'] = html.window.navigator.appName;
//         visitorData['appVersion'] = html.window.navigator.appVersion;
//         visitorData['platform'] = html.window.navigator.platform;
//         visitorData['vendor'] = html.window.navigator.vendor;
//
//         // Detect browser type
//         final userAgent = html.window.navigator.userAgent.toLowerCase();
//         if (userAgent.contains('firefox')) {
//           visitorData['browser'] = 'Firefox';
//         } else if (userAgent.contains('chrome') &&
//             !userAgent.contains('edge')) {
//           visitorData['browser'] = 'Chrome';
//         } else if (userAgent.contains('safari') &&
//             !userAgent.contains('chrome')) {
//           visitorData['browser'] = 'Safari';
//         } else if (userAgent.contains('edge') || userAgent.contains('edg')) {
//           visitorData['browser'] = 'Edge';
//         } else if (userAgent.contains('opera') || userAgent.contains('opr')) {
//           visitorData['browser'] = 'Opera';
//         } else {
//           visitorData['browser'] = 'Other';
//         }
//
//         // Detect mobile vs desktop
//         visitorData['isMobile'] = userAgent.contains('mobile') ||
//             userAgent.contains('android') ||
//             userAgent.contains('iphone');
//
//         // Screen Information
//         try {
//           visitorData['screen'] = {
//             'width': html.window.screen?.width,
//             'height': html.window.screen?.height,
//             'pixelRatio': html.window.devicePixelRatio,
//             'colorDepth': html.window.screen?.colorDepth,
//           };
//         } catch (e) {
//           visitorData['screen'] = {'error': 'Unable to get screen information'};
//         }
//
//         // Viewport size (visible area)
//         try {
//           visitorData['viewport'] = {
//             'width': html.window.innerWidth,
//             'height': html.window.innerHeight,
//           };
//         } catch (e) {
//           visitorData['viewport'] = {
//             'error': 'Unable to get viewport information'
//           };
//         }
//
//         // Language & Time settings
//         visitorData['language'] = html.window.navigator.language;
//         visitorData['timeZone'] = DateTime.now().timeZoneName;
//         visitorData['timeZoneOffset'] = DateTime.now().timeZoneOffset.inMinutes;
//
//         // Connection information - use JS interop for better compatibility
//         try {
//           // Check if connection property exists using JS interop
//           if (js.context['navigator'].hasProperty('connection')) {
//             var conn = js.context['navigator']['connection'];
//             visitorData['connection'] = {
//               'effectiveType': conn.hasProperty('effectiveType')
//                   ? conn['effectiveType']
//                   : 'unknown',
//               'downlink':
//                   conn.hasProperty('downlink') ? conn['downlink'] : 'unknown',
//               'rtt': conn.hasProperty('rtt') ? conn['rtt'] : 'unknown',
//               'saveData':
//                   conn.hasProperty('saveData') ? conn['saveData'] : false,
//             };
//           }
//         } catch (e) {
//           debugPrint('Error getting connection info: $e');
//         }
//
//         // Referrer - use JS interop for better compatibility
//         try {
//           final referrer = js.context['document']['referrer'];
//           if (referrer != null && referrer is String && referrer.isNotEmpty) {
//             visitorData['referrer'] = referrer;
//           }
//         } catch (e) {
//           debugPrint('Error accessing referrer: $e');
//         }
//
//         // Current URL path
//         try {
//           visitorData['currentPath'] = html.window.location.pathname;
//           visitorData['fullUrl'] = html.window.location.href;
//         } catch (e) {
//           debugPrint('Error getting URL path: $e');
//         }
//
//         // Check cookies enabled
//         try {
//           visitorData['cookiesEnabled'] = html.window.navigator.cookieEnabled;
//         } catch (e) {
//           debugPrint('Error checking cookies: $e');
//         }
//
//         // Check for Do Not Track setting
//         try {
//           // Different browsers handle this differently
//           var dntProperty = js.context['navigator']['doNotTrack'] ??
//               js.context['navigator']['msDoNotTrack'] ??
//               js.context['window']['doNotTrack'];
//           visitorData['doNotTrack'] =
//               (dntProperty == '1' || dntProperty == 'yes');
//         } catch (e) {
//           debugPrint('Error checking DNT: $e');
//         }
//
//         // Device memory and hardware concurrency using JS interop
//         try {
//           if (js.context['navigator'].hasProperty('deviceMemory')) {
//             visitorData['deviceMemory'] =
//                 js.context['navigator']['deviceMemory'];
//           }
//
//           if (js.context['navigator'].hasProperty('hardwareConcurrency')) {
//             visitorData['hardwareConcurrency'] =
//                 js.context['navigator']['hardwareConcurrency'];
//           }
//         } catch (e) {
//           debugPrint('Error accessing hardware info: $e');
//         }
//
//         // Touch points (to detect touch capability)
//         try {
//           visitorData['maxTouchPoints'] = html.window.navigator.maxTouchPoints;
//         } catch (e) {
//           debugPrint('Error getting touch points: $e');
//         }
//
//         // Previous visits from local storage
//         try {
//           final visitHistory = html.window.localStorage['visit_history'];
//           if (visitHistory != null && visitHistory.isNotEmpty) {
//             final history = json.decode(visitHistory);
//             visitorData['previousVisits'] = history;
//           }
//
//           // Update visit history
//           final newHistory = [];
//           if (visitHistory != null && visitHistory.isNotEmpty) {
//             newHistory.addAll(json.decode(visitHistory));
//           }
//
//           // Add current visit to history (keep last 5)
//           newHistory.add({
//             'date': DateTime.now().toString().substring(0, 10),
//             'time': DateFormat('HH:mm:ss').format(DateTime.now()),
//           });
//
//           // Keep only last 5 visits
//           if (newHistory.length > 5) {
//             newHistory.removeAt(0);
//           }
//
//           html.window.localStorage['visit_history'] = json.encode(newHistory);
//         } catch (e) {
//           debugPrint('Error managing visit history: $e');
//         }
//       } catch (e) {
//         debugPrint('Error collecting browser data: $e');
//         visitorData['browserDataError'] = e.toString();
//       }
//     } else {
//       // For non-web platforms
//       visitorData['platform'] = defaultTargetPlatform.toString();
//       visitorData['userAgent'] = 'Mobile App';
//     }
//
//     // Network/IP Information
//     try {
//       // Get public IP and related info
//       final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/'));
//       if (ipResponse.statusCode == 200) {
//         final ipData = json.decode(ipResponse.body);
//
//         // Add the IP address
//         if (ipData.containsKey('ip')) {
//           visitorData['ipAddress'] = ipData['ip'];
//         }
//
//         // Enhanced location data - with safe access
//         final location = <String, dynamic>{};
//
//         // Safely add properties
//         if (ipData.containsKey('country_name'))
//           location['country'] = ipData['country_name'];
//         if (ipData.containsKey('country_code'))
//           location['countryCode'] = ipData['country_code'];
//         if (ipData.containsKey('region')) location['region'] = ipData['region'];
//         if (ipData.containsKey('region_code'))
//           location['regionCode'] = ipData['region_code'];
//         if (ipData.containsKey('city')) location['city'] = ipData['city'];
//         if (ipData.containsKey('postal')) location['postal'] = ipData['postal'];
//         if (ipData.containsKey('latitude'))
//           location['latitude'] = ipData['latitude'];
//         if (ipData.containsKey('longitude'))
//           location['longitude'] = ipData['longitude'];
//         if (ipData.containsKey('timezone'))
//           location['timezone'] = ipData['timezone'];
//         if (ipData.containsKey('utc_offset'))
//           location['utcOffset'] = ipData['utc_offset'];
//         if (ipData.containsKey('country_calling_code'))
//           location['countryCallingCode'] = ipData['country_calling_code'];
//         if (ipData.containsKey('currency'))
//           location['currency'] = ipData['currency'];
//         if (ipData.containsKey('currency_name'))
//           location['currencyName'] = ipData['currency_name'];
//         if (ipData.containsKey('languages'))
//           location['languages'] = ipData['languages'];
//
//         if (location.isNotEmpty) {
//           visitorData['location'] = location;
//         }
//
//         // Network information
//         final network = <String, dynamic>{};
//         if (ipData.containsKey('asn')) network['asn'] = ipData['asn'];
//         if (ipData.containsKey('org')) network['org'] = ipData['org'];
//         if (network.isNotEmpty) {
//           visitorData['network'] = network;
//         }
//
//         // EU GDPR status
//         if (ipData.containsKey('in_eu')) {
//           visitorData['inEU'] = ipData['in_eu'];
//         }
//       } else {
//         visitorData['ipLookupError'] = 'HTTP ${ipResponse.statusCode}';
//       }
//     } catch (e) {
//       debugPrint('Error collecting IP/location data: $e');
//       visitorData['ipLookupError'] = e.toString();
//     }
//
//     return visitorData;
//   }
// }
//
// // Create a provider for the analytics service
// final visitorAnalyticsProvider = Provider<VisitorAnalyticsService>((ref) {
//   return VisitorAnalyticsService();
// });
//
// // Create a stream provider for real-time analytics updates
// final analyticsDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
//   final analytics = ref.watch(visitorAnalyticsProvider);
//
//   // Function to fetch data
//   Future<Map<String, dynamic>> fetchData() async {
//     return await analytics.getVisitorStats();
//   }
//
//   // Set up a periodic refresh
//   final controller = StreamController<Map<String, dynamic>>();
//
//   // Fetch initial data
//   fetchData().then((data) {
//     controller.add(data);
//   });
//
//   // Set up a periodic timer to refresh data every 30 seconds
//   final timer = Timer.periodic(const Duration(seconds: 30), (_) {
//     fetchData().then((data) {
//       controller.add(data);
//     });
//   });
//
//   // Clean up
//   ref.onDispose(() {
//     timer.cancel();
//     controller.close();
//   });
//
//   return controller.stream;
// });

class VisitorAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get basic visitor statistics
  Future<Map<String, dynamic>> getVisitorStats() async {
    try {
      // Get current date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Query for today's visitors
      final todaySnapshot = await _firestore
          .collection('visitors')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
          .get();

      // Query for yesterday's visitors
      final yesterdaySnapshot = await _firestore
          .collection('visitors')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(yesterday))
          .where('timestamp', isLessThan: Timestamp.fromDate(today))
          .get();

      // Query for monthly visitors
      final monthlySnapshot = await _firestore
          .collection('visitors')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      // Query for total visitors
      final totalSnapshot = await _firestore.collection('visitors').get();

      // Get unique visitors (count distinct IPs)
      final uniqueIPs = <String>{};
      for (final doc in totalSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('ipAddress')) {
          uniqueIPs.add(data['ipAddress'] as String);
        }
      }

      // Calculate bounce rate (single page view sessions / total sessions)
      final sessionSnapshot = await _firestore.collection('sessions').get();

      int singlePageSessions = 0;
      for (final doc in sessionSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('pageViewCount') && data['pageViewCount'] == 1) {
          singlePageSessions++;
        }
      }

      final bounceRate = sessionSnapshot.docs.isEmpty
          ? 0.0
          : (singlePageSessions / sessionSnapshot.docs.length * 100);

      // Get most visited page
      final pageViewsSnapshot = await _firestore.collection('pageViews').get();

      final pageCounts = <String, int>{};
      for (final doc in pageViewsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('path')) {
          final path = data['path'] as String;
          pageCounts[path] = (pageCounts[path] ?? 0) + 1;
        }
      }

      String mostVisitedPage = 'الرئيسية';
      int mostVisitedPageCount = 0;

      pageCounts.forEach((path, count) {
        if (count > mostVisitedPageCount) {
          mostVisitedPage = path;
          mostVisitedPageCount = count;
        }
      });

      // Calculate average session duration
      int totalSessionDuration = 0;
      for (final doc in sessionSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('duration')) {
          totalSessionDuration += data['duration'] as int;
        }
      }

      final avgSessionDuration = sessionSnapshot.docs.isEmpty
          ? 0
          : totalSessionDuration ~/ sessionSnapshot.docs.length;

      // Format avg session duration as MM:SS
      final minutes = avgSessionDuration ~/ 60;
      final seconds = avgSessionDuration % 60;
      final avgSessionDurationFormatted =
          '$minutes:${seconds.toString().padLeft(2, '0')}';

      // Calculate percent change from yesterday
      final todayCount = todaySnapshot.docs.length;
      final yesterdayCount = yesterdaySnapshot.docs.length;

      double percentChange = 0;
      if (yesterdayCount > 0) {
        percentChange = ((todayCount - yesterdayCount) / yesterdayCount) * 100;
      }

      return {
        'todayVisitors': todayCount,
        'yesterdayVisitors': yesterdayCount,
        'monthlyVisitors': monthlySnapshot.docs.length,
        'totalVisitors': totalSnapshot.docs.length,
        'uniqueVisitors': uniqueIPs.length,
        'percentChange': percentChange,
        'bounceRate': bounceRate.toStringAsFixed(1),
        'mostVisitedPage': mostVisitedPage,
        'mostVisitedPageCount': mostVisitedPageCount,
        'avgSessionDuration': avgSessionDurationFormatted,
      };
    } catch (e) {
      debugPrint('Error getting visitor stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // Get visitor chart data for the last 7 days
  Future<List<Map<String, dynamic>>> getVisitorChartData() async {
    try {
      final now = DateTime.now();
      final result = <Map<String, dynamic>>[];

      // Get data for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        final nextDate = DateTime(now.year, now.month, now.day - i + 1);

        // Query for visitors on this day
        final snapshot = await _firestore
            .collection('visitors')
            .where('timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(date))
            .where('timestamp', isLessThan: Timestamp.fromDate(nextDate))
            .get();

        // Format the day name in Arabic
        final formatter = DateFormat('EEE', 'ar');
        final dayName = formatter.format(date);

        result.add({
          'day': dayName,
          'date': date,
          'visits': snapshot.docs.length,
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting visitor chart data: $e');
      return [];
    }
  }

  // Get visitor location data
  Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
    try {
      // Get all visitors
      final snapshot = await _firestore
          .collection('visitors')
          .orderBy('timestamp', descending: true)
          .limit(100) // Limit to latest 100 visitors
          .get();

      final result = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Add visitor data to result
        result.add({
          'id': doc.id,
          'timestamp': data['timestamp'],
          'ipAddress': data['ipAddress'] ?? 'غير معروف',
          'country': data['country'] ?? 'غير معروف',
          'city': data['city'] ?? 'غير معروف',
          'region': data['region'] ?? 'غير معروف',
          'latitude': data['latitude'] ?? 0,
          'longitude': data['longitude'] ?? 0,
          'userAgent': data['userAgent'] ?? 'غير معروف',
          'referrer': data['referrer'] ?? '',
          'language': data['language'] ?? 'غير معروف',
          'browser': data['browser'] ?? 'غير معروف',
          'os': data['os'] ?? 'غير معروف',
          'device': data['device'] ?? 'غير معروف',
          'screenResolution': data['screenResolution'] ?? 'غير معروف',
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting visitor location data: $e');
      return [];
    }
  }
  // Get basic visitor statistics
  // Future<Map<String, dynamic>> getVisitorStats() async {
  //   try {
  //     // Get current date
  //     final now = DateTime.now();
  //     final today = DateTime(now.year, now.month, now.day);
  //     final yesterday = today.subtract(const Duration(days: 1));
  //     final startOfMonth = DateTime(now.year, now.month, 1);
  //
  //     // Query for today's visitors
  //     final todaySnapshot = await _firestore
  //         .collection('visitors')
  //         .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
  //         .get();
  //
  //     // Query for yesterday's visitors
  //     final yesterdaySnapshot = await _firestore
  //         .collection('visitors')
  //         .where('timestamp',
  //         isGreaterThanOrEqualTo: Timestamp.fromDate(yesterday))
  //         .where('timestamp', isLessThan: Timestamp.fromDate(today))
  //         .get();
  //
  //     // Query for monthly visitors
  //     final monthlySnapshot = await _firestore
  //         .collection('visitors')
  //         .where('timestamp',
  //         isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
  //         .get();
  //
  //     // Query for total visitors
  //     final totalSnapshot = await _firestore.collection('visitors').get();
  //
  //     // Get unique visitors (count distinct IPs)
  //     final uniqueIPs = <String>{};
  //     for (final doc in totalSnapshot.docs) {
  //       final data = doc.data();
  //       if (data.containsKey('ipAddress')) {
  //         uniqueIPs.add(data['ipAddress'] as String);
  //       }
  //     }
  //
  //     // Calculate bounce rate (single page view sessions / total sessions)
  //     final sessionSnapshot = await _firestore.collection('sessions').get();
  //
  //     int singlePageSessions = 0;
  //     for (final doc in sessionSnapshot.docs) {
  //       final data = doc.data();
  //       if (data.containsKey('pageViewCount') && data['pageViewCount'] == 1) {
  //         singlePageSessions++;
  //       }
  //     }
  //
  //     final bounceRate = sessionSnapshot.docs.isEmpty
  //         ? 0.0
  //         : (singlePageSessions / sessionSnapshot.docs.length * 100);
  //
  //     // Get most visited page
  //     final pageViewsSnapshot = await _firestore.collection('pageViews').get();
  //
  //     final pageCounts = <String, int>{};
  //     for (final doc in pageViewsSnapshot.docs) {
  //       final data = doc.data();
  //       if (data.containsKey('path')) {
  //         final path = data['path'] as String;
  //         pageCounts[path] = (pageCounts[path] ?? 0) + 1;
  //       }
  //     }
  //
  //     String mostVisitedPage = 'الرئيسية';
  //     int mostVisitedPageCount = 0;
  //
  //     pageCounts.forEach((path, count) {
  //       if (count > mostVisitedPageCount) {
  //         mostVisitedPage = path;
  //         mostVisitedPageCount = count;
  //       }
  //     });
  //
  //     // Calculate average session duration
  //     int totalSessionDuration = 0;
  //     for (final doc in sessionSnapshot.docs) {
  //       final data = doc.data();
  //       if (data.containsKey('duration')) {
  //         totalSessionDuration += data['duration'] as int;
  //       }
  //     }
  //
  //     final avgSessionDuration = sessionSnapshot.docs.isEmpty
  //         ? 0
  //         : totalSessionDuration ~/ sessionSnapshot.docs.length;
  //
  //     // Format avg session duration as MM:SS
  //     final minutes = avgSessionDuration ~/ 60;
  //     final seconds = avgSessionDuration % 60;
  //     final avgSessionDurationFormatted =
  //         '$minutes:${seconds.toString().padLeft(2, '0')}';
  //
  //     // Calculate percent change from yesterday
  //     final todayCount = todaySnapshot.docs.length;
  //     final yesterdayCount = yesterdaySnapshot.docs.length;
  //
  //     double percentChange = 0;
  //     if (yesterdayCount > 0) {
  //       percentChange = ((todayCount - yesterdayCount) / yesterdayCount) * 100;
  //     }
  //
  //     return {
  //       'todayVisitors': todayCount,
  //       'yesterdayVisitors': yesterdayCount,
  //       'monthlyVisitors': monthlySnapshot.docs.length,
  //       'totalVisitors': totalSnapshot.docs.length,
  //       'uniqueVisitors': uniqueIPs.length,
  //       'percentChange': percentChange,
  //       'bounceRate': bounceRate.toStringAsFixed(1),
  //       'mostVisitedPage': mostVisitedPage,
  //       'mostVisitedPageCount': mostVisitedPageCount,
  //       'avgSessionDuration': avgSessionDurationFormatted,
  //     };
  //   } catch (e) {
  //     debugPrint('Error getting visitor stats: $e');
  //     return {
  //       'error': e.toString(),
  //     };
  //   }
  // }

  // Get visitor behavior data
  Future<Map<String, dynamic>> getVisitorBehaviorData() async {
    try {
      // Get all page views
      final pageViewsSnapshot = await _firestore.collection('pageViews').get();

      // Calculate page popularity
      final pageCounts = <String, int>{};
      final pageTimeSpent = <String, int>{};

      for (final doc in pageViewsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('path')) {
          final path = data['path'] as String;
          pageCounts[path] = (pageCounts[path] ?? 0) + 1;

          if (data.containsKey('timeOnPage')) {
            final timeOnPage = data['timeOnPage'] as int;
            pageTimeSpent[path] = (pageTimeSpent[path] ?? 0) + timeOnPage;
          }
        }
      }

      // Calculate average time on each page
      final pageAvgTimeSpent = <String, double>{};
      pageTimeSpent.forEach((path, totalTime) {
        final count = pageCounts[path] ?? 1;
        pageAvgTimeSpent[path] = totalTime / count;
      });

      // Get entry and exit pages
      final sessionSnapshot = await _firestore.collection('sessions').get();

      final entryPages = <String, int>{};
      final exitPages = <String, int>{};

      for (final doc in sessionSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('entryPage')) {
          final entryPage = data['entryPage'] as String;
          entryPages[entryPage] = (entryPages[entryPage] ?? 0) + 1;
        }

        if (data.containsKey('exitPage')) {
          final exitPage = data['exitPage'] as String;
          exitPages[exitPage] = (exitPages[exitPage] ?? 0) + 1;
        }
      }

      // Construct popular pages data
      final popularPages = <Map<String, dynamic>>[];
      pageCounts.forEach((path, count) {
        popularPages.add({
          'path': path,
          'views': count,
          'avgTimeSpent': pageAvgTimeSpent[path] ?? 0,
          'entryCount': entryPages[path] ?? 0,
          'exitCount': exitPages[path] ?? 0,
        });
      });

      // Sort by views descending
      popularPages.sort((a, b) => b['views'].compareTo(a['views']));

      // Get referrer sources
      final referrers = <String, int>{};
      for (final doc in pageViewsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('referrer') &&
            data['referrer'] != null &&
            data['referrer'] != '') {
          String referrer = data['referrer'] as String;

          // Simplify referrer URL
          try {
            final uri = Uri.parse(referrer);
            referrer = uri.host;
          } catch (e) {
            // Use the original referrer if parsing fails
          }

          referrers[referrer] = (referrers[referrer] ?? 0) + 1;
        }
      }

      // Construct referrer sources data
      final referrerSources = <Map<String, dynamic>>[];
      referrers.forEach((source, count) {
        referrerSources.add({
          'source': source,
          'count': count,
        });
      });

      // Sort by count descending
      referrerSources.sort((a, b) => b['count'].compareTo(a['count']));

      return {
        'popularPages': popularPages,
        'referrerSources': referrerSources,
      };
    } catch (e) {
      debugPrint('Error getting visitor behavior data: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // Get visitor demographic data
  Future<Map<String, dynamic>> getVisitorDemographicData() async {
    try {
      final snapshot = await _firestore.collection('visitors').get();

      // Calculate country distribution
      final countries = <String, int>{};
      // Calculate browser distribution
      final browsers = <String, int>{};
      // Calculate device distribution
      final devices = <String, int>{};
      // Calculate OS distribution
      final osystems = <String, int>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (data.containsKey('country')) {
          final country = data['country'] as String? ?? 'غير معروف';
          countries[country] = (countries[country] ?? 0) + 1;
        }

        if (data.containsKey('browser')) {
          final browser = data['browser'] as String? ?? 'غير معروف';
          browsers[browser] = (browsers[browser] ?? 0) + 1;
        }

        if (data.containsKey('device')) {
          final device = data['device'] as String? ?? 'غير معروف';
          devices[device] = (devices[device] ?? 0) + 1;
        }

        if (data.containsKey('os')) {
          final os = data['os'] as String? ?? 'غير معروف';
          osystems[os] = (osystems[os] ?? 0) + 1;
        }
      }

      // Construct country data
      final countryData = <Map<String, dynamic>>[];
      countries.forEach((country, count) {
        countryData.add({
          'country': country,
          'count': count,
        });
      });

      // Sort by count descending
      countryData.sort((a, b) => b['count'].compareTo(a['count']));

      // Construct browser data
      final browserData = <Map<String, dynamic>>[];
      browsers.forEach((browser, count) {
        browserData.add({
          'browser': browser,
          'count': count,
        });
      });

      // Sort by count descending
      browserData.sort((a, b) => b['count'].compareTo(a['count']));

      // Construct device data
      final deviceData = <Map<String, dynamic>>[];
      devices.forEach((device, count) {
        deviceData.add({
          'device': device,
          'count': count,
        });
      });

      // Sort by count descending
      deviceData.sort((a, b) => b['count'].compareTo(a['count']));

      // Construct OS data
      final osData = <Map<String, dynamic>>[];
      osystems.forEach((os, count) {
        osData.add({
          'os': os,
          'count': count,
        });
      });

      // Sort by count descending
      osData.sort((a, b) => b['count'].compareTo(a['count']));

      return {
        'countries': countryData,
        'browsers': browserData,
        'devices': deviceData,
        'operatingSystems': osData,
      };
    } catch (e) {
      debugPrint('Error getting visitor demographic data: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // Get visitor session data
  Future<List<Map<String, dynamic>>> getVisitorSessionData(
      String visitorId) async {
    try {
      final snapshot = await _firestore
          .collection('visitors')
          .doc(visitorId)
          .collection('sessions')
          .orderBy('startTime', descending: true)
          .get();

      final result = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        result.add({
          'id': doc.id,
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'duration': data['duration'] ?? 0,
          'pageViewCount': data['pageViewCount'] ?? 0,
          'entryPage': data['entryPage'] ?? '',
          'exitPage': data['exitPage'] ?? '',
          'referrer': data['referrer'] ?? '',
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting visitor session data: $e');
      return [];
    }
  }

  // Get visitor page view data
  Future<List<Map<String, dynamic>>> getVisitorPageViewData(
      String visitorId) async {
    try {
      final snapshot = await _firestore
          .collection('visitors')
          .doc(visitorId)
          .collection('pageViews')
          .orderBy('timestamp', descending: true)
          .get();

      final result = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        result.add({
          'id': doc.id,
          'timestamp': data['timestamp'],
          'path': data['path'] ?? '',
          'title': data['title'] ?? '',
          'referrer': data['referrer'] ?? '',
          'timeOnPage': data['timeOnPage'] ?? 0,
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting visitor page view data: $e');
      return [];
    }
  }

  // Export data to CSV format
  Future<String> exportVisitorDataToCsv() async {
    try {
      final snapshot = await _firestore
          .collection('visitors')
          .orderBy('timestamp', descending: true)
          .get();

      // Create CSV header
      StringBuffer csv = StringBuffer();
      csv.writeln(
          'IP,Country,City,Region,Timestamp,UserAgent,Referrer,Browser,OS,Device');

      // Add each visitor as a row
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ip = data['ipAddress'] ?? '';
        final country = data['country'] ?? '';
        final city = data['city'] ?? '';
        final region = data['region'] ?? '';
        final timestamp = data['timestamp'] != null
            ? (data['timestamp'] as Timestamp).toDate().toIso8601String()
            : '';
        final userAgent = data['userAgent'] ?? '';
        final referrer = data['referrer'] ?? '';
        final browser = data['browser'] ?? '';
        final os = data['os'] ?? '';
        final device = data['device'] ?? '';

        // Escape commas in fields
        final escapedRow = [
          ip,
          _escapeCsvField(country),
          _escapeCsvField(city),
          _escapeCsvField(region),
          timestamp,
          _escapeCsvField(userAgent),
          _escapeCsvField(referrer),
          _escapeCsvField(browser),
          _escapeCsvField(os),
          _escapeCsvField(device),
        ].join(',');

        csv.writeln(escapedRow);
      }

      return csv.toString();
    } catch (e) {
      debugPrint('Error exporting visitor data: $e');
      return 'Error: $e';
    }
  }

  // Helper method to escape CSV fields
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
