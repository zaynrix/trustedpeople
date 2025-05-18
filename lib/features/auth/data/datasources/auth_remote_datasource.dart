import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:trustedtallentsvalley/features/auth/data/models/user_model.dart';
import 'package:trustedtallentsvalley/features/auth/domain/entities/user.dart';

/// Remote data source for authentication operations
class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  /// Sign in with email and password
  Future<UserModel> signIn(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Authentication failed: No user returned');
      }

      // Check if user is an admin
      final role = await _getUserRole(firebaseUser.uid);
      return UserModel.fromFirebaseUser(firebaseUser, role);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  /// Get the current user if authenticated
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    // Check if user is an admin
    final role = await _getUserRole(firebaseUser.uid);
    return UserModel.fromFirebaseUser(firebaseUser, role);
  }

  /// Check if a user is an admin
  Future<bool> isUserAdmin(String uid) async {
    final role = await _getUserRole(uid);
    return role == UserRole.admin;
  }

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      // Get user role from Firestore
      final role = await _getUserRole(firebaseUser.uid);
      return UserModel.fromFirebaseUser(firebaseUser, role);
    });
  }

  /// Get user role from Firestore
  Future<UserRole> _getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('admins').doc(uid).get();

      if (userDoc.exists) {
        final roleValue =
            userDoc.data()?['role'] as int? ?? 2; // Default to common (2)
        return UserRole.fromInt(roleValue);
      } else {
        // If user is not in admins collection, they're not an admin
        return UserRole.common;
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return UserRole.common; // Default to common on error
    }
  }

  /// Handle FirebaseAuth exceptions
  Exception _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return Exception('Invalid email or password');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later');
      case 'operation-not-allowed':
        return Exception('Email/password sign-in is not enabled');
      case 'invalid-email':
        return Exception('Invalid email address');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}
