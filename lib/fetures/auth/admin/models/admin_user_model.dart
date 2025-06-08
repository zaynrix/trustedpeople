// Admin user model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_base_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_role_enum.dart';

class AdminUser extends BaseUser {
  final UserRole role;
  final bool isAdmin;

  const AdminUser({
    required super.uid,
    required super.email,
    required super.fullName,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    this.role = UserRole.admin,
    this.isAdmin = true,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: UserRole.fromInt(data['role'] ?? 0),
      isAdmin: data['isAdmin'] ?? true,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role.value,
      'isAdmin': isAdmin,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
