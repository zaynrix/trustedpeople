import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/notifiers/auth_notifier_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/providers/auth_provider_admin.dart';

// Provider for managing user applications
final userApplicationsProvider = StateNotifierProvider<UserApplicationsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final auth = ref.watch(authProvider.notifier);
  return UserApplicationsNotifier(auth);
});

// 🆕 NEW: Enhanced UserApplicationsNotifier to work with trusted users
class UserApplicationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final AuthNotifier _authNotifier;

  UserApplicationsNotifier(this._authNotifier)
      : super(const AsyncValue.loading()) {
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      state = const AsyncValue.loading();
      final applications = await _authNotifier.getAllUserApplications();
      state = AsyncValue.data(applications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

// 🆕 NEW: Get users with application data from 'users' collection
  Future<List<Map<String, dynamic>>> _getAllUsersWithApplicationData() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'documentId': doc.id,
          'uid': data['uid'],
          'fullName': data['profile']['fullName'] ??
              data['profile']['firstName'] +
                  ' ' +
                  (data['profile']['lastName'] ?? ''),
          'email': data['email'],
          'phoneNumber': data['profile']['phone'],
          'additionalPhone': data['profile']['additionalPhone'] ?? '',
          'serviceProvider': data['profile']['serviceProvider'],
          'location': data['profile']['location'],
          'telegramAccount': data['profile']['telegramAccount'] ?? '',
          'description': data['profile']['bio'] ?? '',
          'workingHours': data['profile']['workingHours'] ?? '',
          'status': data['status'], // pending|approved|rejected|suspended
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
          'adminComment': data['application']['rejectionReason'] ?? '',
          'submittedAt': data['application']['submittedAt'],
          'reviewedAt': data['application']['reviewedAt'],
          'reviewedBy': data['application']['reviewedBy'],
          'canEditProfile': data['permissions']['canEditProfile'] ?? false,
        };
      }).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

