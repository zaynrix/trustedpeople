// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class AuthState {
  final User? user;
  final UserRole role;
  final bool isLoading;
  final String? error;

  bool get isAdmin => role == UserRole.admin;
  bool get isAuthenticated => user != null;

  AuthState({
    this.user,
    this.role = UserRole.common,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    UserRole? role,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._auth, this._firestore) : super(AuthState()) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        state = AuthState();
      } else {
        await _fetchUserRole(user);
      }
    });
  }

  Future<void> _fetchUserRole(User user) async {
    try {
      state = state.copyWith(isLoading: true);

      // Check the user's role in Firestore
      final userDoc = await _firestore.collection('admins').doc(user.uid).get();

      if (userDoc.exists) {
        final roleValue = userDoc.data()?['role'] as int? ??
            2; // Default to common (2) if role not specified
        state = state.copyWith(
          user: user,
          role: UserRole.fromInt(roleValue),
          isLoading: false,
        );
      } else {
        // If user is not in admins collection, they're not an admin
        state = state.copyWith(
          user: user,
          role: UserRole.common,
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      state = state.copyWith(
        user: user,
        role: UserRole.common, // Default to common on error
        isLoading: false,
        error: 'Failed to fetch user role',
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Auth state listener will update the state
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to sign out',
      );
    }
  }
}

// Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);
  return AuthNotifier(auth, firestore);
});

// Helper providers
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
