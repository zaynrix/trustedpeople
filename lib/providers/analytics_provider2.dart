import 'dart:convert';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin_dashboard.dart';

/// Provider for visitor analytics service
final visitorAnalyticsProvider = Provider<VisitorAnalyticsService>((ref) {
  return VisitorAnalyticsService();
});
// final visitorStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
//   final service = ref.watch(visitorAnalyticsProvider);
//   return service.getVisitorStats();
// });

final analyticsChartDataProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getVisitorChartData();
});
// Fixed analytics_provider.dart

/// Provider for visitor analytics service

/// Service for tracking visitor analytics for ALL website visitors
class VisitorAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _visitorId;
  String? _sessionId;
  final Map<String, dynamic> _visitorData = {};
  bool _initialized = false;

  // Constructor
  VisitorAnalyticsService() {
    // Initialize date formatting for Arabic locale
    initializeDateFormatting('ar', null).then((_) {
      _initialized = true;
      debugPrint('Date formatting initialized for Arabic locale');
    });
  }

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
  //             isGreaterThanOrEqualTo: Timestamp.fromDate(yesterday))
  //         .where('timestamp', isLessThan: Timestamp.fromDate(today))
  //         .get();
  //
  //     // Query for monthly visitors
  //     final monthlySnapshot = await _firestore
  //         .collection('visitors')
  //         .where('timestamp',
  //             isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
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

  /// Records a unique visitor - call this when the app starts
  Future<bool> recordUniqueVisit() async {
    try {
      // Ensure date formatting is initialized
      if (!_initialized) {
        await initializeDateFormatting('ar', null);
        _initialized = true;
      }

      // Get visitor ID
      final visitorId = await _getVisitorId();

      // Get visitor data
      await _collectVisitorData();

      // Check if we already recorded a visit today
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final lastVisitDate = prefs.getString('last_visit_date');

      // Debug
      debugPrint('Last visit date: $lastVisitDate, Today: $today');

      // Only record once per day
      final isNewVisit = lastVisitDate != today;
      if (isNewVisit) {
        // Save today as last visit date
        await prefs.setString('last_visit_date', today);

        // Update visitor record in Firestore
        await _firestore.collection('visitors').doc(visitorId).set({
          'ipAddress': _visitorData['ipAddress'],
          'userAgent': _visitorData['userAgent'],
          'language': _visitorData['language'],
          'timestamp': FieldValue.serverTimestamp(),
          'lastVisit': FieldValue.serverTimestamp(),
          'firstVisit':
              _visitorData['firstVisit'] ?? FieldValue.serverTimestamp(),
          'country': _visitorData['country'],
          'city': _visitorData['city'],
          'region': _visitorData['region'],
          'latitude': _visitorData['latitude'],
          'longitude': _visitorData['longitude'],
          'browser': _visitorData['browser'],
          'os': _visitorData['os'],
          'device': _visitorData['device'],
          'screenResolution': _visitorData['screenResolution'],
          'referrer': _visitorData['referrer'],
        }, SetOptions(merge: true));

        // Add to daily visits collection
        await _firestore.collection('visits').add({
          'visitorId': visitorId,
          'timestamp': FieldValue.serverTimestamp(),
          'ipAddress': _visitorData['ipAddress'],
          'country': _visitorData['country'],
          'city': _visitorData['city'],
          'date': today,
        });

        // Debug
        debugPrint('New visit recorded for visitor: $visitorId');
      } else {
        // Just update last visit timestamp
        await _firestore.collection('visitors').doc(visitorId).update({
          'lastVisit': FieldValue.serverTimestamp(),
        });

        debugPrint('Updated last visit time for visitor: $visitorId');
      }

      // Start a new session
      await _startSession();

      return true;
    } catch (e) {
      debugPrint('Error recording unique visit: $e');
      return false;
    }
  }

  /// Records a page view - call this when the route changes
  Future<void> recordPageView(String path, String title) async {
    try {
      // Get visitor and session IDs
      final visitorId = await _getVisitorId();

      // Make sure we have a session
      if (_sessionId == null) {
        await _startSession();
      }

      // Debug
      debugPrint('Recording page view: $path, title: $title');

      // Record page view
      await _firestore
          .collection('visitors')
          .doc(visitorId)
          .collection('pageViews')
          .add({
        'path': path,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': _sessionId,
      });

      // Also add to general pageViews collection
      await _firestore.collection('pageViews').add({
        'visitorId': visitorId,
        'path': path,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': _sessionId,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      // Update session page count
      if (_sessionId != null) {
        await _firestore
            .collection('visitors')
            .doc(visitorId)
            .collection('sessions')
            .doc(_sessionId)
            .update({
          'pageViewCount': FieldValue.increment(1),
        });
      }

      debugPrint('Page view recorded successfully');
    } catch (e) {
      debugPrint('Error recording page view: $e');
    }
  }

  /// Get visitor statistics - used by the admin dashboard
  Future<Map<String, dynamic>> getVisitorStats() async {
    try {
      // Ensure date formatting is initialized
      if (!_initialized) {
        await initializeDateFormatting('ar', null);
        _initialized = true;
      }

      // Get current date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Format dates for Firestore queries
      final todayStr = DateFormat('yyyy-MM-dd').format(today);
      final yesterdayStr = DateFormat('yyyy-MM-dd').format(yesterday);

      // Query for today's visitors (using visits collection with date field)
      final todayVisits = await _firestore
          .collection('visits')
          .where('date', isEqualTo: todayStr)
          .get();

      // Query for yesterday's visitors
      final yesterdayVisits = await _firestore
          .collection('visits')
          .where('date', isEqualTo: yesterdayStr)
          .get();

      // Get monthly visitors
      final monthlyVisits = await _firestore
          .collection('visitors')
          .where('lastVisit',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      // Get total visitors
      final totalVisitors = await _firestore.collection('visitors').get();

      // Calculate unique visitors (count distinct IPs)
      final uniqueIPs = <String>{};
      for (final doc in totalVisitors.docs) {
        final data = doc.data();
        if (data.containsKey('ipAddress')) {
          uniqueIPs.add(data['ipAddress'] as String);
        }
      }

      // Get page views to calculate bounce rate and most visited page
      final pageViewsSnapshot = await _firestore.collection('pageViews').get();

      // Count pageviews per path
      final pageCounts = <String, int>{};
      for (final doc in pageViewsSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('path')) {
          final path = data['path'] as String;
          pageCounts[path] = (pageCounts[path] ?? 0) + 1;
        }
      }

      // Find most visited page
      String mostVisitedPage = 'الرئيسية';
      int mostVisitedPageCount = 0;
      pageCounts.forEach((path, count) {
        if (count > mostVisitedPageCount) {
          mostVisitedPage = path;
          mostVisitedPageCount = count;
        }
      });

      // Calculate percent change from yesterday
      final todayCount = todayVisits.docs.length;
      final yesterdayCount = yesterdayVisits.docs.length;

      double percentChange = 0;
      if (yesterdayCount > 0) {
        percentChange = ((todayCount - yesterdayCount) / yesterdayCount) * 100;
      }

      // Get average session duration from sessions
      final sessionSnapshot = await _firestore.collection('sessions').get();

      int totalSessionDuration = 0;
      for (final doc in sessionSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('duration')) {
          totalSessionDuration += (data['duration'] as num).toInt();
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

      return {
        'todayVisitors': todayCount,
        'yesterdayVisitors': yesterdayCount,
        'monthlyVisitors': monthlyVisits.docs.length,
        'totalVisitors': totalVisitors.docs.length,
        'uniqueVisitors': uniqueIPs.length,
        'percentChange': percentChange,
        'bounceRate':
            '0.0', // Calculate this if you have session data with page count
        'mostVisitedPage': mostVisitedPage,
        'mostVisitedPageCount': mostVisitedPageCount,
        'avgSessionDuration': avgSessionDurationFormatted,
      };
    } catch (e) {
      debugPrint('Error getting visitor stats: $e');
      return {
        'error': e.toString(),
        'todayVisitors': 0,
        'yesterdayVisitors': 0,
        'monthlyVisitors': 0,
        'totalVisitors': 0,
        'uniqueVisitors': 0,
        'percentChange': 0.0,
        'bounceRate': '0.0',
        'mostVisitedPage': 'الرئيسية',
        'mostVisitedPageCount': 0,
        'avgSessionDuration': '0:00',
      };
    }
  }

  /// Get visitor chart data for the last 7 days
  Future<List<Map<String, dynamic>>> getVisitorChartData() async {
    try {
      // Ensure date formatting is initialized
      if (!_initialized) {
        await initializeDateFormatting('ar', null);
        _initialized = true;
      }

      final now = DateTime.now();
      final result = <Map<String, dynamic>>[];

      // Get data for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);

        // Format the date for Firestore query
        final dateStr = DateFormat('yyyy-MM-dd').format(date);

        // Query for visitors on this day
        final snapshot = await _firestore
            .collection('visits')
            .where('date', isEqualTo: dateStr)
            .get();

        // Format the day name in Arabic
        final dayName = DateFormat('EEE', 'ar').format(date);

        result.add({
          'day': dayName,
          'date': date,
          'visits': snapshot.docs.length,
        });
      }

      return result;
    } catch (e) {
      debugPrint('Error getting visitor chart data: $e');
      // Return empty data with the right structure
      final now = DateTime.now();
      final result = <Map<String, dynamic>>[];

      for (int i = 6; i >= 0; i--) {
        final date = DateTime(now.year, now.month, now.day - i);
        result.add({
          'day': i.toString(),
          'date': date,
          'visits': 0,
        });
      }

      return result;
    }
  }

  /// Get visitor location data
  Future<List<Map<String, dynamic>>> getVisitorLocationData() async {
    try {
      // Get all visitors (or limit to most recent)
      final snapshot = await _firestore
          .collection('visitors')
          .orderBy('lastVisit', descending: true)
          .limit(100) // Limit to latest 100 visitors
          .get();

      final result = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Add visitor data to result
        result.add({
          'id': doc.id,
          'timestamp': data['lastVisit'] ?? data['timestamp'],
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

  /// Get or create visitor ID
  Future<String> _getVisitorId() async {
    if (_visitorId != null) {
      return _visitorId!;
    }

    try {
      // Try to get from local storage
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString('visitor_id');

      if (storedId != null && storedId.isNotEmpty) {
        _visitorId = storedId;
        debugPrint('Retrieved existing visitor ID: $storedId');
        return storedId;
      }

      // Create new ID
      final newId = _firestore.collection('visitors').doc().id;
      await prefs.setString('visitor_id', newId);
      _visitorId = newId;
      debugPrint('Created new visitor ID: $newId');
      return newId;
    } catch (e) {
      debugPrint('Error getting visitor ID: $e');
      final fallbackId = 'visitor-${DateTime.now().millisecondsSinceEpoch}';
      _visitorId = fallbackId;
      return fallbackId;
    }
  }

  /// Collect visitor information
  Future<void> _collectVisitorData() async {
    try {
      // Check if we already have data
      if (_visitorData.isNotEmpty) {
        return;
      }

      // Get IP info
      final ipData = await _getIpInfo();

      // Get browser info
      final userAgent = html.window.navigator.userAgent;
      final screenWidth = html.window.screen?.width ?? 0;
      final screenHeight = html.window.screen?.height ?? 0;
      final language = html.window.navigator.language;
      final referrer = html.document.referrer;

      // Detect browser
      String browser = 'Unknown';
      if (userAgent.contains('Firefox')) {
        browser = 'Firefox';
      } else if (userAgent.contains('Edge')) {
        browser = 'Edge';
      } else if (userAgent.contains('Chrome')) {
        browser = 'Chrome';
      } else if (userAgent.contains('Safari')) {
        browser = 'Safari';
      } else if (userAgent.contains('Opera')) {
        browser = 'Opera';
      }

      // Detect OS
      String os = 'Unknown';
      if (userAgent.contains('Windows')) {
        os = 'Windows';
      } else if (userAgent.contains('Mac OS')) {
        os = 'macOS';
      } else if (userAgent.contains('Android')) {
        os = 'Android';
      } else if (userAgent.contains('iOS') ||
          userAgent.contains('iPhone') ||
          userAgent.contains('iPad')) {
        os = 'iOS';
      } else if (userAgent.contains('Linux')) {
        os = 'Linux';
      }

      // Detect device
      String device = 'Desktop';
      if (userAgent.contains('Mobile')) {
        device = 'Mobile';
      } else if (userAgent.contains('Tablet') || userAgent.contains('iPad')) {
        device = 'Tablet';
      }

      // Store data
      _visitorData.addAll({
        'ipAddress': ipData['ip'] ?? 'Unknown',
        'country': ipData['country'] ?? 'Unknown',
        'city': ipData['city'] ?? 'Unknown',
        'region': ipData['region'] ?? 'Unknown',
        'latitude': ipData['latitude'] ?? 0,
        'longitude': ipData['longitude'] ?? 0,
        'userAgent': userAgent,
        'screenResolution': '${screenWidth}x${screenHeight}',
        'language': language,
        'referrer': referrer,
        'browser': browser,
        'os': os,
        'device': device,
        'firstVisit': FieldValue.serverTimestamp(),
      });

      debugPrint(
          'Collected visitor data: ${_visitorData['country']}, ${_visitorData['city']}, ${_visitorData['browser']}');
    } catch (e) {
      debugPrint('Error collecting visitor data: $e');
    }
  }

  /// Get IP and location info
  Future<Map<String, dynamic>> _getIpInfo() async {
    try {
      // Get IP
      final ipResponse =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      final ipJson = json.decode(ipResponse.body);
      final ip = ipJson['ip'] as String;

      debugPrint('Got IP address: $ip');

      // Get location from IP
      final locationResponse =
          await http.get(Uri.parse('https://ipapi.co/$ip/json'));

      if (locationResponse.statusCode == 200) {
        final locationData = json.decode(locationResponse.body);
        debugPrint(
            'Got location data: ${locationData['country_name']}, ${locationData['city']}');

        return {
          'ip': ip,
          'country': locationData['country_name'] ?? 'Unknown',
          'city': locationData['city'] ?? 'Unknown',
          'region': locationData['region'] ?? 'Unknown',
          'latitude': locationData['latitude'] ?? 0,
          'longitude': locationData['longitude'] ?? 0,
        };
      }

      // Return basic data if location lookup fails
      return {'ip': ip};
    } catch (e) {
      debugPrint('Error getting IP info: $e');
      return {
        'ip': 'Unknown',
        'country': 'Unknown',
        'city': 'Unknown',
        'region': 'Unknown',
      };
    }
  }

  /// Start a new session
  Future<void> _startSession() async {
    try {
      final visitorId = await _getVisitorId();

      // Check if we already have a session
      if (_sessionId != null) {
        // Session already exists
        return;
      }

      // Create session
      final sessionRef = _firestore
          .collection('visitors')
          .doc(visitorId)
          .collection('sessions')
          .doc();

      _sessionId = sessionRef.id;

      // Record session start
      await sessionRef.set({
        'startTime': FieldValue.serverTimestamp(),
        'pageViewCount': 0,
        'referrer': _visitorData['referrer'] ?? '',
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      // Save session start time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_session_id', _sessionId!);
      await prefs.setInt(
          'session_start_time', DateTime.now().millisecondsSinceEpoch);

      // Set up session end handler for when the user leaves the site
      html.window.onBeforeUnload.listen((event) async {
        await _endSession();
      });

      debugPrint('Started new session: $_sessionId');
    } catch (e) {
      debugPrint('Error starting session: $e');
    }
  }

  /// End the current session
  Future<void> _endSession() async {
    try {
      if (_sessionId == null || _visitorId == null) return;

      // Calculate duration
      final prefs = await SharedPreferences.getInstance();
      final startTime = prefs.getInt('session_start_time') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final duration = (now - startTime) ~/ 1000; // Convert to seconds

      // Update session
      await _firestore
          .collection('visitors')
          .doc(_visitorId)
          .collection('sessions')
          .doc(_sessionId)
          .update({
        'endTime': FieldValue.serverTimestamp(),
        'duration': duration,
      });

      // Clear session data
      await prefs.remove('current_session_id');
      await prefs.remove('session_start_time');
      _sessionId = null;

      debugPrint('Ended session with duration: $duration seconds');
    } catch (e) {
      debugPrint('Error ending session: $e');
    }
  }
}
