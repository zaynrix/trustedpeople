// lib/features/admin/user_management/data/datasources/user_management_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/features/admin/dashboard/domain/entities/managed_user.dart';

class UserManagementRemoteDatasource {
  final FirebaseFirestore _firestore;

  UserManagementRemoteDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Get trusted users stream
  Stream<List<ManagedUser>> getTrustedUsersStream() {
    return _firestore
        .collection(FirebaseConstants.trustedUsers)
        .where('isTrusted', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ManagedUser.fromFirestore(doc))
            .toList());
  }

  // Get untrusted users stream
  Stream<List<ManagedUser>> getUntrustedUsersStream() {
    return _firestore
        .collection(FirebaseConstants.trustedUsers)
        .where('isTrusted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ManagedUser.fromFirestore(doc))
            .toList());
  }

  // Get all users stream
  Stream<List<ManagedUser>> getAllUsersStream() {
    return _firestore
        .collection(FirebaseConstants.trustedUsers)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ManagedUser.fromFirestore(doc))
            .toList());
  }

  // Get unique locations for filtering
  Stream<List<String>> getUniqueLocationsStream() {
    return _firestore
        .collection(FirebaseConstants.trustedUsers)
        .snapshots()
        .map((snapshot) {
      final locations = snapshot.docs
          .map((doc) => doc['location'] as String? ?? '')
          .where((location) => location.isNotEmpty)
          .toSet()
          .toList();
      locations.sort();
      return locations;
    });
  }

  // Get user by ID
  Future<ManagedUser?> getUserById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.trustedUsers)
          .doc(id)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ManagedUser.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  // Add new user
  Future<bool> addUser(ManagedUser user) async {
    try {
      // Generate a new document ID if none provided
      final docRef = user.id.isEmpty
          ? _firestore.collection(FirebaseConstants.trustedUsers).doc()
          : _firestore.collection(FirebaseConstants.trustedUsers).doc(user.id);

      final userData = user.toMap();
      if (user.id.isEmpty) {
        userData['id'] = docRef.id;
      }

      userData['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(userData);
      return true;
    } catch (e) {
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  // Update existing user
  Future<bool> updateUser(ManagedUser user) async {
    try {
      if (user.id.isEmpty) {
        return false;
      }

      final userData = user.toMap();
      userData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseConstants.trustedUsers)
          .doc(user.id)
          .update(userData);

      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    try {
      await _firestore
          .collection(FirebaseConstants.trustedUsers)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  // Get trusted users count
  Future<int> getTrustedUsersCount() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.trustedUsers)
        .where('isTrusted', isEqualTo: true)
        .count()
        .get();

    return snapshot.count!;
  }

  // Get untrusted users count
  Future<int> getUntrustedUsersCount() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.trustedUsers)
        .where('isTrusted', isEqualTo: false)
        .count()
        .get();

    return snapshot.count!;
  }
}
