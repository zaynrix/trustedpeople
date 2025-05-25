// lib/fetures/services/visitor_analytics_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

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
