// User roles enum
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
