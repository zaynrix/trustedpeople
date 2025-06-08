import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/core/widgets/app_drawer.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/mobile/mobile_fab.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/mobile/mobile_header.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/mobile/mobile_tip_card.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/protection_guide_app_bar.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/empty_state.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/error_state.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/shared/loading_state.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/web/web_header.dart';
import 'package:trustedtallentsvalley/fetures/home/protection_guide/widgets/web/web_tips_grid.dart';

import '../models/protection_tip.dart';
import '../providers/protection_tips_provider.dart';

class ProtectionGuideScreen extends ConsumerWidget {
  const ProtectionGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(protectionTipsProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final size = MediaQuery.of(context).size;

    // Define breakpoints
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      backgroundColor: isMobile ? Colors.grey.shade50 : Colors.white,
      appBar: buildAppBar(context, ref, isMobile, isAdmin),
      drawer: isMobile ? const AppDrawer() : null,
      floatingActionButton:
          isAdmin && isMobile ? buildModernFAB(context, ref) : null,
      body: isMobile
          ? _buildMobileLayout(context, ref, tipsAsync)
          : _buildWebLayout(context, ref, tipsAsync, isDesktop),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref,
      AsyncValue<List<ProtectionTip>> tipsAsync) {
    return tipsAsync.when(
      data: (tips) => _buildMobileContent(context, ref, tips),
      loading: () => buildModernLoadingState(),
      error: (error, stack) => buildErrorState(context, error),
    );
  }

  Widget _buildWebLayout(BuildContext context, WidgetRef ref,
      AsyncValue<List<ProtectionTip>> tipsAsync, bool isDesktop) {
    final maxWidth = isDesktop ? 1200.0 : 900.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: tipsAsync.when(
          data: (tips) => _buildWebContent(context, ref, tips, isDesktop),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildMobileContent(
      BuildContext context, WidgetRef ref, List<ProtectionTip> tips) {
    if (tips.isEmpty) {
      return buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        // Header section
        SliverToBoxAdapter(
          child: buildModernMobileHeader(tips.length),
        ),

        // Tips grid
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tip = tips[index];
                return buildModernMobileTipCard(context, ref, tip);
              },
              childCount: tips.length,
            ),
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildWebContent(BuildContext context, WidgetRef ref,
      List<ProtectionTip> tips, bool isDesktop) {
    if (tips.isEmpty) {
      return buildEmptyState();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWebHeader(context, ref, tips.length, isDesktop),
            const SizedBox(height: 48),
            buildWebTipsGrid(context, ref, tips, isDesktop),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
