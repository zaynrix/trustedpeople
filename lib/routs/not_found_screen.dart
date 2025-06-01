import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Modern404Screen extends StatefulWidget {
  final String? attemptedPath;

  const Modern404Screen({
    Key? key,
    this.attemptedPath,
  }) : super(key: key);

  @override
  State<Modern404Screen> createState() => _Modern404ScreenState();
}

class _Modern404ScreenState extends State<Modern404Screen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                // min-height: screenSize.height - 100,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24.0 : 48.0,
                  vertical: 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated 404 Icon/Illustration
                    _buildAnimatedIcon(isDark, isTablet),

                    SizedBox(height: isTablet ? 48 : 32),

                    // Main heading
                    _buildMainHeading(theme, isTablet),

                    SizedBox(height: isTablet ? 24 : 16),

                    // Subtitle
                    _buildSubtitle(theme, isTablet),

                    if (widget.attemptedPath != null) ...[
                      SizedBox(height: isTablet ? 20 : 16),
                      _buildAttemptedPath(theme, isTablet),
                    ],

                    SizedBox(height: isTablet ? 48 : 32),

                    // Action buttons
                    _buildActionButtons(context, theme, isTablet, isMobile),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Helpful links
                    _buildHelpfulLinks(context, theme, isTablet),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDark, bool isTablet) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: isTablet ? 200 : 150,
            height: isTablet ? 200 : 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                        const Color(0xFFEC4899),
                      ]
                    : [
                        const Color(0xFF3B82F6),
                        const Color(0xFF8B5CF6),
                        const Color(0xFFEC4899),
                      ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color:
                      (isDark ? Colors.purple : Colors.blue).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '404',
                style: TextStyle(
                  fontSize: isTablet ? 64 : 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainHeading(ThemeData theme, bool isTablet) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            'Oops! Page Not Found',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: isTablet ? 42 : 32,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onBackground,
              letterSpacing: -1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle(ThemeData theme, bool isTablet) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            'The page you\'re looking for doesn\'t exist or has been moved.\nLet\'s get you back on track!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isTablet ? 18 : 16,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              height: 1.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttemptedPath(ThemeData theme, bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: isTablet ? 20 : 18,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Attempted: ${widget.attemptedPath}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontFamily: 'monospace',
                fontSize: isTablet ? 14 : 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ThemeData theme, bool isTablet, bool isMobile) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              // Primary action - Go Home
              _buildPrimaryButton(
                context: context,
                theme: theme,
                isTablet: isTablet,
                onPressed: () => context.go('/'),
                icon: Icons.home_rounded,
                label: 'Go Home',
              ),

              // Secondary action - Go Back
              _buildSecondaryButton(
                context: context,
                theme: theme,
                isTablet: isTablet,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
                icon: Icons.arrow_back_rounded,
                label: 'Go Back',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required ThemeData theme,
    required bool isTablet,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isTablet ? 24 : 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 24,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required BuildContext context,
    required ThemeData theme,
    required bool isTablet,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: isTablet ? 24 : 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : 24,
          vertical: isTablet ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHelpfulLinks(
      BuildContext context, ThemeData theme, bool isTablet) {
    final links = [
      {'label': 'Home', 'path': '/', 'icon': Icons.home_outlined},
      {'label': 'Services', 'path': '/services', 'icon': Icons.build_outlined},
      {
        'label': 'Trusted Users',
        'path': '/trusted',
        'icon': Icons.verified_user_outlined
      },
      {
        'label': 'Contact',
        'path': '/contact-us',
        'icon': Icons.contact_support_outlined
      },
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Column(
            children: [
              Text(
                'Quick Navigation',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: links.map((link) {
                  return InkWell(
                    onTap: () => context.go(link['path'] as String),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            link['icon'] as IconData,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            link['label'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
