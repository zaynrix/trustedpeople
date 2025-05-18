class User {
  final String uid;
  final String email;
  final UserRole role;
  final bool isAuthenticated;

  const User({
    required this.uid,
    required this.email,
    required this.role,
    this.isAuthenticated = false,
  });

  bool get isAdmin => role == UserRole.admin;
}

/// User roles in the system
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
}