// 🆕 UPDATED: Enhanced approval method
  Future<void> updateApplicationStatus(String userId, String status,
      {String? comment}) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Step 1: Update user document
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userRef, {
        'status': status,
        'permissions.canEditProfile': status.toLowerCase() == 'approved',
        'application.reviewedAt': FieldValue.serverTimestamp(),
        'application.reviewedBy': 'admin_uid', // Get from current admin
        'application.rejectionReason': comment ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (status.toLowerCase() == 'approved') {
        // Step 2: Create trusted_users document
        final userDoc = await userRef.get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final trustedUserRef = FirebaseFirestore.instance
              .collection('trusted_users')
              .doc(userId);

          batch.set(trustedUserRef, {
            'uid': userId,
            'publicProfile': {
              'displayName': userData['profile']['fullName'],
              'bio': userData['profile']['bio'] ?? '',
              'profileImageUrl': userData['profile']['profileImageUrl'] ?? '',
              'serviceProvider': userData['profile']['serviceProvider'],
              'location': userData['profile']['location'],
              'workingHours': userData['profile']['workingHours'] ?? '',
              'showPhone': true,
              'showEmail': false,
              'showAddress': true,
              'phone': userData['profile']['phone'],
              'email': userData['email'],
              'city': userData['profile']['location'],
              'state': '',
            },
            'verificationBadges': [
              if (userData['verification']['emailVerified'] == true)
                'email_verified',
              if (userData['verification']['phoneVerified'] == true)
                'phone_verified',
            ],
            'statistics': {
              'rating': 0.0,
              'totalReviews': 0,
              'joinedDate': FieldValue.serverTimestamp(),
            },
            'isVisible': true,
            'addedToTrustedAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      } else if (status.toLowerCase() == 'rejected') {
        // Step 3: Remove from trusted_users if rejected
        final trustedUserRef =
            FirebaseFirestore.instance.collection('trusted_users').doc(userId);
        batch.delete(trustedUserRef);
      }

      await batch.commit();
      await loadApplications();
    } catch (error) {
      rethrow;
    }
  }

// 🆕 UPDATED: Get trusted users count from new collection
  Future<int> getTrustedUsersCount() async {
    try {
      final trustedSnapshot = await FirebaseFirestore.instance
          .collection('trusted_users')
          .where('isVisible', isEqualTo: true)
          .get();
      return trustedSnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // 🆕 UPDATED: Sync method for new structure
  Future<void> syncApprovedUsersToTrustedTable() async {
    try {
      print('🔄 Starting sync of approved users to trusted_users...');

      // Get all approved users who don't have trusted_users entry
      final approvedUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'approved')
          .get();

      int synced = 0;
      int errors = 0;

      for (final userDoc in approvedUsersSnapshot.docs) {
        try {
          final userId = userDoc.id;
          final userData = userDoc.data();

          // Check if already exists in trusted_users
          final trustedUserDoc = await FirebaseFirestore.instance
              .collection('trusted_users')
              .doc(userId)
              .get();

          if (!trustedUserDoc.exists) {
            // Create trusted_users entry
            await FirebaseFirestore.instance
                .collection('trusted_users')
                .doc(userId)
                .set({
              'uid': userId,
              'publicProfile': {
                'displayName': userData['profile']['fullName'],
                'bio': userData['profile']['bio'] ?? '',
                'profileImageUrl': userData['profile']['profileImageUrl'] ?? '',
                'serviceProvider': userData['profile']['serviceProvider'],
                'location': userData['profile']['location'],
                'workingHours': userData['profile']['workingHours'] ?? '',
                'showPhone': true,
                'showEmail': false,
                'showAddress': true,
                'phone': userData['profile']['phone'],
                'email': userData['email'],
                'city': userData['profile']['location'],
                'state': '',
              },
              'verificationBadges': ['email_verified'],
              'statistics': {
                'rating': 0.0,
                'totalReviews': 0,
                'joinedDate': FieldValue.serverTimestamp(),
              },
              'isVisible': true,
              'addedToTrustedAt': FieldValue.serverTimestamp(),
              'lastUpdated': FieldValue.serverTimestamp(),
            });

            synced++;
            print('🔄 Synced user: ${userData['email']}');
          }
        } catch (e) {
          errors++;
          print('🔄 Error syncing user: $e');
        }
      }

      print('🔄 Sync completed: $synced synced, $errors errors');
    } catch (e) {
      print('🔄 Error during sync: $e');
      rethrow;
    }
  }
}

class AdminDashboardStatusScreen extends ConsumerStatefulWidget {
  const AdminDashboardStatusScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardStatusScreen> createState() =>
      _AdminDashboardStatusScreenState();
}

class _AdminDashboardStatusScreenState
    extends ConsumerState<AdminDashboardStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Modern color scheme
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

// 🆕 NEW: Enhanced admin statistics widget
  Widget _buildEnhancedStatsSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getEnhancedStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final stats = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات شاملة',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 20),

              // Main stats grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'إجمالي الطلبات',
                    stats['totalApplications'].toString(),
                    Icons.folder_copy,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'في الانتظار',
                    stats['pendingApplications'].toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'المقبولة',
                    stats['approvedApplications'].toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'الموثوقين النشطين',
                    stats['activeTrustedUsers'].toString(),
                    Icons.verified_user,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sync button for admin
              if (stats['needsSync'] == true) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.sync_problem, color: Colors.yellow.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مزامنة مطلوبة',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow.shade800,
                              ),
                            ),
                            Text(
                              'هناك مستخدمين مقبولين لم يتم إضافتهم لقائمة الموثوقين',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.yellow.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _performSync(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('مزامنة', style: GoogleFonts.cairo()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

// 🆕 NEW: Get enhanced statistics
  Future<Map<String, dynamic>> _getEnhancedStats() async {
    try {
      // Get application stats
      final appStats =
          await ref.read(authProvider.notifier).getApplicationStatistics();

      // Get trusted users count
      final trustedCount = await ref
          .read(userApplicationsProvider.notifier)
          .getTrustedUsersCount();

      // Check if sync is needed
      final approvedCount = appStats['approved'] ?? 0;
      final needsSync = approvedCount > trustedCount;

      return {
        'totalApplications': appStats['total'] ?? 0,
        'pendingApplications':
            (appStats['in_progress'] ?? 0) + (appStats['needs_review'] ?? 0),
        'approvedApplications': approvedCount,
        'rejectedApplications': appStats['rejected'] ?? 0,
        'activeTrustedUsers': trustedCount,
        'needsSync': needsSync,
      };
    } catch (e) {
      return {
        'totalApplications': 0,
        'pendingApplications': 0,
        'approvedApplications': 0,
        'rejectedApplications': 0,
        'activeTrustedUsers': 0,
        'needsSync': false,
      };
    }
  }

// 🆕 NEW: Stat card widget
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

// 🆕 NEW: Perform sync operation
  Future<void> _performSync() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('جاري المزامنة...', style: GoogleFonts.cairo()),
            ],
          ),
        ),
      );

      // Perform sync
      await ref
          .read(userApplicationsProvider.notifier)
          .syncApprovedUsersToTrustedTable();

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت المزامنة بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Refresh data
      ref.invalidate(userApplicationsProvider);
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في المزامنة: ${e.toString()}',
                style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(userApplicationsProvider);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;
    final isTablet = size.width >= 600 && size.width < 900;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: _buildModernAppBar(context, isMobile),
      body: applicationsAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorWidget(error.toString()),
        data: (applications) =>
            _buildMainContent(applications, isMobile, isTablet),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context, bool isMobile) {
    return AppBar(
      elevation: 0,
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: isMobile ? 64 : 80,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة طلبات التسجيل',
            style: GoogleFonts.cairo(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          if (!isMobile)
            Text(
              'إدارة وتتبع جميع طلبات التسجيل',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () =>
                ref.read(userApplicationsProvider.notifier).loadApplications(),
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            tooltip: 'تحديث البيانات',
          ),
        ),
      ],
      bottom: isMobile ? null : _buildTabBar(),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        decoration: const BoxDecoration(
          color: cardColor,
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle:
              GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 14),
          tabs: const [
            Tab(text: 'جميع الطلبات'),
            Tab(text: 'قيد المراجعة'),
            Tab(text: 'مقبولة'),
            Tab(text: 'مرفوضة'),
            Tab(text: 'تحتاج مراجعة'),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      List<Map<String, dynamic>> applications, bool isMobile, bool isTablet) {
    return Column(
      children: [
        _buildEnhancedStatsSection(),
        if (isMobile) _buildMobileHeader(applications),
        if (isMobile) _buildMobileFilterChips(applications),
        _buildSearchBar(isMobile),
        Expanded(
          child: isMobile
              ? _buildMobileLayout(applications)
              : _buildDesktopLayout(applications, isTablet),
        ),
      ],
    );
  }

  Widget _buildMobileHeader(List<Map<String, dynamic>> applications) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              'إجمالي الطلبات',
              applications.length.toString(),
              Icons.folder_copy_outlined,
              primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatsCard(
              'في الانتظار',
              _filterApplications(applications, 'in_progress')
                  .length
                  .toString(),
              Icons.pending_outlined,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'البحث في الطلبات...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
                  prefixIcon:
                      Icon(Icons.search_rounded, color: Colors.grey.shade500),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: Icon(Icons.clear_rounded,
                              color: Colors.grey.shade500),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => ref
                    .read(userApplicationsProvider.notifier)
                    .loadApplications(),
                icon:
                    const Icon(Icons.filter_list_rounded, color: Colors.white),
                tooltip: 'فلترة النتائج',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileFilterChips(List<Map<String, dynamic>> applications) {
    final filters = [
      {
        'key': 'all',
        'label': 'الكل',
        'count': applications.length,
        'icon': Icons.apps
      },
      {
        'key': 'in_progress',
        'label': 'قيد المراجعة',
        'count': _filterApplications(applications, 'in_progress').length,
        'icon': Icons.pending
      },
      {
        'key': 'approved',
        'label': 'مقبولة',
        'count': _filterApplications(applications, 'approved').length,
        'icon': Icons.check_circle
      },
      {
        'key': 'rejected',
        'label': 'مرفوضة',
        'count': _filterApplications(applications, 'rejected').length,
        'icon': Icons.cancel
      },
      {
        'key': 'needs_review',
        'label': 'تحتاج مراجعة',
        'count': _filterApplications(applications, 'needs_review').length,
        'icon': Icons.visibility
      },
    ];

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['key'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    setState(() => _selectedFilter = filter['key'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primaryColor : borderColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${filter['label']} (${filter['count']})',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, dynamic>> applications) {
    return _buildApplicationsList(applications, true);
  }

  Widget _buildDesktopLayout(
      List<Map<String, dynamic>> applications, bool isTablet) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildApplicationsList(applications, false, isTablet: isTablet),
        _buildApplicationsList(
            _filterApplications(applications, 'in_progress'), false,
            isTablet: isTablet),
        _buildApplicationsList(
            _filterApplications(applications, 'approved'), false,
            isTablet: isTablet),
        _buildApplicationsList(
            _filterApplications(applications, 'rejected'), false,
            isTablet: isTablet),
        _buildApplicationsList(
            _filterApplications(applications, 'needs_review'), false,
            isTablet: isTablet),
      ],
    );
  }

  Widget _buildApplicationsList(
      List<Map<String, dynamic>> applications, bool isMobile,
      {bool isTablet = false}) {
    var filteredApplications = isMobile
        ? (_selectedFilter == 'all'
            ? applications
            : _filterApplications(applications, _selectedFilter))
        : applications;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredApplications = filteredApplications.where((app) {
        final searchLower = _searchQuery.toLowerCase();
        return (app['fullName']?.toLowerCase().contains(searchLower) ??
                false) ||
            (app['email']?.toLowerCase().contains(searchLower) ?? false) ||
            (app['phoneNumber']?.contains(_searchQuery) ?? false);
      }).toList();
    }

    if (filteredApplications.isEmpty) {
      return _buildEmptyState();
    }

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(userApplicationsProvider.notifier).loadApplications(),
      child: isMobile
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) => _buildModernApplicationCard(
                  filteredApplications[index], isMobile),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.75,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: filteredApplications.length,
              itemBuilder: (context, index) => _buildModernApplicationCard(
                  filteredApplications[index], isMobile),
            ),
    );
  }

  Widget _buildModernApplicationCard(
      Map<String, dynamic> application, bool isMobile) {
    final status = application['status'] ?? 'pending';
    final createdAt = application['createdAt'];

    return Container(
      margin: isMobile ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.05),
                  primaryColor.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['fullName'] ?? 'غير محدد',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        application['email'] ?? 'غير محدد',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildModernStatusChip(status),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModernDetailRow(Icons.phone_rounded, 'الهاتف',
                      application['phoneNumber'] ?? 'غير محدد'),
                  const SizedBox(height: 12),
                  _buildModernDetailRow(Icons.business_rounded, 'مقدم الخدمة',
                      application['serviceProvider'] ?? 'غير محدد'),
                  const SizedBox(height: 12),
                  _buildModernDetailRow(Icons.location_on_rounded, 'الموقع',
                      application['location'] ?? 'غير محدد'),
                  if (createdAt != null) ...[
                    const SizedBox(height: 12),
                    _buildModernDetailRow(Icons.schedule_rounded,
                        'تاريخ التقديم', _formatDate(createdAt)),
                  ],

                  if (application['adminComment']?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.comment_rounded,
                              size: 16, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              application['adminComment'],
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernActionButton(
                          'عرض التفاصيل',
                          Icons.visibility_rounded,
                          primaryColor,
                          () => _showApplicationDetails(application),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildModernActionButton(
                          'إدارة الحالة',
                          Icons.edit_rounded,
                          primaryColor,
                          () => _showStatusManagementDialog(application),
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatusChip(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green.shade600;
        text = 'مقبول';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        color = Colors.red.shade600;
        text = 'مرفوض';
        icon = Icons.cancel_rounded;
        break;
      case 'in_progress':
        color = Colors.orange.shade600;
        text = 'قيد المراجعة';
        icon = Icons.pending_rounded;
        break;
      case 'needs_review':
        color = Colors.blue.shade600;
        text = 'يحتاج مراجعة';
        icon = Icons.visibility_rounded;
        break;
      default:
        color = Colors.grey.shade600;
        text = 'في الانتظار';
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(
      String text, IconData icon, Color color, VoidCallback onPressed,
      {bool isPrimary = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isPrimary ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary ? color : color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isPrimary ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 50,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد طلبات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي طلبات في هذه الفئة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(userApplicationsProvider.notifier)
                  .loadApplications(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Keep existing utility methods
  List<Map<String, dynamic>> _filterApplications(
      List<Map<String, dynamic>> applications, String status) {
    return applications
        .where((app) => app['status']?.toLowerCase() == status.toLowerCase())
        .toList();
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) =>
          ModernApplicationDetailsDialog(application: application),
    );
  }

  void _showStatusManagementDialog(Map<String, dynamic> application) {
    showDialog(
      context: context,
      builder: (context) => ModernStatusManagementDialog(
        application: application,
        onStatusUpdated: (status, comment) async {
          try {
            final documentId = application['documentId'];
            if (documentId == null) {
              throw Exception('Document ID not found');
            }

            // 🆕 ENHANCED: Use the new method that handles trusted users integration
            await ref
                .read(userApplicationsProvider.notifier)
                .updateApplicationStatus(
                  documentId,
                  status,
                  comment: comment,
                );

            if (mounted) {
              // Show appropriate success message based on status
              String successMessage = 'تم تحديث الحالة بنجاح';

              if (status.toLowerCase() == 'approved') {
                successMessage =
                    'تم قبول الطلب وإضافة المستخدم إلى قائمة الموثوقين بنجاح';
              } else if (status.toLowerCase() == 'rejected') {
                successMessage =
                    'تم رفض الطلب وإزالة المستخدم من قائمة الموثوقين';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(successMessage, style: GoogleFonts.cairo()),
                  backgroundColor: status.toLowerCase() == 'approved'
                      ? Colors.green
                      : status.toLowerCase() == 'rejected'
                          ? Colors.red
                          : Colors.blue,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ في تحديث الحالة: ${e.toString()}',
                      style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

// Modern Application Details Dialog
class ModernApplicationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> application;
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color cardColor = Colors.white;

  const ModernApplicationDetailsDialog({Key? key, required this.application})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تفاصيل الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  application['fullName'] ?? 'غير محدد',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailSection('المعلومات الشخصية', Icons.person_rounded, [
          _buildDetailItem('الاسم الكامل', application['fullName']),
          _buildDetailItem('البريد الإلكتروني', application['email']),
          _buildDetailItem('رقم الهاتف', application['phoneNumber']),
          if (application['additionalPhone']?.isNotEmpty == true)
            _buildDetailItem('رقم هاتف إضافي', application['additionalPhone']),
        ]),
        const SizedBox(height: 24),
        _buildDetailSection('معلومات الخدمة', Icons.business_rounded, [
          _buildDetailItem('مقدم الخدمة', application['serviceProvider']),
          _buildDetailItem('الموقع', application['location']),
        ]),
        const SizedBox(height: 24),
        _buildDetailSection('حالة الطلب', Icons.info_rounded, [
          _buildDetailItem(
              'الحالة الحالية', _getStatusText(application['status'])),
          if (application['createdAt'] != null)
            _buildDetailItem(
                'تاريخ التقديم', _formatDate(application['createdAt'])),
          if (application['updatedAt'] != null)
            _buildDetailItem(
                'آخر تحديث', _formatDate(application['updatedAt'])),
        ]),
        if (application['adminComment']?.isNotEmpty == true) ...[
          const SizedBox(height: 24),
          _buildCommentSection(application['adminComment']),
        ],
      ],
    );
  }

  Widget _buildDetailSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(String comment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment_rounded,
                  color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'ملاحظات الإدارة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.blue.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'needs_review':
        return 'يحتاج مراجعة';
      default:
        return 'في الانتظار';
    }
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
      return timestamp.toString();
    } catch (e) {
      return 'غير محدد';
    }
  }
}

// Modern Status Management Dialog
class ModernStatusManagementDialog extends StatefulWidget {
  final Map<String, dynamic> application;
  final Function(String status, String? comment) onStatusUpdated;

  const ModernStatusManagementDialog({
    Key? key,
    required this.application,
    required this.onStatusUpdated,
  }) : super(key: key);

  @override
  State<ModernStatusManagementDialog> createState() =>
      _ModernStatusManagementDialogState();
}

class _ModernStatusManagementDialogState
    extends State<ModernStatusManagementDialog> {
  late String _selectedStatus;
  final _commentController = TextEditingController();
  bool _isLoading = false;
  static const Color primaryColor = Color(0xFF2563EB);

  final List<Map<String, dynamic>> _statusOptions = [
    {
      'value': 'in_progress',
      'label': 'قيد المراجعة',
      'color': Colors.orange.shade600,
      'icon': Icons.pending_rounded,
      'description': 'الطلب قيد المراجعة من قبل الفريق'
    },
    {
      'value': 'approved',
      'label': 'مقبول',
      'color': Colors.green.shade600,
      'icon': Icons.check_circle_rounded,
      'description': 'تم قبول الطلب وتفعيل الحساب'
    },
    {
      'value': 'rejected',
      'label': 'مرفوض',
      'color': Colors.red.shade600,
      'icon': Icons.cancel_rounded,
      'description': 'تم رفض الطلب لعدم استيفاء الشروط'
    },
    {
      'value': 'needs_review',
      'label': 'يحتاج مراجعة',
      'color': Colors.blue.shade600,
      'icon': Icons.visibility_rounded,
      'description': 'الطلب يحتاج مراجعة إضافية'
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.application['status'] ?? 'in_progress';
    _commentController.text = widget.application['adminComment'] ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(isMobile ? 16 : 40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة حالة الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.application['fullName'] ?? 'غير محدد',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status selection
        Text(
          'حالة الطلب',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),

        ..._statusOptions.map((option) => _buildStatusOption(option)).toList(),

        const SizedBox(height: 24),

        // Comment section
        Text(
          'ملاحظات للمتقدم',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك إضافة ملاحظات توضيحية للمتقدم حول حالة طلبه',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _commentController,
            maxLines: 5,
            style: GoogleFonts.cairo(),
            decoration: InputDecoration(
              hintText: 'أدخل ملاحظاتك هنا...',
              hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusOption(Map<String, dynamic> option) {
    final isSelected = _selectedStatus == option['value'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            isSelected ? option['color'].withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? option['color'] : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedStatus = option['value']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Radio<String>(
                  value: option['value'],
                  groupValue: _selectedStatus,
                  onChanged: (value) =>
                      setState(() => _selectedStatus = value!),
                  activeColor: option['color'],
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: option['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option['icon'],
                    color: option['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option['label'],
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? option['color']
                              : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['description'],
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'حفظ التغييرات',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus() async {
    setState(() => _isLoading = true);

    try {
      await widget.onStatusUpdated(
          _selectedStatus, _commentController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحديث الحالة', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
