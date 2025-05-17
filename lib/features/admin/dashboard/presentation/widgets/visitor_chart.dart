import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/dashboard_stats.dart';

class VisitorChart extends StatelessWidget {
  final List<ChartDataPoint> chartData;
  final bool isSmallScreen;

  const VisitorChart({
    Key? key,
    required this.chartData,
    this.isSmallScreen = false,
  }) : super(key: key);

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
      series: [
        ColumnSeries<ChartDataPoint, String>(
          dataSource: chartData,
          xValueMapper: (ChartDataPoint data, _) => data.day,
          yValueMapper: (ChartDataPoint data, _) => data.visits,
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade600],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10),
          ),
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }
}
