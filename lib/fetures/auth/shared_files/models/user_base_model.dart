// Base user model
abstract class BaseUser {
  final String uid;
  final String email;
  final String fullName;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
}
