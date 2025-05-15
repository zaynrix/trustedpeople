// lib/widgets/admin_visitor_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

class AdminVisitorMap extends StatelessWidget {
  final List<Map<String, dynamic>> visitorLocations;

  const AdminVisitorMap({
    Key? key,
    required this.visitorLocations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8),
                Text(
                  'موقع الزوار (للمشرفين فقط)',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: _buildMap(),
            ),
            const SizedBox(height: 16),
            _buildVisitorTable(),
          ],
        ),
      ),
    );
  }

  // Widget _buildMap() {
  //   if (visitorLocations.isEmpty) {
  //     return Center(
  //       child: Text(
  //         'لا توجد بيانات زوار متاحة',
  //         style: GoogleFonts.cairo(color: Colors.grey.shade600),
  //       ),
  //     );
  //   }
  //
  //   // Extract coordinates for map markers
  //   final markers = visitorLocations.map((location) {
  //     return Marker(
  //       width: 30.0,
  //       height: 30.0,
  //       point: LatLng(
  //         location['latitude'] as double,
  //         location['longitude'] as double,
  //       ),
  //       builder: (ctx) => const Icon(
  //         Icons.location_pin,
  //         color: Colors.red,
  //         size: 30,
  //       ),
  //     );
  //   }).toList();
  //
  //   return FlutterMap(
  //     options: MapOptions(
  //       center: LatLng(25.0, 10.0), // Center on Middle East/North Africa
  //       zoom: 2.0,
  //     ),
  //     layers: [
  //       TileLayerOptions(
  //         urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
  //         subdomains: ['a', 'b', 'c'],
  //       ),
  //       MarkerLayerOptions(
  //         markers: markers,
  //       ),
  //     ],
  //   );
  // }
  Widget _buildMap() {
    if (visitorLocations.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات زوار متاحة',
          style: GoogleFonts.cairo(color: Colors.grey.shade600),
        ),
      );
    }

    // Extract coordinates for map markers
    final markers = visitorLocations.map((location) {
      return Marker(
        width: 30.0,
        height: 30.0,
        point: LatLng(
          location['latitude'] as double,
          location['longitude'] as double,
        ),
        // builder: (ctx) =>
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 30,
        ),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(25.0, 10.0), // Center on Middle East/North Africa
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

  Widget _buildVisitorTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أحدث الزوار (${visitorLocations.length})',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          height: 300,
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'التاريخ',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'IP',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'البلد',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'المدينة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: visitorLocations.map((location) {
                  // Format timestamp
                  String formattedDate = 'غير معروف';
                  if (location.containsKey('timestamp')) {
                    final timestamp = DateTime.parse(location['timestamp']);
                    formattedDate =
                        '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text(formattedDate, style: GoogleFonts.cairo())),
                      DataCell(Text(location['ipAddress'] ?? 'غير معروف',
                          style: GoogleFonts.cairo())),
                      DataCell(Text(location['country'] ?? 'غير معروف',
                          style: GoogleFonts.cairo())),
                      DataCell(Text(location['city'] ?? 'غير معروف',
                          style: GoogleFonts.cairo())),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
