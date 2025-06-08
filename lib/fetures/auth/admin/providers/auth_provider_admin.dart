// auth_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/models/user_application_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/notifiers/auth_notifier_admin.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/services/admin_service.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/services/application_service.dart';
import 'package:trustedtallentsvalley/fetures/auth/trusted_user/services/trusted_user_service.dart';

import '../states/auth_state_admin.dart';

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Service providers
final adminServiceProvider = Provider<AdminService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AdminService(auth, firestore);
});

final applicationServiceProvider = Provider<ApplicationService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return ApplicationService(firestore);
});

final trustedUserServiceProvider = Provider<TrustedUserService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return TrustedUserService(auth, firestore);
});

// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthNotifier(auth, firestore);
});

// Basic auth state providers
final isAdminProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  // Only return true if authenticated, no error, and actually admin
  return authState.isAuthenticated &&
      authState.error == null &&
      authState.isAdmin;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  // Return true only if authenticated and no error
  return authState.isAuthenticated && authState.error == null;
});

final isTrustedUserProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  // Return true only if authenticated, no error, and is trusted user
  return authState.isAuthenticated &&
      authState.error == null &&
      authState.isTrustedUser;
});

final isApprovedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  // Return true only if authenticated, no error, and is approved
  return authState.isAuthenticated &&
      authState.error == null &&
      authState.isApproved;
});
final canEditProfileProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  // Return true only if authenticated, no error, and is approved
  return authState.canEditProfile &&
      authState.error == null &&
      authState.isApproved;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final userDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).userData;
});

final applicationDataProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).applicationData;
});

// Application statistics provider
final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.getApplicationStatistics();
});

// Trusted user statistics provider
final trustedUserStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUserStatistics();
});

// Fixed: Properly convert application data to UserApplication objects
final allUserApplicationsProvider =
    FutureProvider<List<UserApplication>>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  final applicationsData = await authNotifier.getAllUserApplications();

  // Convert List<Map<String, dynamic>> to List<UserApplication>
  return applicationsData.map((data) {
    // Extract document ID or use email as fallback
    final documentId = data['documentId'] ?? data['id'] ?? data['email'] ?? '';
    return UserApplication.fromMap(data, documentId);
  }).toList();
});

// Keep the map version for backward compatibility
final allUserApplicationsAsMapProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.getAllUserApplications();
});

// Application metrics provider
final applicationMetricsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.getApplicationMetrics();
});

// Trusted user metrics provider
final trustedUserMetricsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUserMetrics();
});

// Recent applications provider
final recentApplicationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.getRecentApplications(limit: 5);
});

// Pending applications provider
final pendingApplicationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.getPendingApplications();
});

// Applications requiring review provider
final applicationsRequiringReviewProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.getApplicationsRequiringReview();
});

// Top rated trusted users provider
final topRatedTrustedUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTopRatedTrustedUsers(limit: 10);
});

// Recently joined trusted users provider
final recentlyJoinedTrustedUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getRecentlyJoinedTrustedUsers(limit: 10);
});

// All trusted users provider
final allTrustedUsersProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getAllTrustedUsers();
});

// Fixed: Current user data provider with proper null handling
final currentUserDataProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);

  // Return userData if user is authenticated
  if (authState.isAuthenticated) {
    return authState.userData;
  }

  return null;
});

// Can perform actions provider (only approved users)
final canPerformActionsProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated &&
      authState.isApproved &&
      (authState.isTrustedUser || authState.isAdmin);
});

// User role text provider
final userRoleTextProvider = Provider<String>((ref) {
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) return 'غير مصادق عليه';

  switch (authState.role) {
    case UserRole.admin:
      return 'مشرف';
    case UserRole.trusted:
      return authState.isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة';
    case UserRole.common:
      return 'مستخدم عادي';
    case UserRole.betrug:
      return 'محظور';
    default:
      return 'غير محدد';
  }
});

// Error provider
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

// Loading state provider
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

// Search applications provider (with query parameter)
final searchApplicationsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, query) async {
  if (query.trim().isEmpty) return [];

  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.searchApplications(query.trim());
});

// Applications by status provider
final applicationsByStatusProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, status) async {
  if (status.trim().isEmpty) return [];

  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.getApplicationsByStatus(status.trim());
});

// Trusted users by location provider
final trustedUsersByLocationProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, location) async {
  if (location.trim().isEmpty) return [];

  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUsersByLocation(location.trim());
});

// Trusted users by service provider
final trustedUsersByServiceProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, service) async {
  if (service.trim().isEmpty) return [];

  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUsersByService(service.trim());
});

// Application by email provider
final applicationByEmailProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, email) async {
  if (email.trim().isEmpty) return null;

  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService
      .getApplicationByEmail(email.trim().toLowerCase());
});

// Trusted user profile provider
final trustedUserProfileProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  if (userId.trim().isEmpty) return null;

  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUserProfile(userId.trim());
});

// Users requiring profile completion provider
final usersRequiringProfileCompletionProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final trustedUserService = ref.watch(trustedUserServiceProvider);
  return await trustedUserService.getTrustedUsersRequiringProfileCompletion();
});

// Email exists provider
final emailExistsProvider =
    FutureProvider.family<bool, String>((ref, email) async {
  if (email.trim().isEmpty) return false;

  final applicationService = ref.watch(applicationServiceProvider);
  return await applicationService.emailExists(email.trim().toLowerCase());
});

// User permissions provider
final userPermissionsProvider = Provider<Map<String, bool>>((ref) {
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated) {
    return {
      'canEditProfile': false,
      'canAccessDashboard': false,
      'canViewApplications': false,
      'canApproveApplications': false,
      'canManageUsers': false,
    };
  }

  final userData = authState.userData;
  final permissions = userData?['permissions'] as Map<String, dynamic>? ?? {};

  return {
    'canEditProfile':
        authState.isApproved && (permissions['canEditProfile'] ?? false),
    'canAccessDashboard': authState.isAuthenticated,
    'canViewApplications': authState.isAdmin,
    'canApproveApplications': authState.isAdmin,
    'canManageUsers': authState.isAdmin,
  };
});

// Current user email provider
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.email ?? authState.userEmail;
});
// Current user email provider
final currentUserPhoneProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.phoneNumber ?? authState.user!.phoneNumber;
});
// Current user email provider
final userNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.displayName;
});
final applicationStatusProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.statusDisplayText;
});

// Profile completion status provider
final profileCompletionProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);

  if (!authState.isAuthenticated || !authState.isTrustedUser) return false;

  final userData = authState.userData;
  return userData?['profileCompleted'] ?? false;
});

// Auto-refresh provider (refreshes auth state every 5 minutes)
final autoRefreshProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(minutes: 5), (count) {
    // Trigger refresh of auth state
    ref.read(authProvider.notifier).refreshAuthState();
    return count;
  });
});
