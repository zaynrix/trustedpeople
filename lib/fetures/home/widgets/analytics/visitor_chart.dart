import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class VisitorChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const VisitorChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      primaryYAxis: const NumericAxis(
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
      ),
      series: <CartesianSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: chartData,
          xValueMapper: (Map<String, dynamic> data, _) => data['day'] as String,
          yValueMapper: (Map<String, dynamic> data, _) => data['visits'] as int,
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade600],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: GoogleFonts.cairo(fontSize: 10),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}