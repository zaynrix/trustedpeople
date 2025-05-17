import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';

/// Model class for User entity
class UserModel extends User {
  const UserModel({
    required String uid,
    required String email,
    required UserRole role,
    bool isAuthenticated = false,
  }) : super(
          uid: uid,
          email: email,
          role: role,
          isAuthenticated: isAuthenticated,
        );

  /// Create a UserModel from a Firebase User
  factory UserModel.fromFirebaseUser(
      firebase_auth.User firebaseUser, UserRole role) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      role: role,
      isAuthenticated: true,
    );
  }

  /// Create an empty/unauthenticated UserModel
  factory UserModel.empty() {
    return const UserModel(
      uid: '',
      email: '',
      role: UserRole.common,
      isAuthenticated: false,
    );
  }

  /// Convert UserModel to a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.value,
      'isAuthenticated': isAuthenticated,
    };
  }

  /// Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromInt(map['role'] ?? 2),
      isAuthenticated: map['isAuthenticated'] ?? false,
    );
  }

  /// Create a copy of UserModel with some changes
  UserModel copyWith({
    String? uid,
    String? email,
    UserRole? role,
    bool? isAuthenticated,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
