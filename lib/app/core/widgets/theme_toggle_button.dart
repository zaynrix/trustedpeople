import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/theme_notifier.dart';
import '../theme/theme_providers.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({
    Key? key,
    this.lightIcon = Icons.light_mode,
    this.darkIcon = Icons.dark_mode,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  final IconData lightIcon;
  final IconData darkIcon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return IconButton(
      icon: Icon(
        isDarkMode ? lightIcon : darkIcon,
        color: color,
        size: size,
      ),
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}