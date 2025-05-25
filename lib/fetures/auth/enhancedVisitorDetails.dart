import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/fetures/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Provider for detailed user information
final visitorDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, visitorId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .get();

    if (!doc.exists) {
      return {'error': 'Visitor not found'};
    }

    // Get visitor data
    final data = doc.data() as Map<String, dynamic>;

    // Get the sessions collection for this visitor
    final sessions = await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .collection('sessions')
        .orderBy('startTime', descending: true)
        .get();

    // Add sessions to visitor data
    data['sessions'] = sessions.docs.map((doc) => doc.data()).toList();

    // Get page views collection for this visitor
    final pageViews = await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .collection('pageViews')
        .orderBy('timestamp', descending: true)
        .get();

    // Add page views to visitor data
    data['pageViews'] = pageViews.docs.map((doc) => doc.data()).toList();

    return data;
  } catch (e) {
    debugPrint('Error fetching visitor details: $e');
    return {'error': e.toString()};
  }
});

class EnhancedVisitorDetails extends ConsumerWidget {
  final String visitorId;
  final String visitorIp;

  const EnhancedVisitorDetails({
    Key? key,
    required this.visitorId,
    required this.visitorIp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorDetails = ref.watch(visitorDetailProvider(visitorId));
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('معلومات الزائر', style: GoogleFonts.cairo()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(visitorDetailProvider(visitorId)),
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: visitorDetails.when(
        data: (data) {
          if (data.containsKey('error')) {
            return Center(
              child: Text(
                'حدث خطأ: ${data['error']}',
                style: GoogleFonts.cairo(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          return _buildVisitorDetailsContent(context, data, isSmallScreen, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'حدث خطأ: $error',
            style: GoogleFonts.cairo(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBlockDialog(context, visitorIp, ref),
        backgroundColor: Colors.red,
        child: const Icon(Icons.block),
        tooltip: 'حظر المستخدم',
      ),
    );
  }

  Widget _buildVisitorDetailsContent(
    BuildContext context,
    Map<String, dynamic> data,
    bool isSmallScreen,
    WidgetRef ref,
  ) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(visitorDetailProvider(visitorId)),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(data, isSmallScreen, context),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            _buildDeviceInfoCard(data, isSmallScreen, context),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            _buildLocationInfoCard(data, isSmallScreen, context),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            _buildSessionsCard(data, isSmallScreen, context),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            _buildPageViewsCard(data, isSmallScreen, context),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            _buildRawDataCard(data, isSmallScreen, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      Map<String, dynamic> data, bool isSmallScreen, context) {
    final firstVisit = data['firstVisit'] != null
        ? (data['firstVisit'] as Timestamp).toDate()
        : DateTime.now();
    final lastVisit = data['lastVisit'] != null
        ? (data['lastVisit'] as Timestamp).toDate()
        : DateTime.now();

    final sessionCount = (data['sessions'] as List?)?.length ?? 0;
    final pageViewCount = (data['pageViews'] as List?)?.length ?? 0;

    // Calculate total time on site
    Duration totalTime = Duration.zero;
    if (data['sessions'] != null) {
      for (final session in data['sessions'] as List) {
        if (session['duration'] != null) {
          totalTime += Duration(seconds: session['duration']);
        }
      }
    }

    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person,
                    color: Colors.blue.shade700, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'ملخص الزائر',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Grid of summary stats
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isSmallScreen ? 2 : 3,
              childAspectRatio: isSmallScreen ? 1.8 : 2.0,
              crossAxisSpacing: isSmallScreen ? 8 : 12,
              mainAxisSpacing: isSmallScreen ? 8 : 12,
              children: [
                _buildSummaryItem(
                  'أول زيارة',
                  formatter.format(firstVisit),
                  Icons.calendar_today,
                  Colors.green,
                  isSmallScreen,
                ),
                _buildSummaryItem(
                  'آخر زيارة',
                  formatter.format(lastVisit),
                  Icons.calendar_month,
                  Colors.orange,
                  isSmallScreen,
                ),
                _buildSummaryItem(
                  'عدد الجلسات',
                  sessionCount.toString(),
                  Icons.login,
                  Colors.purple,
                  isSmallScreen,
                ),
                _buildSummaryItem(
                  'عدد الصفحات',
                  pageViewCount.toString(),
                  Icons.pageview,
                  Colors.blue,
                  isSmallScreen,
                ),
                _buildSummaryItem(
                  'إجمالي الوقت',
                  '${totalTime.inMinutes}:${(totalTime.inSeconds % 60).toString().padLeft(2, '0')}',
                  Icons.timer,
                  Colors.teal,
                  isSmallScreen,
                ),
                _buildSummaryItem(
                  'متوسط الجلسة',
                  sessionCount > 0
                      ? '${(totalTime.inSeconds / sessionCount ~/ 60)}:${((totalTime.inSeconds / sessionCount) % 60).toInt().toString().padLeft(2, '0')}'
                      : '0:00',
                  Icons.hourglass_bottom,
                  Colors.amber,
                  isSmallScreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isSmallScreen ? 16 : 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard(
      Map<String, dynamic> data, bool isSmallScreen, context) {
    final userAgent = data['userAgent'] ?? 'غير معروف';

    // Let's try to parse useful information from the user agent
    String browser = 'غير معروف';
    String os = 'غير معروف';
    String device = 'غير معروف';

    // Very basic parsing - in a real app you'd use a proper user agent parser
    if (userAgent.contains('Chrome')) {
      browser = 'Chrome';
    } else if (userAgent.contains('Firefox')) {
      browser = 'Firefox';
    } else if (userAgent.contains('Safari')) {
      browser = 'Safari';
    } else if (userAgent.contains('Edge')) {
      browser = 'Edge';
    }

    if (userAgent.contains('Windows')) {
      os = 'Windows';
    } else if (userAgent.contains('Mac OS')) {
      os = 'macOS';
    } else if (userAgent.contains('iPhone')) {
      os = 'iOS';
      device = 'iPhone';
    } else if (userAgent.contains('iPad')) {
      os = 'iOS';
      device = 'iPad';
    } else if (userAgent.contains('Android')) {
      os = 'Android';
      device = 'Android';
    } else if (userAgent.contains('Linux')) {
      os = 'Linux';
    }

    if (device == 'غير معروف') {
      if (userAgent.contains('Mobile')) {
        device = 'Mobile';
      } else {
        device = 'Desktop';
      }
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices,
                    color: Colors.green.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'معلومات الجهاز',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),

            _buildInfoRow('نظام التشغيل:', os, Icons.computer, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow('نوع الجهاز:', device, Icons.hardware, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow('المتصفح:', browser, Icons.public, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Collapsible User Agent section
            ExpansionTile(
              title: Text(
                'User Agent',
                style: GoogleFonts.cairo(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          userAgent,
                          style: GoogleFonts.cairo(
                              fontSize: isSmallScreen ? 12 : 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () => _copyToClipboard(userAgent, context),
                        tooltip: 'نسخ',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Additional device info if available
            if (data['screenResolution'] != null) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildInfoRow(
                'دقة الشاشة:',
                data['screenResolution'],
                Icons.aspect_ratio,
                isSmallScreen,
              ),
            ],

            if (data['language'] != null) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildInfoRow(
                'اللغة:',
                data['language'],
                Icons.language,
                isSmallScreen,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(
      Map<String, dynamic> data, bool isSmallScreen, context) {
    final country = data['country'] ?? 'غير معروف';
    final city = data['city'] ?? 'غير معروف';
    final region = data['region'] ?? 'غير معروف';
    final ip = data['ipAddress'] ?? 'غير معروف';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on,
                    color: Colors.red.shade700, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'معلومات الموقع',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow('البلد:', country, Icons.flag, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow('المدينة:', city, Icons.location_city, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow('المنطقة:', region, Icons.map, isSmallScreen),
            SizedBox(height: isSmallScreen ? 8 : 12),
            _buildInfoRow(
              'عنوان IP:',
              ip,
              Icons.router,
              isSmallScreen,
              onCopy: () => _copyToClipboard(ip, context),
              onLookup: () => _lookupIP(ip, context),
            ),
            if (data['timezone'] != null) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildInfoRow(
                'المنطقة الزمنية:',
                data['timezone'],
                Icons.access_time,
                isSmallScreen,
              ),
            ],
            if (data['isp'] != null) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildInfoRow(
                'مزود خدمة الإنترنت:',
                data['isp'],
                Icons.wifi,
                isSmallScreen,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsCard(
      Map<String, dynamic> data, bool isSmallScreen, context) {
    final sessions = data['sessions'] as List? ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history,
                    color: Colors.purple.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'جلسات المستخدم',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  'عدد الجلسات: ${sessions.length}',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (sessions.isEmpty) ...[
              SizedBox(height: isSmallScreen ? 12 : 16),
              Center(
                child: Text(
                  'لا توجد جلسات مسجلة لهذا المستخدم',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length > 5 ? 5 : sessions.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final session = sessions[index] as Map<String, dynamic>;

                  final startTime = session['startTime'] != null
                      ? (session['startTime'] as Timestamp).toDate()
                      : DateTime.now();

                  final duration = session['duration'] != null
                      ? Duration(seconds: session['duration'])
                      : Duration.zero;

                  final formatter = DateFormat('dd/MM/yyyy HH:mm');

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Icon(Icons.access_time,
                          color: Colors.purple.shade700),
                    ),
                    title: Row(
                      children: [
                        Text(
                          formatter.format(startTime),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: GoogleFonts.cairo(
                              color: Colors.purple.shade800,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (session['referrer'] != null &&
                            session['referrer'] != '') ...[
                          Row(
                            children: [
                              Icon(Icons.link,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'المرجع: ${session['referrer']}',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (session['entryPage'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.login,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'صفحة الدخول: ${session['entryPage']}',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (session['exitPage'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.logout,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'صفحة الخروج: ${session['exitPage']}',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
              if (sessions.length > 5) ...[
                SizedBox(height: isSmallScreen ? 8 : 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.expand_more),
                    label: Text(
                      'عرض المزيد',
                      style: GoogleFonts.cairo(),
                    ),
                    onPressed: () => _showAllSessionsDialog(
                        context, sessions, isSmallScreen),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPageViewsCard(
      Map<String, dynamic> data, bool isSmallScreen, context) {
    final pageViews = data['pageViews'] as List? ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pageview,
                    color: Colors.blue.shade700, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'مشاهدات الصفحات',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Spacer(),
                Text(
                  'إجمالي المشاهدات: ${pageViews.length}',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (pageViews.isEmpty) ...[
              SizedBox(height: isSmallScreen ? 12 : 16),
              Center(
                child: Text(
                  'لا توجد مشاهدات صفحات مسجلة لهذا المستخدم',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pageViews.length > 5 ? 5 : pageViews.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final pageView = pageViews[index] as Map<String, dynamic>;

                  final timestamp = pageView['timestamp'] != null
                      ? (pageView['timestamp'] as Timestamp).toDate()
                      : DateTime.now();

                  final timeOnPage = pageView['timeOnPage'] != null
                      ? Duration(seconds: pageView['timeOnPage'])
                      : null;

                  final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(Icons.insert_drive_file,
                          color: Colors.blue.shade700),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            pageView['path'] ?? 'غير معروف',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeOnPage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              '${timeOnPage.inMinutes}:${(timeOnPage.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: GoogleFonts.cairo(
                                color: Colors.blue.shade800,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              formatter.format(timestamp),
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (pageView['referrer'] != null &&
                            pageView['referrer'] != '') ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.link,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'المرجع: ${pageView['referrer']}',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (pageView['title'] != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.title,
                                  size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'العنوان: ${pageView['title']}',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
              if (pageViews.length > 5) ...[
                SizedBox(height: isSmallScreen ? 8 : 12),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.expand_more),
                    label: Text(
                      'عرض المزيد',
                      style: GoogleFonts.cairo(),
                    ),
                    onPressed: () => _showAllPageViewsDialog(
                        context, pageViews, isSmallScreen),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataCard(
      Map<String, dynamic> data, bool isSmallScreen, BuildContext context) {
    // Create a copy of the data without large nested lists
    final displayData = Map<String, dynamic>.from(data);
    displayData.remove('sessions');
    displayData.remove('pageViews');

    // Convert to JSON string and prettify
    final jsonString = const JsonEncoder.withIndent('  ').convert(displayData);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            Icon(Icons.code,
                color: Colors.grey.shade700, size: isSmallScreen ? 20 : 24),
            const SizedBox(width: 8),
            Text(
              'البيانات الخام',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text('نسخ البيانات', style: GoogleFonts.cairo()),
                      onPressed: () => _copyToClipboard(jsonString, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: isSmallScreen ? 800 : 1000,
                      child: SelectableText(
                        jsonString,
                        style: GoogleFonts.robotoMono(
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isSmallScreen, {
    VoidCallback? onCopy,
    VoidCallback? onLookup,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 14 : 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: onCopy,
            tooltip: 'نسخ',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        if (onLookup != null)
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18),
            onPressed: onLookup,
            tooltip: 'استعلام',
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النسخ إلى الحافظة', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _lookupIP(String ip, BuildContext context) async {
    final url = 'https://whatismyipaddress.com/ip/$ip';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن فتح الرابط', style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAllSessionsDialog(
    BuildContext context,
    List sessions,
    bool isSmallScreen,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'جميع جلسات المستخدم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final session = sessions[index] as Map<String, dynamic>;

                final startTime = session['startTime'] != null
                    ? (session['startTime'] as Timestamp).toDate()
                    : DateTime.now();

                final duration = session['duration'] != null
                    ? Duration(seconds: session['duration'])
                    : Duration.zero;

                final formatter = DateFormat('dd/MM/yyyy HH:mm');

                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        formatter.format(startTime),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Text(
                          '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.cairo(
                            color: Colors.purple.shade800,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (session['referrer'] != null &&
                          session['referrer'] != '') ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.link,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'المرجع: ${session['referrer']}',
                                style: GoogleFonts.cairo(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (session['entryPage'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.login,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'صفحة الدخول: ${session['entryPage']}',
                                style: GoogleFonts.cairo(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (session['exitPage'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.logout,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'صفحة الخروج: ${session['exitPage']}',
                                style: GoogleFonts.cairo(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  void _showAllPageViewsDialog(
    BuildContext context,
    List pageViews,
    bool isSmallScreen,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'جميع مشاهدات الصفحات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: pageViews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final pageView = pageViews[index] as Map<String, dynamic>;

                final timestamp = pageView['timestamp'] != null
                    ? (pageView['timestamp'] as Timestamp).toDate()
                    : DateTime.now();

                final timeOnPage = pageView['timeOnPage'] != null
                    ? Duration(seconds: pageView['timeOnPage'])
                    : null;

                final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');

                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          pageView['path'] ?? 'غير معروف',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeOnPage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '${timeOnPage.inMinutes}:${(timeOnPage.inSeconds % 60).toString().padLeft(2, '0')}',
                            style: GoogleFonts.cairo(
                              color: Colors.blue.shade800,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            formatter.format(timestamp),
                            style: GoogleFonts.cairo(fontSize: 12),
                          ),
                        ],
                      ),
                      if (pageView['referrer'] != null &&
                          pageView['referrer'] != '') ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.link,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'المرجع: ${pageView['referrer']}',
                                style: GoogleFonts.cairo(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (pageView['title'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.title,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'العنوان: ${pageView['title']}',
                                style: GoogleFonts.cairo(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إغلاق', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  void _showBlockDialog(
    BuildContext context,
    String ip,
    WidgetRef ref,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'حظر المستخدم',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ip.isNotEmpty) ...[
                Text('عنوان IP:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text(ip, style: GoogleFonts.cairo()),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'سبب الحظر',
                  labelStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'اكتب سبب الحظر هنا...',
                ),
                style: GoogleFonts.cairo(),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: GoogleFonts.cairo()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('الرجاء إدخال سبب الحظر'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  // Check if already blocked
                  final snapshot = await FirebaseFirestore.instance
                      .collection('blockedUsers')
                      .where('ip', isEqualTo: ip)
                      .get();

                  if (snapshot.docs.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('هذا المستخدم محظور بالفعل'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  // Create blocked user entry
                  final blockedUser = {
                    'ip': ip,
                    'userAgent': visitorId, // Using visitor ID as a reference
                    'reason': reasonController.text.trim(),
                    'blockedAt': Timestamp.now(),
                    'blockedBy': ref.read(authProvider).user?.email ?? 'Admin',
                  };

                  // Add to Firestore
                  await FirebaseFirestore.instance
                      .collection('blockedUsers')
                      .add(blockedUser);

                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حظر المستخدم بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate back to previous screen
                  Navigator.pop(context);
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
              child: Text('حظر', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }
}
