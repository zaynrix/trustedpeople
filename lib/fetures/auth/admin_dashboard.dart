// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:trustedtallentsvalley/services/auth_service.dart';
// import 'package:trustedtallentsvalley/services/visitor_analytics_service.dart';
//
// // Providers remain the same
// final analyticsDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});
// final chartDataProvider =
//     StateProvider<List<Map<String, dynamic>>>((ref) => []);
// final visitorLocationsProvider =
//     StateProvider<List<Map<String, dynamic>>>((ref) => []);
// final isLoadingProvider = StateProvider<bool>((ref) => true);
// final analyticsServiceProvider = Provider((ref) => VisitorAnalyticsService());
// final loadAnalyticsProvider = FutureProvider.autoDispose((ref) async {
//   final isAdmin = ref.watch(isAdminProvider);
//   final analyticsService = ref.watch(analyticsServiceProvider);
//
//   if (!isAdmin) {
//     ref.read(isLoadingProvider.notifier).state = false;
//     return;
//   }
//
//   ref.read(isLoadingProvider.notifier).state = true;
//
//   try {
//     final stats = await analyticsService.getVisitorStats();
//     final chartData = await analyticsService.getVisitorChartData();
//     final locationData = await analyticsService.getVisitorLocationData();
//
//     ref.read(analyticsDataProvider.notifier).state = stats;
//     ref.read(chartDataProvider.notifier).state = chartData;
//     ref.read(visitorLocationsProvider.notifier).state = locationData;
//   } catch (e) {
//     debugPrint('Error loading analytics data: $e');
//   } finally {
//     ref.read(isLoadingProvider.notifier).state = false;
//   }
// });
//
// class AdminDashboard extends ConsumerWidget {
//   const AdminDashboard({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch all state providers
//     final isAdmin = ref.watch(isAdminProvider);
//     final isLoading = ref.watch(isLoadingProvider);
//     final analyticsData = ref.watch(analyticsDataProvider);
//     final chartData = ref.watch(chartDataProvider);
//     final visitorLocations = ref.watch(visitorLocationsProvider);
//
//     // Get screen size info
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 600;
//
//     // Trigger data load when component builds
//     ref.watch(loadAnalyticsProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('لوحة التحكم', style: GoogleFonts.cairo()),
//         actions: [
//           if (isAdmin)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () => ref.refresh(loadAnalyticsProvider),
//               tooltip: 'تحديث البيانات',
//             ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : !isAdmin
//               ? _buildAccessDeniedMessage(context)
//               : SafeArea(
//                   child: RefreshIndicator(
//                     onRefresh: () async => ref.refresh(loadAnalyticsProvider),
//                     child: SingleChildScrollView(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 12.0 : 16.0,
//                         vertical: isSmallScreen ? 12.0 : 16.0,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildHeader(isSmallScreen),
//                           SizedBox(height: isSmallScreen ? 12.0 : 16.0),
//                           _buildAnalyticsCards(
//                               analyticsData, isSmallScreen, context),
//                           SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//                           _buildVisitorChart(chartData, isSmallScreen),
//                           SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//                           _buildVisitorMap(visitorLocations, isSmallScreen),
//                           SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//                           _buildVisitorTable(
//                               visitorLocations, isSmallScreen, context, ref),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }
//
//   Widget _buildAccessDeniedMessage(BuildContext context) {
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.lock,
//               size: isSmallScreen ? 60 : 80,
//               color: Colors.red.shade300,
//             ),
//             SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//             Text(
//               'عذراً، هذه الصفحة للمشرفين فقط',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 20 : 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red.shade700,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isSmallScreen ? 12.0 : 16.0),
//             Text(
//               'لا تملك الصلاحيات الكافية للوصول إلى لوحة التحكم. يرجى التواصل مع المسؤول إذا كنت تعتقد أن هذا خطأ.',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 color: Colors.grey.shade700,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.arrow_back),
//               label: Text('العودة', style: GoogleFonts.cairo()),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 24 : 32,
//                     vertical: isSmallScreen ? 10 : 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(bool isSmallScreen) {
//     return Row(
//       children: [
//         Icon(Icons.admin_panel_settings,
//             size: isSmallScreen ? 24 : 28, color: Colors.blue.shade700),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             'إحصائيات الموقع',
//             style: GoogleFonts.cairo(
//               fontSize: isSmallScreen ? 20 : 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue.shade700,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAnalyticsCards(Map<String, dynamic> analyticsData,
//       bool isSmallScreen, BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     // Determine grid columns based on screen size
//     int crossAxisCount;
//     if (screenWidth > 1200) {
//       crossAxisCount = 3; // Large screens - 3 cards in a row
//     } else if (screenWidth > 600) {
//       crossAxisCount = 3; // Medium screens - 2 cards in a row
//     } else {
//       crossAxisCount = 2; // Small screens - 1 card per row
//     }
//
//     return Padding(
//       padding: EdgeInsets.all(
//           isSmallScreen ? 8.0 : 12.0), // Add padding around the grid
//       child: GridView.count(
//         crossAxisCount: crossAxisCount,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         crossAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
//         mainAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
//         childAspectRatio:
//             isSmallScreen ? 1.8 : 2.0, // Increased ratio makes items shorter
//         children: [
//           _buildAnalyticItem(
//             analyticsData['todayVisitors']?.toString() ?? '0',
//             'زيارة اليوم',
//             Icons.trending_up,
//             Colors.green,
//             '${analyticsData['percentChange']?.toStringAsFixed(1) ?? '0'}% عن أمس',
//             isSmallScreen: isSmallScreen,
//           ),
//           _buildAnalyticItem(
//             analyticsData['totalVisitors']?.toString() ?? '0',
//             'إجمالي الزيارات',
//             Icons.people,
//             Colors.blue,
//             '${analyticsData['monthlyVisitors'] ?? '0'} زيارة هذا الشهر',
//             isSmallScreen: isSmallScreen,
//           ),
//           _buildAnalyticItem(
//             analyticsData['avgSessionDuration'] ?? '0:00',
//             'متوسط مدة الزيارة',
//             Icons.timer,
//             Colors.orange,
//             'تحديث لحظي',
//             isSmallScreen: isSmallScreen,
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Modified _buildAnalyticItem to support responsive sizing
//   Widget _buildAnalyticItem(
//     String value,
//     String title,
//     IconData icon,
//     Color color,
//     String subtitle, {
//     required bool isSmallScreen,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: GoogleFonts.cairo(
//                       fontSize: isSmallScreen ? 14 : 16,
//                       color: Colors.grey.shade700,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               value,
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 24 : 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               subtitle,
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVisitorChart(
//       List<Map<String, dynamic>> chartData, bool isSmallScreen) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.insert_chart,
//                     color: Colors.purple.shade700,
//                     size: isSmallScreen ? 20 : 24),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     'الزيارات خلال آخر 7 أيام',
//                     style: GoogleFonts.cairo(
//                       fontSize: isSmallScreen ? 16 : 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: isSmallScreen ? 16 : 24),
//             SizedBox(
//               height: isSmallScreen ? 200 : 250,
//               child: chartData.isEmpty
//                   ? Center(
//                       child: Text(
//                         'لا توجد بيانات متاحة',
//                         style: GoogleFonts.cairo(),
//                       ),
//                     )
//                   : _buildBarChart(chartData, isSmallScreen),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBarChart(
//       List<Map<String, dynamic>> chartData, bool isSmallScreen) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               return BarTooltipItem(
//                 '${chartData[groupIndex]['visits']} زائر',
//                 const TextStyle(color: Colors.white),
//               );
//             },
//           ),
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= 0 && value.toInt() < chartData.length) {
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       chartData[value.toInt()]['day'],
//                       style:
//                           GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 30,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   value.toInt().toString(),
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
//                   textAlign: TextAlign.left,
//                 );
//               },
//             ),
//           ),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           getDrawingHorizontalLine: (value) => FlLine(
//             color: Colors.grey.shade300,
//             strokeWidth: 1,
//           ),
//         ),
//         borderData: FlBorderData(
//           show: false,
//         ),
//         barGroups: chartData.asMap().entries.map((entry) {
//           final index = entry.key;
//           final data = entry.value;
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: (data['visits'] as num).toDouble(),
//                 color: Colors.blue.shade400,
//                 width: isSmallScreen ? 15 : 20,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(6),
//                   topRight: Radius.circular(6),
//                 ),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   Widget _buildVisitorMap(
//       List<Map<String, dynamic>> visitorLocations, bool isSmallScreen) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // Expandable section header
//           ExpansionTile(
//             title: Row(
//               children: [
//                 Icon(Icons.map,
//                     color: Colors.green.shade700,
//                     size: isSmallScreen ? 20 : 24),
//                 const SizedBox(width: 8),
//                 Text(
//                   'خريطة الزوار',
//                   style: GoogleFonts.cairo(
//                     fontSize: isSmallScreen ? 16 : 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             initiallyExpanded:
//                 !isSmallScreen, // Collapsed by default on small screens
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
//                 child: SizedBox(
//                   height: isSmallScreen ? 200 : 300,
//                   child: visitorLocations.isEmpty
//                       ? Center(
//                           child: Text(
//                             'لا توجد بيانات متاحة',
//                             style: GoogleFonts.cairo(),
//                           ),
//                         )
//                       : _buildMap(visitorLocations),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMap(List<Map<String, dynamic>> visitorLocations) {
//     final markers = visitorLocations.map((location) {
//       return Marker(
//         width: 30.0,
//         height: 30.0,
//         point: LatLng(
//           (location['latitude'] as num).toDouble(),
//           (location['longitude'] as num).toDouble(),
//         ),
//         child: const Icon(
//           Icons.location_pin,
//           color: Colors.red,
//           size: 24,
//         ),
//       );
//     }).toList();
//
//     return FlutterMap(
//       options: MapOptions(
//         initialCenter: LatLng(25.0, 10.0),
//         initialZoom: 2.0,
//       ),
//       children: [
//         TileLayer(
//           urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//           subdomains: const ['a', 'b', 'c'],
//         ),
//         MarkerLayer(
//           markers: markers,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVisitorTable(List<Map<String, dynamic>> visitorLocations,
//       bool isSmallScreen, BuildContext context, ref) {
//     // For very small screens, we'll show a more mobile-friendly list view instead of a table
//     final useListView = MediaQuery.of(context).size.width < 480;
//
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           // Expandable section header
//           ExpansionTile(
//             title: Row(
//               children: [
//                 Icon(Icons.list_alt,
//                     color: Colors.blue.shade700, size: isSmallScreen ? 20 : 24),
//                 const SizedBox(width: 8),
//                 Text(
//                   'بيانات الزوار',
//                   style: GoogleFonts.cairo(
//                     fontSize: isSmallScreen ? 16 : 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             subtitle: Text(
//               'عدد الزوار: ${visitorLocations.length}',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 12 : 14,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//             initiallyExpanded:
//                 !isSmallScreen, // Collapsed by default on small screens
//             children: [
//               Padding(
//                 padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
//                 child: useListView
//                     ? _buildVisitorListView(
//                         visitorLocations, isSmallScreen, context, ref)
//                     : _buildVisitorTableView(
//                         visitorLocations, isSmallScreen, context, ref),
//               ),
//               if (visitorLocations.length > 20)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: Center(
//                     child: Text(
//                       'يتم عرض أحدث 20 زائر من إجمالي ${visitorLocations.length}',
//                       style: GoogleFonts.cairo(
//                         fontSize: isSmallScreen ? 12 : 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildVisitorTableView(List<Map<String, dynamic>> visitorLocations,
//       bool isSmallScreen, BuildContext context, WidgetRef ref) {
//     // Added context and ref parameters
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: DataTable(
//         columnSpacing: isSmallScreen ? 16 : 24,
//         dataRowMinHeight: isSmallScreen ? 48 : 56,
//         dataRowMaxHeight: isSmallScreen ? 64 : 72,
//         columns: [
//           DataColumn(
//             label: Text(
//               'التاريخ',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           DataColumn(
//             label: Text(
//               'عنوان IP',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           DataColumn(
//             label: Text(
//               'البلد',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           DataColumn(
//             label: Text(
//               'المدينة',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           DataColumn(
//             label: Text(
//               'المنطقة',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           // Add action column
//           DataColumn(
//             label: Text(
//               'إجراءات',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//           DataColumn(
//             label: Text(
//               'تفاصيل',
//               style: GoogleFonts.cairo(
//                 fontWeight: FontWeight.bold,
//                 fontSize: isSmallScreen ? 12 : 14,
//               ),
//             ),
//           ),
//         ],
//         rows: visitorLocations.take(20).map((location) {
//           // Format timestamp
//           String formattedDate = 'غير معروف';
//           if (location.containsKey('timestamp')) {
//             final timestamp = DateTime.parse(location['timestamp'] as String);
//             formattedDate =
//                 '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//           }
//
//           return DataRow(
//             cells: [
//               DataCell(Text(formattedDate,
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//               DataCell(Text(location['ipAddress'] ?? 'غير معروف',
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//               DataCell(Text(location['country'] ?? 'غير معروف',
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//               DataCell(Text(location['city'] ?? 'غير معروف',
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//               DataCell(Text(location['region'] ?? 'غير معروف',
//                   style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//               // Add block action cell
//               DataCell(
//                 IconButton(
//                   icon: Icon(Icons.block, color: Colors.red, size: 20),
//                   tooltip: 'حظر هذا المستخدم',
//                   onPressed: () {
//                     _showBlockDialog(
//                       context,
//                       ref,
//                       location['ipAddress'] ?? '',
//                       location['userAgent'] ?? '',
//                       '${location['country'] ?? ''}, ${location['city'] ?? ''}',
//                     );
//                   },
//                 ),
//               ),
//               DataCell(
//                 IconButton(
//                   icon: Icon(Icons.remove_red_eye_outlined,
//                       color: Colors.red, size: 20),
//                   tooltip: 'view',
//                   onPressed: () {
//                     // _showFullUserAgentDialog(context,)
//                   },
//                 ),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
//
// // List view for mobile screens with blocking functionality
//   Widget _buildVisitorListView(List<Map<String, dynamic>> visitorLocations,
//       bool isSmallScreen, BuildContext context, WidgetRef ref) {
//     // Added context and ref parameters
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: visitorLocations.length > 20 ? 20 : visitorLocations.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final location = visitorLocations[index];
//
//         // Format timestamp
//         String formattedDate = 'غير معروف';
//         if (location.containsKey('timestamp')) {
//           final timestamp = DateTime.parse(location['timestamp'] as String);
//           formattedDate =
//               '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//         }
//
//         return ListTile(
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '${location['country'] ?? 'غير معروف'} - ${location['city'] ?? 'غير معروف'}',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 'IP: ${location['ipAddress'] ?? 'غير معروف'}',
//                 style: GoogleFonts.cairo(fontSize: 13),
//               ),
//             ],
//           ),
//           subtitle: Text(
//             'التاريخ: $formattedDate',
//             style: GoogleFonts.cairo(
//               color: Colors.grey.shade600,
//               fontSize: 12,
//             ),
//           ),
//           trailing: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.block, color: Colors.red, size: 20),
//                 tooltip: 'حظر هذا المستخدم',
//                 onPressed: () {
//                   _showBlockDialog(
//                     context,
//                     ref,
//                     location['ipAddress'] ?? '',
//                     location['userAgent'] ?? '',
//                     '${location['country'] ?? ''}, ${location['city'] ?? ''}',
//                   );
//                 },
//               ),
//               Icon(
//                 Icons.location_on,
//                 color: Colors.redAccent,
//                 size: 18,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
// // Enhanced security info row with copy and block options
//   Widget _buildSecurityInfoRow(
//     String label,
//     String value, {
//     VoidCallback? onCopy,
//     VoidCallback? onBlock,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.cairo(),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           if (onCopy != null)
//             IconButton(
//               icon: const Icon(Icons.copy, size: 16),
//               onPressed: onCopy,
//               tooltip: 'نسخ',
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(),
//             ),
//           if (onBlock != null)
//             IconButton(
//               icon: const Icon(Icons.block, size: 16, color: Colors.red),
//               onPressed: onBlock,
//               tooltip: 'حظر',
//               padding: const EdgeInsets.only(right: 8),
//               constraints: const BoxConstraints(),
//             ),
//         ],
//       ),
//     );
//   }
//
// // Copy to clipboard helper
//   void _copyToClipboard(String text, context) {
//     Clipboard.setData(ClipboardData(text: text));
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('تم النسخ'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
// // Show full user agent in a dialog
//   void _showFullUserAgentDialog(BuildContext context, String userAgent) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'تفاصيل User Agent',
//             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
//           ),
//           content: Container(
//             width: double.maxFinite,
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SelectableText(
//                     userAgent,
//                     style: GoogleFonts.robotoMono(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => _copyToClipboard(userAgent, context),
//               child: Text('نسخ', style: GoogleFonts.cairo()),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إغلاق', style: GoogleFonts.cairo()),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// // Check if an IP is already blocked
//   Future<bool> _checkIfBlocked(String ip, context) async {
//     if (ip.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('عنوان IP غير متوفر'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return false;
//     }
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('blockedUsers')
//           .where('ip', isEqualTo: ip)
//           .get();
//
//       final isBlocked = snapshot.docs.isNotEmpty;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(isBlocked
//               ? 'هذا المستخدم محظور بالفعل'
//               : 'هذا المستخدم غير محظور'),
//           backgroundColor: isBlocked ? Colors.red : Colors.green,
//         ),
//       );
//
//       return isBlocked;
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('حدث خطأ: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//   }
//
// // // Show block dialog and add to blocked users
// //   void _showBlockDialog(
// //       BuildContext context, {
// //         required String ip,
// //         required String userAgent,
// //         required String email,
// //       }) {
// //     final reasonController = TextEditingController();
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text(
// //             'حظر المستخدم',
// //             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (ip.isNotEmpty) ...[
// //                 Text('عنوان IP:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
// //                 Text(ip, style: GoogleFonts.cairo()),
// //                 const SizedBox(height: 8),
// //               ],
// //               if (email.isNotEmpty) ...[
// //                 Text('البريد الإلكتروني:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
// //                 Text(email, style: GoogleFonts.cairo()),
// //                 const SizedBox(height: 8),
// //               ],
// //               const SizedBox(height: 16),
// //               TextField(
// //                 controller: reasonController,
// //                 decoration: InputDecoration(
// //                   labelText: 'سبب الحظر',
// //                   labelStyle: GoogleFonts.cairo(),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   hintText: 'اكتب سبب الحظر هنا...',
// //                 ),
// //                 style: GoogleFonts.cairo(),
// //                 maxLines: 3,
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text('إلغاء', style: GoogleFonts.cairo()),
// //             ),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 if (reasonController.text.trim().isEmpty) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text('الرجاء إدخال سبب الحظر'),
// //                       backgroundColor: Colors.orange,
// //                     ),
// //                   );
// //                   return;
// //                 }
// //
// //                 try {
// //                   // Check if already blocked
// //                   final isAlreadyBlocked = await _checkIfBlocked(ip);
// //                   if (isAlreadyBlocked) {
// //                     Navigator.pop(context);
// //                     return;
// //                   }
// //
// //                   // Create blocked user
// //                   final blockedUser = BlockedUser(
// //                     id: '',
// //                     ip: ip,
// //                     userAgent: userAgent,
// //                     reason: reasonController.text.trim(),
// //                     blockedAt: DateTime.now(),
// //                     blockedBy: ref.read(authProvider).user?.email ?? 'Admin',
// //                     userEmail: email,
// //                   );
// //
// //                   // Save to Firestore
// //                   await FirebaseFirestore.instance
// //                       .collection('blockedUsers')
// //                       .add(blockedUser.toMap());
// //
// //                   Navigator.pop(context);
// //
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text('تم حظر المستخدم بنجاح'),
// //                       backgroundColor: Colors.green,
// //                     ),
// //                   );
// //                 } catch (e) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text('حدث خطأ: $e'),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   );
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //               ),
// //               child: Text('حظر', style: GoogleFonts.cairo()),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// // Add this method to show the block dialog
//   void _showBlockDialog(
//     BuildContext context,
//     WidgetRef ref,
//     String ip,
//     String userAgent,
//     String location,
//   ) {
//     final reasonController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'حظر المستخدم',
//             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (ip.isNotEmpty) ...[
//                 Text('عنوان IP:',
//                     style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
//                 Text(ip, style: GoogleFonts.cairo()),
//                 const SizedBox(height: 8),
//               ],
//               if (location.isNotEmpty) ...[
//                 Text('الموقع:',
//                     style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
//                 Text(location, style: GoogleFonts.cairo()),
//                 const SizedBox(height: 8),
//               ],
//               const SizedBox(height: 16),
//               TextField(
//                 controller: reasonController,
//                 decoration: InputDecoration(
//                   labelText: 'سبب الحظر',
//                   labelStyle: GoogleFonts.cairo(),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   hintText: 'اكتب سبب الحظر هنا...',
//                 ),
//                 style: GoogleFonts.cairo(),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء', style: GoogleFonts.cairo()),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (reasonController.text.trim().isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('الرجاء إدخال سبب الحظر'),
//                       backgroundColor: Colors.orange,
//                     ),
//                   );
//                   return;
//                 }
//
//                 try {
//                   // Create blocked user entry
//                   final blockedUser = {
//                     'ip': ip,
//                     'userAgent': userAgent,
//                     'reason': reasonController.text.trim(),
//                     'blockedAt': Timestamp.now(),
//                     'blockedBy': ref.read(authProvider).user?.email ?? 'Admin',
//                     'location': location,
//                   };
//
//                   // Add to Firestore
//                   await FirebaseFirestore.instance
//                       .collection('blockedUsers')
//                       .add(blockedUser);
//
//                   Navigator.pop(context);
//
//                   // Show success message
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('تم حظر المستخدم بنجاح'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//
//                   // Refresh any relevant providers (optional)
//                   if (ref.exists(blockedUsersProvider)) {
//                     ref.refresh(blockedUsersProvider);
//                   }
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('حدث خطأ: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: Text('حظر', style: GoogleFonts.cairo()),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// // Provider for the blocked users
// final blockedUsersProvider =
//     FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
//   final isAdmin = ref.watch(isAdminProvider);
//
//   if (!isAdmin) {
//     return [];
//   }
//
//   try {
//     final snapshot = await FirebaseFirestore.instance
//         .collection('blockedUsers')
//         .orderBy('blockedAt', descending: true)
//         .get();
//
//     return snapshot.docs.map((doc) {
//       final data = doc.data();
//       data['id'] = doc.id;
//       return data;
//     }).toList();
//   } catch (e) {
//     debugPrint('Error loading blocked users: $e');
//     return [];
//   }
// });
//
// class BlockedUsersScreen extends ConsumerWidget {
//   const BlockedUsersScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get screen size
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 600;
//
//     // Watch the blocked users provider
//     final blockedUsersAsync = ref.watch(blockedUsersProvider);
//     final isAdmin = ref.watch(isAdminProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('المستخدمون المحظورون', style: GoogleFonts.cairo()),
//         actions: [
//           if (isAdmin)
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () => ref.refresh(blockedUsersProvider),
//               tooltip: 'تحديث البيانات',
//             ),
//         ],
//       ),
//       body: !isAdmin
//           ? _buildAccessDeniedMessage(context, isSmallScreen)
//           : blockedUsersAsync.when(
//               data: (blockedUsers) => _buildBlockedUsersContent(
//                 context,
//                 blockedUsers,
//                 isSmallScreen,
//                 ref,
//               ),
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (error, stack) => Center(
//                 child: Text(
//                   'حدث خطأ: $error',
//                   style: GoogleFonts.cairo(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//     );
//   }
//
//   Widget _buildAccessDeniedMessage(BuildContext context, bool isSmallScreen) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.lock,
//               size: isSmallScreen ? 60 : 80,
//               color: Colors.red.shade300,
//             ),
//             SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//             Text(
//               'عذراً، هذه الصفحة للمشرفين فقط',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 20 : 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red.shade700,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.arrow_back),
//               label: Text('العودة', style: GoogleFonts.cairo()),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 24 : 32,
//                     vertical: isSmallScreen ? 10 : 12),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBlockedUsersContent(
//     BuildContext context,
//     List<Map<String, dynamic>> blockedUsers,
//     bool isSmallScreen,
//     WidgetRef ref,
//   ) {
//     // For very small screens, we'll show a more mobile-friendly list view instead of a table
//     final useListView = MediaQuery.of(context).size.width < 480;
//
//     if (blockedUsers.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.block_flipped,
//               size: isSmallScreen ? 60 : 80,
//               color: Colors.grey.shade400,
//             ),
//             SizedBox(height: isSmallScreen ? 16.0 : 24.0),
//             Text(
//               'لا يوجد مستخدمون محظورون',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 18 : 22,
//                 color: Colors.grey.shade700,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: isSmallScreen ? 8.0 : 12.0),
//             Text(
//               'عندما تقوم بحظر مستخدمين، سيظهرون هنا',
//               style: GoogleFonts.cairo(
//                 fontSize: isSmallScreen ? 14 : 16,
//                 color: Colors.grey.shade600,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () async => ref.refresh(blockedUsersProvider),
//       child: Padding(
//         padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline,
//                       color: Colors.blue.shade700, size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'العدد الإجمالي للمستخدمين المحظورين: ${blockedUsers.length}',
//                       style: GoogleFonts.cairo(
//                         fontSize: isSmallScreen ? 14 : 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: useListView
//                   ? _buildBlockedUsersList(
//                       blockedUsers, isSmallScreen, ref, context)
//                   : _buildBlockedUsersTable(
//                       blockedUsers, isSmallScreen, ref, context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBlockedUsersList(List<Map<String, dynamic>> blockedUsers,
//       bool isSmallScreen, WidgetRef ref, context) {
//     return ListView.separated(
//       itemCount: blockedUsers.length,
//       separatorBuilder: (context, index) => const Divider(),
//       itemBuilder: (context, index) {
//         final user = blockedUsers[index];
//
//         // Format timestamp
//         String formattedDate = 'غير معروف';
//         if (user.containsKey('blockedAt')) {
//           final timestamp = (user['blockedAt'] as Timestamp).toDate();
//           formattedDate =
//               '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//         }
//
//         return ListTile(
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.laptop, size: 18, color: Colors.grey.shade700),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       user['ip'] ?? 'غير معروف',
//                       style: GoogleFonts.cairo(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               if (user.containsKey('location') && user['location'] != null) ...[
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.location_on,
//                         size: 18, color: Colors.red.shade400),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         user['location'],
//                         style: GoogleFonts.cairo(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.report_problem,
//                       size: 18, color: Colors.amber.shade700),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'السبب: ${user['reason'] ?? 'غير محدد'}',
//                       style: GoogleFonts.cairo(fontSize: 13),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.access_time,
//                       size: 16, color: Colors.grey.shade600),
//                   const SizedBox(width: 6),
//                   Text(
//                     formattedDate,
//                     style: GoogleFonts.cairo(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     'بواسطة: ${user['blockedBy'] ?? 'Admin'}',
//                     style: GoogleFonts.cairo(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           trailing: IconButton(
//             icon: const Icon(Icons.delete_forever, color: Colors.red),
//             onPressed: () => _showUnblockDialog(context, user['id'], ref),
//             tooltip: 'إلغاء الحظر',
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildBlockedUsersTable(List<Map<String, dynamic>> blockedUsers,
//       bool isSmallScreen, WidgetRef ref, context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: SingleChildScrollView(
//         child: DataTable(
//           columnSpacing: isSmallScreen ? 16 : 24,
//           dataRowMinHeight: isSmallScreen ? 48 : 56,
//           dataRowMaxHeight: isSmallScreen ? 64 : 72,
//           columns: [
//             DataColumn(
//               label: Text(
//                 'عنوان IP',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//             DataColumn(
//               label: Text(
//                 'الموقع',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//             DataColumn(
//               label: Text(
//                 'سبب الحظر',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//             DataColumn(
//               label: Text(
//                 'تاريخ الحظر',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//             DataColumn(
//               label: Text(
//                 'بواسطة',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//             DataColumn(
//               label: Text(
//                 'إجراءات',
//                 style: GoogleFonts.cairo(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isSmallScreen ? 12 : 14,
//                 ),
//               ),
//             ),
//           ],
//           rows: blockedUsers.map((user) {
//             // Format timestamp
//             String formattedDate = 'غير معروف';
//             if (user.containsKey('blockedAt')) {
//               final timestamp = (user['blockedAt'] as Timestamp).toDate();
//               formattedDate =
//                   '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
//             }
//
//             return DataRow(
//               cells: [
//                 DataCell(Text(user['ip'] ?? 'غير معروف',
//                     style:
//                         GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//                 DataCell(Text(user['location'] ?? 'غير معروف',
//                     style:
//                         GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//                 DataCell(
//                   Tooltip(
//                     message: user['reason'] ?? 'غير محدد',
//                     child: Text(
//                       user['reason'] ?? 'غير محدد',
//                       style:
//                           GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13),
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 2,
//                     ),
//                   ),
//                 ),
//                 DataCell(Text(formattedDate,
//                     style:
//                         GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//                 DataCell(Text(user['blockedBy'] ?? 'Admin',
//                     style:
//                         GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
//                 DataCell(
//                   IconButton(
//                     icon: const Icon(Icons.delete_forever,
//                         color: Colors.red, size: 20),
//                     tooltip: 'إلغاء الحظر',
//                     onPressed: () =>
//                         _showUnblockDialog(context, user['id'], ref),
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   void _showUnblockDialog(BuildContext context, String id, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             'إلغاء الحظر',
//             style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
//           ),
//           content: Text(
//             'هل أنت متأكد من أنك تريد إلغاء حظر هذا المستخدم؟',
//             style: GoogleFonts.cairo(),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء', style: GoogleFonts.cairo()),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   // Delete from Firestore
//                   await FirebaseFirestore.instance
//                       .collection('blockedUsers')
//                       .doc(id)
//                       .delete();
//
//                   Navigator.pop(context);
//
//                   // Show success message
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('تم إلغاء الحظر بنجاح'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//
//                   // Refresh the list
//                   ref.refresh(blockedUsersProvider);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('حدث خطأ: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//               ),
//               child: Text('تأكيد', style: GoogleFonts.cairo()),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:trustedtallentsvalley/services/auth_service.dart';
import 'package:trustedtallentsvalley/services/visitor_analytics_service.dart';

import 'BlockedUsersScreen.dart';
import 'EnhancedVisitorDetails.dart';

// Define a model for visitor info to make handling data easier
class VisitorInfo {
  final String id;
  final String ipAddress;
  final String country;
  final String city;
  final String region;
  final DateTime timestamp;
  final String userAgent;
  final Map<String, dynamic> additionalData;

  VisitorInfo({
    required this.id,
    required this.ipAddress,
    required this.country,
    required this.city,
    required this.region,
    required this.timestamp,
    required this.userAgent,
    this.additionalData = const {},
  });

  factory VisitorInfo.fromMap(Map<String, dynamic> data, String id) {
    return VisitorInfo(
      id: id,
      ipAddress: data['ipAddress'] ?? 'غير معروف',
      country: data['country'] ?? 'غير معروف',
      city: data['city'] ?? 'غير معروف',
      region: data['region'] ?? 'غير معروف',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      userAgent: data['userAgent'] ?? 'غير معروف',
      additionalData: Map<String, dynamic>.from(data),
    );
  }
}

// State providers for the admin dashboard
final analyticsDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final chartDataProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
final visitorLocationsProvider = StateProvider<List<VisitorInfo>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => true);
final analyticsServiceProvider = Provider((ref) => VisitorAnalyticsService());

// Provider for filtering and searching
final visitorFilterProvider = StateProvider<String>((ref) => '');
final visitorSearchProvider = StateProvider<String>((ref) => '');

// Add additional providers for visitor details
final selectedVisitorProvider = StateProvider<VisitorInfo?>((ref) => null);
final visitorDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, visitorId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .get();

    if (!doc.exists) {
      return {'error': 'Visitor not found'};
    }

    return doc.data() as Map<String, dynamic>;
  } catch (e) {
    debugPrint('Error fetching visitor details: $e');
    return {'error': e.toString()};
  }
});

// Use StateNotifierProvider for better state management
final analyticsStateProvider =
    StateNotifierProvider<AnalyticsStateNotifier, AsyncValue<void>>((ref) {
  return AnalyticsStateNotifier(ref);
});

// Notifier to manage loading analytics data
class AnalyticsStateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AnalyticsStateNotifier(this._ref) : super(const AsyncValue.loading()) {
    // Initialize by loading data if admin
    if (_ref.read(isAdminProvider)) {
      loadData();
    } else {
      _ref.read(isLoadingProvider.notifier).state = false;
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadData() async {
    try {
      // Set loading state
      state = const AsyncValue.loading();
      _ref.read(isLoadingProvider.notifier).state = true;

      final isAdmin = _ref.read(isAdminProvider);
      if (!isAdmin) {
        _ref.read(isLoadingProvider.notifier).state = false;
        state = const AsyncValue.data(null);
        return;
      }

      final analyticsService = _ref.read(analyticsServiceProvider);

      // Get all the data
      final stats = await analyticsService.getVisitorStats();
      final chartData = await analyticsService.getVisitorChartData();
      final locationDataRaw = await analyticsService.getVisitorLocationData();

      // Convert raw location data to VisitorInfo objects
      final locationData = locationDataRaw.asMap().entries.map((entry) {
        return VisitorInfo.fromMap(entry.value, 'visitor-${entry.key}');
      }).toList();

      // Now we can safely update the providers
      _ref.read(analyticsDataProvider.notifier).state = stats;
      _ref.read(chartDataProvider.notifier).state = chartData;
      _ref.read(visitorLocationsProvider.notifier).state = locationData;

      // Update our state to success
      state = const AsyncValue.data(null);
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  // Call this method to refresh data
  void refresh() {
    loadData();
  }
}

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all state providers
    final isAdmin = ref.watch(isAdminProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final analyticsData = ref.watch(analyticsDataProvider);
    final chartData = ref.watch(chartDataProvider);
    final visitorLocations = ref.watch(visitorLocationsProvider);
    final visitorFilter = ref.watch(visitorFilterProvider);
    final visitorSearch = ref.watch(visitorSearchProvider);

    // Watch analytics state to trigger data loading
    final analyticsState = ref.watch(analyticsStateProvider);

    // Get screen size info
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم', style: GoogleFonts.cairo()),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () => _navigateToBlockedUsers(context),
              tooltip: 'المستخدمون المحظورون',
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(analyticsStateProvider.notifier).refresh(),
              tooltip: 'تحديث البيانات',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isAdmin
              ? _buildAccessDeniedMessage(context)
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(analyticsStateProvider.notifier).refresh(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12.0 : 16.0,
                        vertical: isSmallScreen ? 12.0 : 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(isSmallScreen, context),
                          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                          _buildAnalyticsCards(
                              analyticsData, isSmallScreen, context),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorChart(chartData, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorMap(visitorLocations, isSmallScreen),
                          SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                          _buildVisitorFilters(context, isSmallScreen, ref),
                          SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                          _buildVisitorTable(visitorLocations, isSmallScreen,
                              context, ref, visitorFilter, visitorSearch),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildAccessDeniedMessage(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: isSmallScreen ? 60 : 80,
              color: Colors.red.shade300,
            ),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            Text(
              'عذراً، هذه الصفحة للمشرفين فقط',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 12.0 : 16.0),
            Text(
              'لا تملك الصلاحيات الكافية للوصول إلى لوحة التحكم. يرجى التواصل مع المسؤول إذا كنت تعتقد أن هذا خطأ.',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallScreen ? 16.0 : 24.0),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text('العودة', style: GoogleFonts.cairo()),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 10 : 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen, BuildContext context) {
    return Row(
      children: [
        Icon(Icons.admin_panel_settings,
            size: isSmallScreen ? 24 : 28, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'إحصائيات الموقع',
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.block),
          label: Text('إدارة المحظورين', style: GoogleFonts.cairo()),
          onPressed: () => _navigateToBlockedUsers(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(Map<String, dynamic> analyticsData,
      bool isSmallScreen, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid columns based on screen size
    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 3; // Large screens - 3 cards in a row
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Medium screens - 2 cards in a row
    } else {
      crossAxisCount = 2; // Small screens - 1 card per row
    }

    return Padding(
      padding: EdgeInsets.all(
          isSmallScreen ? 8.0 : 12.0), // Add padding around the grid
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
        mainAxisSpacing: isSmallScreen ? 6 : 10, // Reduced spacing
        childAspectRatio:
            isSmallScreen ? 1.8 : 2.0, // Increased ratio makes items shorter
        children: [
          _buildAnalyticItem(
            analyticsData['todayVisitors']?.toString() ?? '0',
            'زيارة اليوم',
            Icons.trending_up,
            Colors.green,
            '${analyticsData['percentChange']?.toStringAsFixed(1) ?? '0'}% عن أمس',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['totalVisitors']?.toString() ?? '0',
            'إجمالي الزيارات',
            Icons.people,
            Colors.blue,
            '${analyticsData['monthlyVisitors'] ?? '0'} زيارة هذا الشهر',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['avgSessionDuration'] ?? '0:00',
            'متوسط مدة الزيارة',
            Icons.timer,
            Colors.orange,
            'تحديث لحظي',
            isSmallScreen: isSmallScreen,
          ),
          // Add more analytics items
          _buildAnalyticItem(
            analyticsData['uniqueVisitors']?.toString() ?? '0',
            'زوار فريدون',
            Icons.person_outline,
            Colors.purple,
            'آخر 30 يوماً',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['bounceRate']?.toString() ?? '0%',
            'معدل الارتداد',
            Icons.exit_to_app,
            Colors.red,
            'تحديث لحظي',
            isSmallScreen: isSmallScreen,
          ),
          _buildAnalyticItem(
            analyticsData['mostVisitedPage'] ?? 'الرئيسية',
            'الصفحة الأكثر زيارة',
            Icons.insert_chart,
            Colors.teal,
            '${analyticsData['mostVisitedPageCount'] ?? '0'} زيارة',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  // Modified _buildAnalyticItem to support responsive sizing
  Widget _buildAnalyticItem(
    String value,
    String title,
    IconData icon,
    Color color,
    String subtitle, {
    required bool isSmallScreen,
  }) {
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
                Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
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
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorChart(
      List<Map<String, dynamic>> chartData, bool isSmallScreen) {
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
                Icon(Icons.insert_chart,
                    color: Colors.purple.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الزيارات خلال آخر 7 أيام',
                    style: GoogleFonts.cairo(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            SizedBox(
              height: isSmallScreen ? 200 : 250,
              child: chartData.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد بيانات متاحة',
                        style: GoogleFonts.cairo(),
                      ),
                    )
                  : _buildBarChart(chartData, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
      List<Map<String, dynamic>> chartData, bool isSmallScreen) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${chartData[groupIndex]['visits']} زائر',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      chartData[value.toInt()]['day'],
                      style:
                          GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 10 : 12),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade300,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: (data['visits'] as num).toDouble(),
                color: Colors.blue.shade400,
                width: isSmallScreen ? 15 : 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisitorMap(
      List<VisitorInfo> visitorLocations, bool isSmallScreen) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Expandable section header
          ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.map,
                    color: Colors.green.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'خريطة الزوار',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            initiallyExpanded:
                !isSmallScreen, // Collapsed by default on small screens
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                child: SizedBox(
                  height: isSmallScreen ? 200 : 300,
                  child: visitorLocations.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد بيانات متاحة',
                            style: GoogleFonts.cairo(),
                          ),
                        )
                      : _buildMap(visitorLocations),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<VisitorInfo> visitorLocations) {
    final markers = visitorLocations
        .map((location) {
          final latitude = location.additionalData['latitude'] as num?;
          final longitude = location.additionalData['longitude'] as num?;

          if (latitude == null || longitude == null) {
            return null;
          }

          return Marker(
            width: 30.0,
            height: 30.0,
            point: LatLng(
              latitude.toDouble(),
              longitude.toDouble(),
            ),
            child: const Icon(
              Icons.location_pin,
              color: Colors.red,
              size: 24,
            ),
          );
        })
        .whereType<Marker>()
        .toList(); // Filter out null markers

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(25.0, 10.0),
        initialZoom: 2.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  // Add filtering options for visitors
  Widget _buildVisitorFilters(
      BuildContext context, bool isSmallScreen, WidgetRef ref) {
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
                Icon(Icons.filter_list,
                    color: Colors.indigo.shade700,
                    size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'تصفية وبحث',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث عن زائر (IP، بلد، مدينة)...',
                      hintStyle: GoogleFonts.cairo(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.cairo(),
                    onChanged: (value) =>
                        ref.read(visitorSearchProvider.notifier).state = value,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'تصفية حسب',
                      labelStyle: GoogleFonts.cairo(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: GoogleFonts.cairo(),
                    value: ref.read(visitorFilterProvider),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text('الكل', style: GoogleFonts.cairo()),
                      ),
                      DropdownMenuItem(
                        value: 'today',
                        child: Text('اليوم', style: GoogleFonts.cairo()),
                      ),
                      DropdownMenuItem(
                        value: 'week',
                        child: Text('هذا الأسبوع', style: GoogleFonts.cairo()),
                      ),
                      DropdownMenuItem(
                        value: 'desktop',
                        child:
                            Text('أجهزة الكمبيوتر', style: GoogleFonts.cairo()),
                      ),
                      DropdownMenuItem(
                        value: 'mobile',
                        child: Text('الأجهزة المحمولة',
                            style: GoogleFonts.cairo()),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(visitorFilterProvider.notifier).state = value;
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorTable(
      List<VisitorInfo> visitorLocations,
      bool isSmallScreen,
      BuildContext context,
      WidgetRef ref,
      String filter,
      String search) {
    // Filter visitors based on filter and search criteria
    final filteredVisitors = visitorLocations.where((visitor) {
      // Apply search filter
      if (search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        return visitor.ipAddress.toLowerCase().contains(searchLower) ||
            visitor.country.toLowerCase().contains(searchLower) ||
            visitor.city.toLowerCase().contains(searchLower) ||
            visitor.region.toLowerCase().contains(searchLower);
      }

      // Apply category filter
      if (filter.isEmpty) {
        return true;
      } else if (filter == 'today') {
        final now = DateTime.now();
        return visitor.timestamp.day == now.day &&
            visitor.timestamp.month == now.month &&
            visitor.timestamp.year == now.year;
      } else if (filter == 'week') {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return visitor.timestamp.isAfter(weekAgo);
      } else if (filter == 'desktop') {
        return !visitor.userAgent.toLowerCase().contains('mobile');
      } else if (filter == 'mobile') {
        return visitor.userAgent.toLowerCase().contains('mobile');
      }

      return true;
    }).toList();

    // For very small screens, we'll show a more mobile-friendly list view instead of a table
    final useListView = MediaQuery.of(context).size.width < 480;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Expandable section header
          ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.list_alt,
                    color: Colors.blue.shade700, size: isSmallScreen ? 20 : 24),
                const SizedBox(width: 8),
                Text(
                  'بيانات الزوار',
                  style: GoogleFonts.cairo(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              'عدد الزوار: ${filteredVisitors.length}',
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey.shade700,
              ),
            ),
            initiallyExpanded:
                !isSmallScreen, // Collapsed by default on small screens
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
                child: useListView
                    ? _buildVisitorListView(
                        filteredVisitors, isSmallScreen, context, ref)
                    : _buildVisitorTableView(
                        filteredVisitors, isSmallScreen, context, ref),
              ),
              if (filteredVisitors.length > 20)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      'يتم عرض أحدث 20 زائر من إجمالي ${filteredVisitors.length}',
                      style: GoogleFonts.cairo(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorTableView(List<VisitorInfo> visitorLocations,
      bool isSmallScreen, BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: isSmallScreen ? 16 : 24,
        dataRowMinHeight: isSmallScreen ? 48 : 56,
        dataRowMaxHeight: isSmallScreen ? 64 : 72,
        columns: [
          DataColumn(
            label: Text(
              'التاريخ',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'عنوان IP',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'البلد',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'المدينة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'الجهاز',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'إجراءات',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ],
        rows: visitorLocations.take(20).map((visitor) {
          // Format timestamp
          final formatter = DateFormat('dd/MM/yyyy HH:mm');
          final formattedDate = formatter.format(visitor.timestamp);

          // Determine device type (simple logic)
          String deviceType = 'غير معروف';
          if (visitor.userAgent.toLowerCase().contains('mobile')) {
            deviceType = 'جوال';
          } else if (visitor.userAgent.toLowerCase().contains('tablet')) {
            deviceType = 'لوحي';
          } else {
            deviceType = 'كمبيوتر';
          }

          return DataRow(
            cells: [
              DataCell(Text(formattedDate,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(visitor.ipAddress,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(visitor.country,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(visitor.city,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(Text(deviceType,
                  style: GoogleFonts.cairo(fontSize: isSmallScreen ? 11 : 13))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: Colors.blue, size: 20),
                      tooltip: 'عرض التفاصيل',
                      onPressed: () {
                        _navigateToVisitorDetails(context, visitor);
                      },
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.block, color: Colors.red, size: 20),
                      tooltip: 'حظر هذا المستخدم',
                      onPressed: () {
                        _showBlockDialog(
                          context,
                          ref,
                          visitor.ipAddress,
                          visitor.userAgent,
                          '${visitor.country}, ${visitor.city}',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // List view for mobile screens with enhanced information
  Widget _buildVisitorListView(List<VisitorInfo> visitorLocations,
      bool isSmallScreen, BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visitorLocations.length > 20 ? 20 : visitorLocations.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final visitor = visitorLocations[index];

        // Format timestamp
        final formatter = DateFormat('dd/MM/yyyy HH:mm');
        final formattedDate = formatter.format(visitor.timestamp);

        // Determine device type
        String deviceType = 'غير معروف';
        IconData deviceIcon = Icons.devices;

        if (visitor.userAgent.toLowerCase().contains('iphone')) {
          deviceType = 'iPhone';
          deviceIcon = Icons.phone_iphone;
        } else if (visitor.userAgent.toLowerCase().contains('android')) {
          deviceType = 'Android';
          deviceIcon = Icons.phone_android;
        } else if (visitor.userAgent.toLowerCase().contains('mobile')) {
          deviceType = 'جوال';
          deviceIcon = Icons.smartphone;
        } else if (visitor.userAgent.toLowerCase().contains('tablet')) {
          deviceType = 'لوحي';
          deviceIcon = Icons.tablet_mac;
        } else if (visitor.userAgent.toLowerCase().contains('windows')) {
          deviceType = 'Windows';
          deviceIcon = Icons.laptop_windows;
        } else if (visitor.userAgent.toLowerCase().contains('mac')) {
          deviceType = 'Mac';
          deviceIcon = Icons.laptop_mac;
        } else {
          deviceType = 'كمبيوتر';
          deviceIcon = Icons.computer;
        }

        // Determine browser
        String browser = 'غير معروف';
        IconData browserIcon = Icons.public;

        if (visitor.userAgent.toLowerCase().contains('chrome')) {
          browser = 'Chrome';
          browserIcon = Icons.web;
        } else if (visitor.userAgent.toLowerCase().contains('firefox')) {
          browser = 'Firefox';
          browserIcon = Icons.web;
        } else if (visitor.userAgent.toLowerCase().contains('safari')) {
          browser = 'Safari';
          browserIcon = Icons.web;
        } else if (visitor.userAgent.toLowerCase().contains('edge')) {
          browser = 'Edge';
          browserIcon = Icons.web;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () => _navigateToVisitorDetails(context, visitor),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.red.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${visitor.country}, ${visitor.city}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(deviceIcon,
                                size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              deviceType,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.router,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        visitor.ipAddress,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        browserIcon,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        browser,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.grey.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.info_outline,
                            color: Colors.blue, size: 20),
                        tooltip: 'عرض التفاصيل',
                        onPressed: () {
                          _navigateToVisitorDetails(context, visitor);
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.block,
                            color: Colors.red, size: 20),
                        tooltip: 'حظر هذا المستخدم',
                        onPressed: () {
                          _showBlockDialog(
                            context,
                            ref,
                            visitor.ipAddress,
                            visitor.userAgent,
                            '${visitor.country}, ${visitor.city}',
                          );
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Enhanced security info row with copy and block options
  Widget _buildSecurityInfoRow(
    String label,
    String value, {
    VoidCallback? onCopy,
    VoidCallback? onBlock,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: onCopy,
              tooltip: 'نسخ',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (onBlock != null)
            IconButton(
              icon: const Icon(Icons.block, size: 16, color: Colors.red),
              onPressed: onBlock,
              tooltip: 'حظر',
              padding: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  // Copy to clipboard helper
  void _copyToClipboard(String text, context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النسخ', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show block dialog and add to blocked users
  void _showBlockDialog(
    BuildContext context,
    WidgetRef ref,
    String ip,
    String userAgent,
    String location,
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
              if (location.isNotEmpty) ...[
                Text('الموقع:',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                Text(location, style: GoogleFonts.cairo()),
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
                    SnackBar(
                      content: Text('الرجاء إدخال سبب الحظر',
                          style: GoogleFonts.cairo()),
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

                  final isBlocked = snapshot.docs.isNotEmpty;

                  if (isBlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('هذا المستخدم محظور بالفعل',
                            style: GoogleFonts.cairo()),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    Navigator.pop(context);
                    return;
                  }

                  // Create blocked user entry
                  final blockedUser = {
                    'ip': ip,
                    'userAgent': userAgent,
                    'reason': reasonController.text.trim(),
                    'blockedAt': Timestamp.now(),
                    'blockedBy': ref.read(authProvider).user?.email ?? 'Admin',
                    'location': location,
                  };

                  // Add to Firestore
                  await FirebaseFirestore.instance
                      .collection('blockedUsers')
                      .add(blockedUser);

                  Navigator.pop(context);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حظر المستخدم بنجاح',
                          style: GoogleFonts.cairo()),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh analytics data
                  ref.read(analyticsStateProvider.notifier).refresh();

                  // Refresh blocked users list if provider exists
                  if (ref.exists(blockedUsersProvider)) {
                    ref.refresh(blockedUsersProvider);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: $e', style: GoogleFonts.cairo()),
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

  // Navigate to blocked users screen
  void _navigateToBlockedUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BlockedUsersScreen2(),
      ),
    );
  }

  // Navigate to visitor details screen
  void _navigateToVisitorDetails(BuildContext context, VisitorInfo visitor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedVisitorDetails(
          visitorId: visitor.id,
          visitorIp: visitor.ipAddress,
        ),
      ),
    );
  }
}
