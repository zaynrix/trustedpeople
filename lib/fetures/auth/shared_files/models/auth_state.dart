// models/auth_state.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/models/admin_user_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/admin/models/user_application_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_base_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_role_enum.dart';
import 'package:trustedtallentsvalley/fetures/auth/trusted_user/models/trusted_user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserRole role;
  final User? firebaseUser;
  final AdminUser? adminUser;
  final TrustedUser? trustedUser;
  final UserApplication? pendingApplication;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role = UserRole.common,
    this.firebaseUser,
    this.adminUser,
    this.trustedUser,
    this.pendingApplication,
    this.error,
  });

  // Computed getters for easy access
  bool get isAdmin => role == UserRole.admin && adminUser != null;
  bool get isTrusted => role == UserRole.trusted && trustedUser != null;
  bool get isPending => pendingApplication != null && !isApproved;
  bool get isApproved => trustedUser?.isApproved ?? false;
  bool get hasFirebaseAuth => firebaseUser != null;

  // Get current user data regardless of type
  BaseUser? get currentUser {
    if (adminUser != null) return adminUser;
    if (trustedUser != null) return trustedUser;
    return null;
  }

  // Get user email from any source
  String? get userEmail {
    return firebaseUser?.email ??
        adminUser?.email ??
        trustedUser?.email ??
        pendingApplication?.email;
  }

  // Get user display name from any source
  String? get displayName {
    return firebaseUser?.displayName ??
        adminUser?.fullName ??
        trustedUser?.fullName ??
        pendingApplication?.fullName;
  }

  // Check if user can perform actions (only approved users)
  bool get canPerformActions {
    return isAuthenticated && (isAdmin || (isTrusted && isApproved));
  }

  // Get application status for pending users
  String? get applicationStatus {
    return pendingApplication?.status;
  }

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserRole? role,
    User? firebaseUser,
    AdminUser? adminUser,
    TrustedUser? trustedUser,
    UserApplication? pendingApplication,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      adminUser: adminUser ?? this.adminUser,
      trustedUser: trustedUser ?? this.trustedUser,
      pendingApplication: pendingApplication ?? this.pendingApplication,
      error: error ?? this.error,
    );
  }

  // Clear user data while keeping loading state
  AuthState clearUser() {
    return AuthState(
      isLoading: isLoading,
      isAuthenticated: false,
      role: UserRole.common,
      firebaseUser: null,
      adminUser: null,
      trustedUser: null,
      pendingApplication: null,
      error: error,
    );
  }

  // Set admin user
  AuthState setAdmin(User firebaseUser, AdminUser adminUser) {
    return AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: UserRole.admin,
      firebaseUser: firebaseUser,
      adminUser: adminUser,
      trustedUser: null,
      pendingApplication: null,
      error: null,
    );
  }

  // Set trusted user (approved)
  AuthState setTrustedUser(User firebaseUser, TrustedUser trustedUser) {
    return AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: UserRole.trusted,
      firebaseUser: firebaseUser,
      adminUser: null,
      trustedUser: trustedUser,
      pendingApplication: null,
      error: null,
    );
  }

  // Set pending user (no Firebase auth yet)
  AuthState setPendingUser(UserApplication application) {
    return AuthState(
      isLoading: false,
      isAuthenticated: true,
      role: UserRole.trusted,
      firebaseUser: null,
      adminUser: null,
      trustedUser: null,
      pendingApplication: application,
      error: null,
    );
  }

  // Set loading state
  AuthState setLoading(bool loading) {
    return copyWith(isLoading: loading, error: null);
  }

  // Set error state
  AuthState setError(String error) {
    return copyWith(isLoading: false, error: error);
  }

  @override
  String toString() {
    return 'AuthState('
        'isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, '
        'role: $role, '
        'firebaseUser: ${firebaseUser?.email ?? 'null'}, '
        'adminUser: ${adminUser?.email ?? 'null'}, '
        'trustedUser: ${trustedUser?.email ?? 'null'}, '
        'pendingApplication: ${pendingApplication?.email ?? 'null'}, '
        'error: $error'
        ')';
  }
}
