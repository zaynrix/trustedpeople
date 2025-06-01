import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/stats/stat_item.dart';

class StatsColumn extends StatelessWidget {
  const StatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatItem(value: '70+', label: 'موثوق'),
        SizedBox(height: 16),
        StatItem(value: '100+', label: 'نصاب'),
        SizedBox(height: 16),
        StatItem(value: '8000+', label: 'مستخدم'),
        SizedBox(height: 16),
        StatItem(value: '90%', label: 'معدل الرضا'),
      ],
    );
  }
}
