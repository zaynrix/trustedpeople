import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';
import 'package:trustedtallentsvalley/fetures/services/visitor_analytics_service.dart';

import '../models/visitor_info.dart';

// ==================== Basic State Providers ====================
final analyticsDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final chartDataProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
final visitorLocationsProvider = StateProvider<List<VisitorInfo>>((ref) => []);
final isLoadingProvider = StateProvider<bool>((ref) => true);
final selectedVisitorProvider = StateProvider<VisitorInfo?>((ref) => null);

// ==================== Filter and Search Providers ====================
final visitorFilterProvider = StateProvider<String>((ref) => '');
final visitorSearchProvider = StateProvider<String>((ref) => '');
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);
final sortOptionProvider = StateProvider<String>((ref) => 'timestamp_desc');

// ==================== Service Providers ====================
final analyticsServiceProvider = Provider((ref) => VisitorAnalyticsService());

// ==================== Future Providers ====================
final visitorDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, visitorId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('visitors')
        .doc(visitorId)
        .get();

    if (!doc.exists) {
      return {'error': 'Visitor not found'};
    }

    return doc.data() as Map<String, dynamic>;
  } catch (e) {
    debugPrint('Error fetching visitor details: $e');
    return {'error': e.toString()};
  }
});

final blockedUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('blockedUsers')
        .orderBy('blockedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    debugPrint('Error fetching blocked users: $e');
    return [];
  }
});

// ==================== Main Analytics State Provider ====================
final analyticsStateProvider =
    StateNotifierProvider<AnalyticsStateNotifier, AnalyticsState>((ref) {
  return AnalyticsStateNotifier(ref);
});

// ==================== Analytics State ====================
class AnalyticsState {
  final bool isLoading;
  final String? error;
  final bool isInitialized;
  final DateTime? lastUpdated;

