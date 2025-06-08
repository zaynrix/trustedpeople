import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/config/app_constant.dart';
import 'package:trustedtallentsvalley/config/app_utils.dart';
import 'package:trustedtallentsvalley/fetures/admin/adminDStatistcs/widgets/dashboard_components.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/screens/BlockedUsersScreen.dart';

import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets.dart';

class AdminDashboardStatistics extends ConsumerStatefulWidget {
  const AdminDashboardStatistics({super.key});

  @override
  ConsumerState<AdminDashboardStatistics> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboardStatistics> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  void _initializeData() {
    final isAdmin = ref.read(isAdminProvider);
    if (isAdmin) {
      ref.read(analyticsStateProvider.notifier).loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final analyticsState = ref.watch(analyticsStateProvider);

    return Scaffold(
      appBar: _buildModernAppBar(context, theme, isAdmin),
      body: _buildBody(context, isAdmin, analyticsState),
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    BuildContext context,
    ThemeData theme,
    bool isAdmin,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      title: Row(
        children: [
          Icon(
            Icons.dashboard_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'لوحة الاحصائيات',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      actions: isAdmin ? _buildAppBarActions(context, theme) : null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.3),
                theme.colorScheme.primary.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, ThemeData theme) {
    return [
      ModernIconButton(
        icon: Icons.people_rounded,
        tooltip: 'المستخدمون المحظورون',
        onPressed: () => _navigateToBlockedUsers(context),
      ),
      const SizedBox(width: 8),
      const RefreshButton(),
      const SizedBox(width: 16),
    ];
  }

  Widget _buildBody(
      BuildContext context, bool isAdmin, AnalyticsState analyticsState) {
    if (analyticsState.isLoading) {
      return const LoadingWidget(message: 'جارٍ تحميل البيانات...');
    }

    if (!isAdmin) {
      return const AccessDeniedWidget();
    }

    if (analyticsState.hasError) {
      return ErrorRetryWidget(error: analyticsState.error!);
    }

    return _buildDashboardContent(context);
  }

  Widget _buildDashboardContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(analyticsStateProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: Breakpoints.getHorizontalPadding(context),
          vertical: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            SizedBox(height: Breakpoints.getCardSpacing(context)),
            const AnalyticsCards(),
            const SizedBox(height: 24),
            const VisitorChart(),
            const SizedBox(height: 24),
            const VisitorMap(),
            const SizedBox(height: 24),
            const VisitorFilters(),
            const SizedBox(height: 16),
            const VisitorTable(),
          ],
        ),
      ),
    );
  }

  void _navigateToBlockedUsers(BuildContext context) {
    Navigator.push(
      context,
      AnimationUtils.createSlideRoute(
        page: const BlockedUsersScreen2(),
      ),
    );
  }
}
