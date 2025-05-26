
import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/stats/stat_item.dart';

class StatsColumn extends StatelessWidget {
  const StatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatItem(value: '250+', label: 'موثوق'),
        SizedBox(height: 16),
        StatItem(value: '100+', label: 'نصاب'),
        SizedBox(height: 16),
        StatItem(value: '1000+', label: 'مستخدم'),
        SizedBox(height: 16),
        StatItem(value: '90%', label: 'معدل الرضا'),
      ],
    );
  }
}