  const AnalyticsState({
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
    this.lastUpdated,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    bool? isInitialized,
    DateTime? lastUpdated,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isInitialized: isInitialized ?? this.isInitialized,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasError => error != null;
  bool get shouldRefresh {
    if (lastUpdated == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes > 5; // Refresh after 5 minutes
  }
}

// ==================== Analytics State Notifier ====================
class AnalyticsStateNotifier extends StateNotifier<AnalyticsState> {
  final Ref _ref;

  AnalyticsStateNotifier(this._ref) : super(const AnalyticsState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isAdmin = _ref.read(isAdminProvider);

    if (isAdmin) {
      await loadData();
    } else {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
      );
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> loadData({bool forceRefresh = false}) async {
    try {
      // Don't reload if recently loaded unless forced
      if (!forceRefresh && !state.shouldRefresh && state.isInitialized) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);
      _ref.read(isLoadingProvider.notifier).state = true;

      final isAdmin = _ref.read(isAdminProvider);
      if (!isAdmin) {
        state = state.copyWith(
          isLoading: false,
          isInitialized: true,
          error: 'غير مخول للوصول',
        );
        _ref.read(isLoadingProvider.notifier).state = false;
        return;
      }

      final analyticsService = _ref.read(analyticsServiceProvider);

      // Load all data concurrently for better performance
      final results = await Future.wait([
        analyticsService.getVisitorStats(),
        analyticsService.getVisitorChartData(),
        analyticsService.getVisitorLocationData(),
      ]);

      final stats = results[0] as Map<String, dynamic>;
      final chartData = results[1] as List<Map<String, dynamic>>;
      final locationDataRaw = results[2] as List<Map<String, dynamic>>;

      // Convert raw location data to VisitorInfo objects
      final locationData = locationDataRaw.asMap().entries.map((entry) {
        return VisitorInfo.fromMap(entry.value, 'visitor-${entry.key}');
      }).toList();

      // Update providers
      _ref.read(analyticsDataProvider.notifier).state = stats;
      _ref.read(chartDataProvider.notifier).state = chartData;
      _ref.read(visitorLocationsProvider.notifier).state = locationData;

      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialized: true,
      );
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void refresh() => loadData(forceRefresh: true);

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> retryLoad() async {
    if (state.hasError) {
      clearError();
      await loadData(forceRefresh: true);
    }
  }
}

// ==================== Filtered Visitors Provider ====================
final filteredVisitorsProvider = Provider<List<VisitorInfo>>((ref) {
  final visitors = ref.watch(visitorLocationsProvider);
  final filter = ref.watch(visitorFilterProvider);
  final search = ref.watch(visitorSearchProvider);
  final dateRange = ref.watch(dateRangeProvider);
  final sortOption = ref.watch(sortOptionProvider);

  List<VisitorInfo> filtered = List.from(visitors);

  // Apply search filter
  if (search.isNotEmpty) {
    final searchLower = search.toLowerCase();
    filtered = filtered.where((visitor) {
      return visitor.ipAddress.toLowerCase().contains(searchLower) ||
          visitor.country.toLowerCase().contains(searchLower) ||
          visitor.city.toLowerCase().contains(searchLower) ||
          visitor.region.toLowerCase().contains(searchLower);
    }).toList();
  }

  // Apply category filter
  if (filter.isNotEmpty) {
    switch (filter) {
      case 'today':
        final now = DateTime.now();
        filtered = filtered
            .where((visitor) =>
                visitor.timestamp.day == now.day &&
                visitor.timestamp.month == now.month &&
                visitor.timestamp.year == now.year)
            .toList();
        break;
      case 'week':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered
            .where((visitor) => visitor.timestamp.isAfter(weekAgo))
            .toList();
        break;
      case 'month':
        final now = DateTime.now();
        filtered = filtered
            .where((visitor) =>
                visitor.timestamp.month == now.month &&
                visitor.timestamp.year == now.year)
            .toList();
        break;
      case 'desktop':
        filtered = filtered
            .where((visitor) =>
                !visitor.userAgent.toLowerCase().contains('mobile'))
            .toList();
        break;
      case 'mobile':
        filtered = filtered
            .where(
                (visitor) => visitor.userAgent.toLowerCase().contains('mobile'))
            .toList();
        break;
      case 'tablet':
        filtered = filtered
            .where(
                (visitor) => visitor.userAgent.toLowerCase().contains('tablet'))
            .toList();
        break;
    }
  }

  // Apply date range filter
  if (dateRange != null) {
    filtered = filtered
        .where((visitor) =>
            visitor.timestamp.isAfter(dateRange.start) &&
            visitor.timestamp
                .isBefore(dateRange.end.add(const Duration(days: 1))))
        .toList();
  }

  // Apply sorting
  switch (sortOption) {
    case 'timestamp_desc':
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      break;
    case 'timestamp_asc':
      filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      break;
    case 'country_asc':
      filtered.sort((a, b) => a.country.compareTo(b.country));
      break;
    case 'country_desc':
      filtered.sort((a, b) => b.country.compareTo(a.country));
      break;
    case 'ip_asc':
      filtered.sort((a, b) => a.ipAddress.compareTo(b.ipAddress));
      break;
    case 'ip_desc':
      filtered.sort((a, b) => b.ipAddress.compareTo(a.ipAddress));
      break;
  }

  return filtered;
});

// ==================== Statistics Providers ====================
final visitorStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final visitors = ref.watch(visitorLocationsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final thisWeek = now.subtract(const Duration(days: 7));
  final thisMonth = DateTime(now.year, now.month, 1);

  final todayVisitors =
      visitors.where((v) => v.timestamp.isAfter(today)).length;
  final yesterdayVisitors = visitors
      .where(
          (v) => v.timestamp.isAfter(yesterday) && v.timestamp.isBefore(today))
      .length;
  final weekVisitors =
      visitors.where((v) => v.timestamp.isAfter(thisWeek)).length;
  final monthVisitors =
      visitors.where((v) => v.timestamp.isAfter(thisMonth)).length;

  final uniqueIPs = visitors.map((v) => v.ipAddress).toSet().length;
  final uniqueCountries = visitors.map((v) => v.country).toSet().length;

  // Device type breakdown
  int mobileCount = 0, desktopCount = 0, tabletCount = 0;
  for (final visitor in visitors) {
    final deviceInfo = visitor.deviceInfo;
    if (deviceInfo.isMobile) {
      mobileCount++;
    } else if (deviceInfo.isTablet) {
      tabletCount++;
    } else {
      desktopCount++;
    }
  }

  // Calculate percentage change from yesterday
  double percentageChange = 0.0;
  if (yesterdayVisitors > 0) {
    percentageChange =
        ((todayVisitors - yesterdayVisitors) / yesterdayVisitors) * 100;
  } else if (todayVisitors > 0) {
    percentageChange = 100.0;
  }

  return {
    'total': visitors.length,
    'today': todayVisitors,
    'yesterday': yesterdayVisitors,
    'week': weekVisitors,
    'month': monthVisitors,
    'unique': uniqueIPs,
    'countries': uniqueCountries,
    'percentageChange': percentageChange,
    'devices': {
      'mobile': mobileCount,
      'desktop': desktopCount,
      'tablet': tabletCount,
    },
  };
});

// ==================== Top Countries Provider ====================
final topCountriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final visitors = ref.watch(visitorLocationsProvider);

  final countryCount = <String, int>{};
  for (final visitor in visitors) {
    countryCount[visitor.country] = (countryCount[visitor.country] ?? 0) + 1;
  }

  final sortedCountries = countryCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedCountries
      .take(10)
      .map((entry) => {
            'country': entry.key,
            'count': entry.value,
            'percentage': visitors.isNotEmpty
                ? (entry.value / visitors.length * 100)
                : 0.0,
          })
      .toList();
});

// ==================== Real-time Updates Provider ====================
final realtimeVisitorsProvider = StreamProvider<List<VisitorInfo>>((ref) {
  return FirebaseFirestore.instance
      .collection('visitors')
      .orderBy('timestamp', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => VisitorInfo.fromMap(doc.data(), doc.id))
          .toList());
});

