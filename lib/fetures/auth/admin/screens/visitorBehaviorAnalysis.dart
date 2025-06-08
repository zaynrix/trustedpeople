import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trustedtallentsvalley/fetures/services/visitor_analytics_service.dart';

// Provider for user behavior data
final userBehaviorDataProvider = FutureProvider.autoDispose((ref) async {
  final analyticsService = VisitorAnalyticsService();
  return await analyticsService.getVisitorBehaviorData();
});

// Provider for demographic data
final demographicDataProvider = FutureProvider.autoDispose((ref) async {
  final analyticsService = VisitorAnalyticsService();
  return await analyticsService.getVisitorDemographicData();
});

class VisitorBehaviorAnalysis extends ConsumerWidget {
  const VisitorBehaviorAnalysis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final behaviorDataAsync = ref.watch(userBehaviorDataProvider);
    final demographicDataAsync = ref.watch(demographicDataProvider);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تحليل سلوك الزوار',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(userBehaviorDataProvider);
              ref.refresh(demographicDataProvider);
            },
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportDataToCSV(context, ref),
            tooltip: 'تصدير البيانات',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(userBehaviorDataProvider);
          ref.refresh(demographicDataProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('تحليل سلوك الزوار', Icons.analytics,
                  Colors.blue.shade700, isSmallScreen),
              SizedBox(height: isSmallScreen ? 16.0 : 24.0),
              _buildBehaviorContent(behaviorDataAsync, demographicDataAsync,
                  isSmallScreen, context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      String title, IconData icon, Color color, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmallScreen ? 24 : 28,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorContent(
    AsyncValue<Map<String, dynamic>> behaviorDataAsync,
    AsyncValue<Map<String, dynamic>> demographicDataAsync,
    bool isSmallScreen,
    BuildContext context,
    WidgetRef ref,
  ) {
    return behaviorDataAsync.when(
      data: (behaviorData) {
        return demographicDataAsync.when(
          data: (demographicData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPopularPagesCard(behaviorData, isSmallScreen, context),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                _buildReferrerSourcesCard(behaviorData, isSmallScreen, context),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                _buildDemographicsCard(demographicData, isSmallScreen, context),
                SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                _buildTrafficSourcesCard(
                    demographicData, isSmallScreen, context),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text(
              'حدث خطأ: $error',
              style: GoogleFonts.cairo(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'حدث خطأ: $error',
          style: GoogleFonts.cairo(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPopularPagesCard(
      Map<String, dynamic> behaviorData, bool isSmallScreen, context) {
    final popularPages =
        behaviorData['popularPages'] as List<Map<String, dynamic>>? ?? [];

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
                Icon(
                  Icons.pageview,
                  color: Colors.purple.shade700,
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'الصفحات الأكثر زيارة',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),
            if (popularPages.isEmpty)
              Center(
                child: Text(
                  'لا توجد بيانات متاحة',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: popularPages.length > 5 ? 5 : popularPages.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final page = popularPages[index];

                  // Format average time spent
                  final avgTimeSpent = page['avgTimeSpent'] as double? ?? 0;
                  final minutes = avgTimeSpent ~/ 60;
                  final seconds = (avgTimeSpent % 60).toInt();
                  final timeSpentFormatted =
                      '$minutes:${seconds.toString().padLeft(2, '0')}';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.cairo(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            page['path'] as String? ?? '',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Text(
                            '${page['views']} زيارة',
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
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'متوسط وقت الزيارة: $timeSpentFormatted',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.login,
                              size: 16,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'صفحة دخول: ${page['entryCount']} مرة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.logout,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'صفحة خروج: ${page['exitCount']} مرة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            if (popularPages.length > 5) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.expand_more),
                  label: Text(
                    'عرض المزيد',
                    style: GoogleFonts.cairo(),
                  ),
                  onPressed: () =>
                      _showAllPagesDialog(popularPages, isSmallScreen, context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferrerSourcesCard(
      Map<String, dynamic> behaviorData, bool isSmallScreen, context) {
    final referrerSources =
        behaviorData['referrerSources'] as List<Map<String, dynamic>>? ?? [];

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
                Icon(
                  Icons.link,
                  color: Colors.teal.shade700,
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'مصادر الإحالة',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),
            if (referrerSources.isEmpty)
              Center(
                child: Text(
                  'لا توجد بيانات متاحة',
                  style: GoogleFonts.cairo(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              )
            else
              SizedBox(
                height: isSmallScreen ? 180 : 220,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildReferrerPieChart(
                          referrerSources, isSmallScreen),
                    ),
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: referrerSources.length > 5
                            ? 5
                            : referrerSources.length,
                        itemBuilder: (context, index) {
                          final source = referrerSources[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _getColorForReferrer(index),
                              radius: isSmallScreen ? 12 : 16,
                            ),
                            title: Text(
                              source['source'] as String? ?? 'مباشر',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 13 : 15,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '${source['count']} زيارة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (referrerSources.length > 5) ...[
              SizedBox(height: isSmallScreen ? 8 : 12),
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.expand_more),
                  label: Text(
                    'عرض المزيد',
                    style: GoogleFonts.cairo(),
                  ),
                  onPressed: () => _showAllReferrersDialog(
                      referrerSources, isSmallScreen, context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferrerPieChart(
      List<Map<String, dynamic>> referrerSources, bool isSmallScreen) {
    // Calculate total referrals
    int totalReferrals = 0;
    for (final source in referrerSources) {
      totalReferrals += source['count'] as int? ?? 0;
    }

    return SizedBox(
      height: isSmallScreen ? 180 : 220,
      child: totalReferrals == 0
          ? Center(
              child: Text(
                'لا توجد بيانات',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: isSmallScreen ? 30 : 40,
                sections: referrerSources
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final source = entry.value;
                  final value = (source['count'] as int? ?? 0).toDouble();
                  final percent =
                      totalReferrals > 0 ? (value / totalReferrals) * 100 : 0.0;

                  return PieChartSectionData(
                    color: _getColorForReferrer(index),
                    value: value,
                    title: '${percent.toStringAsFixed(1)}%',
                    radius: isSmallScreen ? 60 : 80,
                    titleStyle: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _getColorForReferrer(int index) {
    switch (index % 5) {
      case 0:
        return Colors.teal;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.red;
      case 4:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Widget _buildDemographicsCard(Map<String, dynamic> demographicData,
      bool isSmallScreen, BuildContext context) {
    // final countries =
    //     demographicData['countries'] as List<Map<String, dynamic>>? ?? [];

    // Create view tabs for different demographics
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Row(
                children: [
                  Icon(
                    Icons.pie_chart,
                    color: Colors.indigo.shade700,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الديموغرافيا',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              isScrollable: true,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.cairo(),
              tabs: const [
                Tab(text: 'البلدان'),
                Tab(text: 'المتصفحات'),
                Tab(text: 'الأجهزة'),
                Tab(text: 'أنظمة التشغيل'),
              ],
            ),
            SizedBox(
              height: isSmallScreen ? 240 : 300,
              child: TabBarView(
                children: [
                  _buildCountriesTab(demographicData, isSmallScreen, context),
                  _buildBrowsersTab(demographicData, isSmallScreen, context),
                  _buildDevicesTab(demographicData, isSmallScreen, context),
                  _buildOsTab(demographicData, isSmallScreen, context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountriesTab(Map<String, dynamic> demographicData,
      bool isSmallScreen, BuildContext context) {
    final countries =
        demographicData['countries'] as List<Map<String, dynamic>>? ?? [];

    if (countries.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      );
    }

    // Calculate total visitors
    int totalVisitors = 0;
    for (final country in countries) {
      totalVisitors += country['count'] as int? ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildPieChart(countries, totalVisitors, isSmallScreen,
                (index) => _getColorForCountry(index)),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: countries.length > 5 ? 5 : countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final count = country['count'] as int? ?? 0;
                final percent =
                    totalVisitors > 0 ? (count / totalVisitors) * 100 : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getColorForCountry(index),
                    radius: isSmallScreen ? 12 : 16,
                  ),
                  title: Text(
                    country['country'] as String? ?? 'غير معروف',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${count.toString()} (${percent.toStringAsFixed(1)}%)',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowsersTab(Map<String, dynamic> demographicData,
      bool isSmallScreen, BuildContext context) {
    final browsers =
        demographicData['browsers'] as List<Map<String, dynamic>>? ?? [];

    if (browsers.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      );
    }

    // Calculate total visitors
    int totalVisitors = 0;
    for (final browser in browsers) {
      totalVisitors += browser['count'] as int? ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildPieChart(browsers, totalVisitors, isSmallScreen,
                (index) => _getColorForBrowser(index)),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: browsers.length > 5 ? 5 : browsers.length,
              itemBuilder: (context, index) {
                final browser = browsers[index];
                final count = browser['count'] as int? ?? 0;
                final percent =
                    totalVisitors > 0 ? (count / totalVisitors) * 100 : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getColorForBrowser(index),
                    radius: isSmallScreen ? 12 : 16,
                  ),
                  title: Text(
                    browser['browser'] as String? ?? 'غير معروف',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${count.toString()} (${percent.toStringAsFixed(1)}%)',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesTab(Map<String, dynamic> demographicData,
      bool isSmallScreen, BuildContext context) {
    final devices =
        demographicData['devices'] as List<Map<String, dynamic>>? ?? [];

    if (devices.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      );
    }

    // Calculate total visitors
    int totalVisitors = 0;
    for (final device in devices) {
      totalVisitors += device['count'] as int? ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildPieChart(devices, totalVisitors, isSmallScreen,
                (index) => _getColorForDevice(index)),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length > 5 ? 5 : devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                final count = device['count'] as int? ?? 0;
                final percent =
                    totalVisitors > 0 ? (count / totalVisitors) * 100 : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getColorForDevice(index),
                    radius: isSmallScreen ? 12 : 16,
                  ),
                  title: Text(
                    device['device'] as String? ?? 'غير معروف',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${count.toString()} (${percent.toStringAsFixed(1)}%)',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsTab(Map<String, dynamic> demographicData, bool isSmallScreen,
      BuildContext context) {
    final osystems =
        demographicData['operatingSystems'] as List<Map<String, dynamic>>? ??
            [];

    if (osystems.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات متاحة',
          style: GoogleFonts.cairo(
            color: Colors.grey.shade600,
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
      );
    }

    // Calculate total visitors
    int totalVisitors = 0;
    for (final os in osystems) {
      totalVisitors += os['count'] as int? ?? 0;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildPieChart(osystems, totalVisitors, isSmallScreen,
                (index) => _getColorForOS(index)),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: osystems.length > 5 ? 5 : osystems.length,
              itemBuilder: (context, index) {
                final os = osystems[index];
                final count = os['count'] as int? ?? 0;
                final percent =
                    totalVisitors > 0 ? (count / totalVisitors) * 100 : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: _getColorForOS(index),
                    radius: isSmallScreen ? 12 : 16,
                  ),
                  title: Text(
                    os['os'] as String? ?? 'غير معروف',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${count.toString()} (${percent.toStringAsFixed(1)}%)',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    List<Map<String, dynamic>> data,
    int total,
    bool isSmallScreen,
    Color Function(int) getColor,
  ) {
    return SizedBox(
      height: isSmallScreen ? 180 : 220,
      child: total == 0
          ? Center(
              child: Text(
                'لا توجد بيانات',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade600,
                ),
              ),
            )
          : PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: isSmallScreen ? 30 : 40,
                sections: data.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final value = (item['count'] as int? ?? 0).toDouble();
                  final percent = total > 0 ? (value / total) * 100 : 0.0;

                  return PieChartSectionData(
                    color: getColor(index),
                    value: value,
                    title: '${percent.toStringAsFixed(1)}%',
                    radius: isSmallScreen ? 60 : 80,
                    titleStyle: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _getColorForCountry(int index) {
    switch (index % 5) {
      case 0:
        return Colors.indigo;
      case 1:
        return Colors.green;
      case 2:
        return Colors.amber;
      case 3:
        return Colors.red;
      case 4:
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  Color _getColorForBrowser(int index) {
    switch (index % 5) {
      case 0:
        return Colors.blue.shade700;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.redAccent;
      case 4:
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  Color _getColorForDevice(int index) {
    switch (index % 4) {
      case 0:
        return Colors.teal.shade700;
      case 1:
        return Colors.red.shade700;
      case 2:
        return Colors.amber.shade700;
      case 3:
        return Colors.purple.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  Color _getColorForOS(int index) {
    switch (index % 5) {
      case 0:
        return Colors.green.shade700;
      case 1:
        return Colors.blue.shade700;
      case 2:
        return Colors.grey.shade700;
      case 3:
        return Colors.amber.shade700;
      case 4:
        return Colors.red.shade700;
      default:
        return Colors.purple.shade700;
    }
  }

  Widget _buildTrafficSourcesCard(Map<String, dynamic> demographicData,
      bool isSmallScreen, BuildContext context) {
    // This card shows trends in traffic over time
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
                Icon(
                  Icons.timeline,
                  color: Colors.amber.shade700,
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'أدوات إضافية',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Additional tools grid
            GridView.count(
              crossAxisCount: isSmallScreen ? 2 : 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _buildToolCard(
                  'تصدير البيانات',
                  Icons.file_download,
                  Colors.green,
                  () => _exportDataToCSV(context, null),
                  isSmallScreen,
                ),
                _buildToolCard(
                  'تتبع المسار',
                  Icons.route,
                  Colors.purple,
                  () => _showComingSoonDialog(context, 'ميزة تتبع مسار الزائر'),
                  isSmallScreen,
                ),
                _buildToolCard(
                  'خريطة حرارية',
                  Icons.whatshot,
                  Colors.red,
                  () => _showComingSoonDialog(
                      context, 'ميزة الخريطة الحرارية للموقع'),
                  isSmallScreen,
                ),
                _buildToolCard(
                  'الإشعارات',
                  Icons.notifications,
                  Colors.amber,
                  () => _showComingSoonDialog(
                      context, 'ميزة الإشعارات التلقائية'),
                  isSmallScreen,
                ),
                _buildToolCard(
                  'التقارير الدورية',
                  Icons.schedule,
                  Colors.blue,
                  () => _showComingSoonDialog(context, 'ميزة التقارير الدورية'),
                  isSmallScreen,
                ),
                _buildToolCard(
                  'الإعدادات',
                  Icons.settings,
                  Colors.grey,
                  () =>
                      _showComingSoonDialog(context, 'إعدادات تحليلات الزوار'),
                  isSmallScreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isSmallScreen ? 24 : 32,
            ),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAllPagesDialog(List<Map<String, dynamic>> pages, bool isSmallScreen,
      BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'جميع الصفحات',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: pages.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final page = pages[index];

                // Format average time spent
                final avgTimeSpent = page['avgTimeSpent'] as double? ?? 0;
                final minutes = avgTimeSpent ~/ 60;
                final seconds = (avgTimeSpent % 60).toInt();
                final timeSpentFormatted =
                    '$minutes:${seconds.toString().padLeft(2, '0')}';

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              page['path'] as String? ?? '',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.purple.shade200),
                            ),
                            child: Text(
                              '${page['views']} زيارة',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.purple.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'متوسط وقت الزيارة: $timeSpentFormatted',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.login,
                            size: 16,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'صفحة دخول: ${page['entryCount']} مرة',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.logout,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'صفحة خروج: ${page['exitCount']} مرة',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  void _showAllReferrersDialog(List<Map<String, dynamic>> referrers,
      bool isSmallScreen, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'جميع مصادر الإحالة',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: referrers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final source = referrers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getColorForReferrer(index % 5),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    source['source'] as String? ?? 'مباشر',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    '${source['count']} زيارة',
                    style: GoogleFonts.cairo(
                      color: Colors.grey.shade700,
                    ),
                  ),
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

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'قريباً',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.engineering,
                size: 48,
                color: Colors.amber,
              ),
              SizedBox(height: 16),
              Text(
                'جاري العمل على $feature',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'هذه الميزة قيد التطوير وستكون متاحة قريباً',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('حسناً', style: GoogleFonts.cairo()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportDataToCSV(BuildContext context, WidgetRef? ref) async {
    try {
      final analyticsService = VisitorAnalyticsService();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري تصدير البيانات...',
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
          );
        },
      );

      // Export data
      final csvData = await analyticsService.exportVisitorDataToCsv();

      // Close loading dialog
      Navigator.pop(context);

      // Save the CSV file
      final bytes = Uint8List.fromList(utf8.encode(csvData));
      await FileSaver.instance.saveFile(
        name:
            'visitor_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تصدير البيانات بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تصدير البيانات: $e',
              style: GoogleFonts.cairo()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
