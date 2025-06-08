// auth_state.dart
import 'package:firebase_auth/firebase_auth.dart';

// User roles
enum UserRole {
  admin(0),
  trusted(1),
  common(2),
  betrug(3);

  final int value;
  const UserRole(this.value);

  static UserRole fromInt(int value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.common,
    );
  }

  // Helper method to get role display name
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مشرف';
      case UserRole.trusted:
        return 'مستخدم موثوق';
      case UserRole.common:
        return 'مستخدم عادي';
      case UserRole.betrug:
        return 'محظور';
    }
  }

  // Helper method to check if role has admin privileges
  bool get hasAdminPrivileges => this == UserRole.admin;

  // Helper method to check if role is trusted
  bool get isTrustedRole => this == UserRole.trusted;

  // Helper method to check if role is banned
  bool get isBanned => this == UserRole.betrug;
}

// Updated AuthState with proper default values
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserRole role;
  final User? user;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? applicationData; // For pending users
  final String? userEmail; // For pending users without Firebase auth
  final bool isTrustedUser;
  final bool isApproved; // Whether trusted user is approved
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role = UserRole.common,
    this.user,
    this.userData,
    this.applicationData,
    this.userEmail,
    this.isTrustedUser = false, // FIXED: Default should be false, not true
    this.isApproved = false,
    this.error,
  });

  // Computed getters for compatibility and convenience
  bool get isAdmin => role == UserRole.admin;
  bool get isBanned => role == UserRole.betrug;
  bool get hasError => error != null;
  bool get hasUserData => userData != null;
  bool get hasApplicationData => applicationData != null;

  // Helper getters for user information
  String? get userDisplayName {
    if (userData != null) {
      // Try different possible name fields
      return userData!['fullName'] ??
          userData!['profile']?['fullName'] ??
          userData!['aliasName'] ??
          userData!['displayName'];
    }
    if (applicationData != null) {
      return applicationData!['fullName'];
    }
    return user?.displayName;
  }

  String? get userEmailAddress {
    return user?.email ??
        userEmail ??
        userData?['email'] ??
        applicationData?['email'];
  }

  String? get userPhoneNumber {
    if (userData != null) {
      return userData!['phoneNumber'] ??
          userData!['profile']?['phone'] ??
          userData!['mobileNumber'];
    }
    if (applicationData != null) {
      return applicationData!['phoneNumber'];
    }
    return null;
  }

  String? get userLocation {
    if (userData != null) {
      return userData!['location'] ?? userData!['profile']?['location'];
    }
    if (applicationData != null) {
      return applicationData!['location'];
    }
    return null;
  }

  String? get userServiceProvider {
    if (userData != null) {
      return userData!['serviceProvider'] ??
          userData!['profile']?['serviceProvider'] ??
          userData!['servicesProvided'];
    }
    if (applicationData != null) {
      return applicationData!['serviceProvider'];
    }
    return null;
  }

  // UPDATED: Status check helpers with better logic
  bool get canEditProfile {
    if (hasError || !isAuthenticated) return false;
    if (isAdmin) return true;
    if (isTrustedUser && isApproved) {
      final permissions = userData?['permissions'] as Map<String, dynamic>?;
      return permissions?['canEditProfile'] ?? false;
    }
    return false;
  }

  bool get canAccessDashboard {
    if (hasError || !isAuthenticated) return false;
    return isAdmin || (isTrustedUser && isApproved);
  }

  bool get canPerformActions {
    if (hasError || !isAuthenticated) return false;
    return isAdmin || (isTrustedUser && isApproved);
  }

  bool get isPendingApproval {
    return isAuthenticated && isTrustedUser && !isApproved && !isAdmin;
  }

  // NEW: Check if user is a regular user (not admin, not trusted)
  bool get isRegularUser {
    return isAuthenticated &&
        !isAdmin &&
        !isTrustedUser &&
        role == UserRole.common;
  }

  // NEW: Check if user has applied to become trusted but not yet approved
  bool get isApplicant {
    return isAuthenticated &&
        role == UserRole.common &&
        applicationData != null;
  }

  bool get requiresProfileCompletion {
    if (!isAuthenticated || !isApproved) return false;
    if (userData != null) {
      return userData!['profileCompleted'] == false;
    }
    return false;
  }

  // Application status helpers
  String? get applicationStatus {
    if (applicationData != null) {
      return applicationData!['status'];
    }
    if (userData != null) {
      return userData!['status'];
    }
    return null;
  }

  bool get isApplicationPending {
    final status = applicationStatus?.toLowerCase();
    return status == 'pending' || status == 'in_progress';
  }

  bool get isApplicationApproved {
    final status = applicationStatus?.toLowerCase();
    return status == 'approved';
  }

  bool get isApplicationRejected {
    final status = applicationStatus?.toLowerCase();
    return status == 'rejected';
  }

  // UPDATED: Role display helpers with better logic
  String get roleDisplayText {
    if (!isAuthenticated) return 'غير مصادق عليه';
    if (hasError) return 'خطأ في المصادقة';

    switch (role) {
      case UserRole.admin:
        return 'مشرف';
      case UserRole.trusted:
        return isApproved ? 'مستخدم موثوق' : 'في انتظار الموافقة';
      case UserRole.common:
        if (isApplicant) {
          return 'مستخدم عادي (قدم طلب للانضمام)';
        }
        return 'مستخدم عادي';
      case UserRole.betrug:
        return 'محظور';
    }
  }

  String get statusDisplayText {
    if (hasError) return 'خطأ: $error';
    if (!isAuthenticated) return 'غير مسجل الدخول';
    if (isAdmin) return 'مشرف نشط';
    if (isTrustedUser && isApproved) return 'مستخدم موثوق معتمد';
    if (isTrustedUser && !isApproved) return 'في انتظار الموافقة';
    if (isBanned) return 'حساب محظور';
    if (isApplicant) return 'مستخدم عادي - قدم طلب انضمام';
    return 'مستخدم عادي';
  }

  // NEW: Get user type for easier categorization
  String get userType {
    if (!isAuthenticated) return 'unauthenticated';
    if (isAdmin) return 'admin';
    if (isTrustedUser && isApproved) return 'trusted_approved';
    if (isTrustedUser && !isApproved) return 'trusted_pending';
    if (isApplicant) return 'applicant';
    if (isBanned) return 'banned';
    return 'regular';
  }

  // UPDATED: Validation helpers with better checks
  bool get isValidState {
    // Basic validation checks
    if (isAuthenticated && user == null && userEmail == null) return false;
    if (isAdmin && (!isAuthenticated || user == null)) return false;
    if (isTrustedUser && !isAuthenticated) return false;

    // Role consistency checks
    if (isAdmin && role != UserRole.admin) return false;
    if (isTrustedUser && role != UserRole.trusted) return false;
    if (isBanned && role != UserRole.betrug) return false;

    return true;
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (isAuthenticated && user == null && userEmail == null) {
      errors.add('Authenticated state but no user or email');
    }
    if (isAdmin && (!isAuthenticated || user == null)) {
      errors.add('Admin state but not properly authenticated');
    }
    if (isTrustedUser && !isAuthenticated) {
      errors.add('Trusted user state but not authenticated');
    }
    if (isApproved && !isTrustedUser && !isAdmin) {
      errors.add('Approved state but not trusted user or admin');
    }
    if (isAdmin && role != UserRole.admin) {
      errors.add('Admin flag true but role is not admin');
    }
    if (isTrustedUser && role != UserRole.trusted) {
      errors.add('Trusted user flag true but role is not trusted');
    }

    return errors;
  }

  // Copy with method with null handling improvements
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserRole? role,
    User? user,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? applicationData,
    String? userEmail,
    bool? isTrustedUser,
    bool? isApproved,
    String? error,
    bool clearError = false,
    bool clearUserData = false,
    bool clearApplicationData = false,
    bool clearUserEmail = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      user: user ?? this.user,
      userData: clearUserData ? null : (userData ?? this.userData),
      applicationData: clearApplicationData
          ? null
          : (applicationData ?? this.applicationData),
      userEmail: clearUserEmail ? null : (userEmail ?? this.userEmail),
      isTrustedUser: isTrustedUser ?? this.isTrustedUser,
      isApproved: isApproved ?? this.isApproved,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // Factory constructors for common states
  factory AuthState.loading() {
    return const AuthState(isLoading: true);
  }

  factory AuthState.unauthenticated() {
    return const AuthState();
  }

  factory AuthState.error(String errorMessage) {
    return AuthState(error: errorMessage);
  }

  // UPDATED: Factory constructor for regular user (new registration)
  factory AuthState.regularUser({
    required User user,
    Map<String, dynamic>? userData,
    Map<String, dynamic>? applicationData,
  }) {
    return AuthState(
      isAuthenticated: true,
      role: UserRole.common,
      user: user,
      userData: userData,
      applicationData: applicationData,
      isTrustedUser: false, // Not trusted until approved
      isApproved: false, // Not approved until admin approves
    );
  }

  factory AuthState.admin({
    required User user,
    required Map<String, dynamic> userData,
  }) {
    return AuthState(
      isAuthenticated: true,
      role: UserRole.admin,
      user: user,
      userData: userData,
      isTrustedUser: false, // Admins are not in trusted user category
      isApproved: true, // Admins are always approved
    );
  }

  factory AuthState.trustedUser({
    required User user,
    required Map<String, dynamic> userData,
    required bool isApproved,
    Map<String, dynamic>? applicationData,
  }) {
    return AuthState(
      isAuthenticated: true,
      role: UserRole.trusted,
      user: user,
      userData: userData,
      applicationData: applicationData,
      isTrustedUser: true,
      isApproved: isApproved,
    );
  }

  factory AuthState.pendingUser({
    required String email,
    required Map<String, dynamic> applicationData,
  }) {
    return AuthState(
      isAuthenticated: false,
      role: UserRole.trusted,
      applicationData: applicationData,
      userEmail: email,
      isTrustedUser: true,
      isApproved: false,
    );
  }

  // NEW: Factory for banned user
  factory AuthState.bannedUser({
    required User user,
    Map<String, dynamic>? userData,
  }) {
    return AuthState(
      isAuthenticated: true,
      role: UserRole.betrug,
      user: user,
      userData: userData,
      isTrustedUser: false,
      isApproved: false,
    );
  }

  // Equality and hash code
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthState &&
        other.isLoading == isLoading &&
        other.isAuthenticated == isAuthenticated &&
        other.role == role &&
        other.user?.uid == user?.uid &&
        other.isTrustedUser == isTrustedUser &&
        other.isApproved == isApproved &&
        other.userEmail == userEmail &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isAuthenticated,
      role,
      user?.uid,
      isTrustedUser,
      isApproved,
      userEmail,
      error,
    );
  }

  // Enhanced toString method for better debugging
  @override
  String toString() {
    final buffer = StringBuffer('AuthState(');
    buffer.write('isLoading: $isLoading, ');
    buffer.write('isAuthenticated: $isAuthenticated, ');
    buffer.write('role: $role, ');
    buffer.write('user: ${user?.email ?? user?.uid ?? 'null'}, ');
    buffer.write('isTrustedUser: $isTrustedUser, ');
    buffer.write('isApproved: $isApproved, ');
    buffer.write('userEmail: $userEmail, ');
    buffer.write('hasUserData: ${userData != null}, ');
    buffer.write('hasApplicationData: ${applicationData != null}, ');
    buffer.write('error: $error');

    if (userData != null) {
      buffer.write(', userName: ${userDisplayName}');
    }
    if (applicationData != null) {
      buffer.write(', appStatus: ${applicationStatus}');
    }

    buffer.write(', userType: $userType');
    buffer.write(')');
    return buffer.toString();
  }

  // JSON serialization helpers (useful for debugging or persistence)
  Map<String, dynamic> toJson() {
    return {
      'isLoading': isLoading,
      'isAuthenticated': isAuthenticated,
      'role': role.value,
      'userId': user?.uid,
      'userEmail': user?.email ?? userEmail,
      'isTrustedUser': isTrustedUser,
      'isApproved': isApproved,
      'hasUserData': userData != null,
      'hasApplicationData': applicationData != null,
      'error': error,
      'displayName': userDisplayName,
      'status': statusDisplayText,
      'userType': userType,
      'isRegularUser': isRegularUser,
      'isApplicant': isApplicant,
      'isPendingApproval': isPendingApproval,
    };
  }

  // NEW: Helper method to get detailed state description
  String get detailedStateDescription {
    final parts = <String>[];

    if (isLoading) parts.add('Loading');
    if (!isAuthenticated) parts.add('Not Authenticated');
    if (hasError) parts.add('Has Error');

    if (isAuthenticated) {
      parts.add('Authenticated');
      parts.add('Role: ${role.displayName}');

      if (isAdmin) parts.add('Admin');
      if (isTrustedUser) {
        parts.add(isApproved ? 'Trusted (Approved)' : 'Trusted (Pending)');
      }
      if (isRegularUser) parts.add('Regular User');
      if (isApplicant) parts.add('Has Application');
      if (isBanned) parts.add('Banned');
    }

    return parts.join(', ');
  }
}
