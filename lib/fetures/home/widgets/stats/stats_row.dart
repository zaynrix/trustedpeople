
import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/fetures/Home/widgets/stats/stat_item.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatItem(value: '250+', label: 'موثوق'),
        StatItem(value: '100+', label: 'نصاب'),
        StatItem(value: '1000+', label: 'مستخدم'),
        StatItem(value: '90%', label: 'معدل الرضا'),
      ],
    );
  }
}