// ==================== Dashboard Settings Provider ====================
final dashboardSettingsProvider =
    StateNotifierProvider<DashboardSettingsNotifier, DashboardSettings>((ref) {
  return DashboardSettingsNotifier();
});

class DashboardSettings {
  final bool autoRefresh;
  final int refreshInterval; // in minutes
  final bool showNotifications;
  final bool compactMode;
  final String theme; // 'light', 'dark', 'system'

  const DashboardSettings({
    this.autoRefresh = true,
    this.refreshInterval = 5,
    this.showNotifications = true,
    this.compactMode = false,
    this.theme = 'system',
  });
  //pr
  DashboardSettings copyWith({
    bool? autoRefresh,
    int? refreshInterval,
    bool? showNotifications,
    bool? compactMode,
    String? theme,
  }) {
    return DashboardSettings(
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      showNotifications: showNotifications ?? this.showNotifications,
      compactMode: compactMode ?? this.compactMode,
      theme: theme ?? this.theme,
    );
  }
}

class DashboardSettingsNotifier extends StateNotifier<DashboardSettings> {
  DashboardSettingsNotifier() : super(const DashboardSettings());

  void toggleAutoRefresh() {
    state = state.copyWith(autoRefresh: !state.autoRefresh);
  }

  void setRefreshInterval(int minutes) {
    if (minutes > 0 && minutes <= 60) {
      state = state.copyWith(refreshInterval: minutes);
    }
  }

  void toggleNotifications() {
    state = state.copyWith(showNotifications: !state.showNotifications);
  }

  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
  }

  void setTheme(String theme) {
    if (['light', 'dark', 'system'].contains(theme)) {
      state = state.copyWith(theme: theme);
    }
  }
}
