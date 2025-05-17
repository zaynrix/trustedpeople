import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';

class VisitorMap extends StatelessWidget {
  final List<VisitorLocation> locations;
  final bool isSmallScreen;

  const VisitorMap({
    Key? key,
    required this.locations,
    this.isSmallScreen = false,
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
                const Icon(Icons.location_on, color: Colors.redAccent),
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
              height: isSmallScreen ? 200 : 300,
              child: _buildMap(),
            ),
            const SizedBox(height: 16),
            _buildVisitorTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    // Implement your map building logic here
    return Center(child: Text('Map will be displayed here'));
  }

  Widget _buildVisitorTable() {
    // Implement your visitor table logic here
    return DataTable(
      columns: const [
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Visitors')),
      ],
      rows: locations.map((location) {
        return DataRow(
          cells: [
            DataCell(Text(location.city ?? 'Unknown')),
            DataCell(Text('${location.country ?? 0}')),
          ],
        );
      }).toList(),
    );
  }
}
