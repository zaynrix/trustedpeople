import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:trustedtallentsvalley/app/core/constants/app_connstants.dart';

/// Data source for User-related operations
class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource(this.firestore);

  /// Get all trusted users from Firestore
  Stream<QuerySnapshot> getTrustedUsersStream() {
    return firestore
        .collection(AppConstants.trustedUsersCollection)
        .where(AppConstants.isTrusted, isEqualTo: true)
        .snapshots();
  }

  /// Get all untrusted users from Firestore
  Stream<QuerySnapshot> getUntrustedUsersStream() {
    return firestore
        .collection(AppConstants.trustedUsersCollection)
        .where(AppConstants.isTrusted, isEqualTo: false)
        .snapshots();
  }

  /// Get all users from Firestore
  Stream<QuerySnapshot> getAllUsersStream() {
    return firestore
        .collection(AppConstants.trustedUsersCollection)
        .snapshots();
  }

  /// Get a user by ID from Firestore
  Future<DocumentSnapshot?> getUserById(String id) async {
    try {
      return await firestore
          .collection(AppConstants.trustedUsersCollection)
          .doc(id)
          .get();
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }

  /// Add a new user to Firestore
  Future<bool> addUser(Map<String, dynamic> userData) async {
    try {
      // Generate a new document ID
      final docRef =
          firestore.collection(AppConstants.trustedUsersCollection).doc();

      // Add 'id' field to userData
      userData['id'] = docRef.id;

      // Add timestamp
      userData['createdAt'] = FieldValue.serverTimestamp();

      await docRef.set(userData);
      return true;
    } catch (e) {
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  /// Update an existing user in Firestore
  Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      // Add timestamp
      userData['updatedAt'] = FieldValue.serverTimestamp();

      await firestore
          .collection(AppConstants.trustedUsersCollection)
          .doc(id)
          .update(userData);
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  /// Delete a user from Firestore
  Future<bool> deleteUser(String id) async {
    try {
      await firestore
          .collection(AppConstants.trustedUsersCollection)
          .doc(id)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  /// Get all unique locations from Firestore
  Stream<QuerySnapshot> getLocationsStream() {
    return firestore
        .collection(AppConstants.trustedUsersCollection)
        .snapshots();
  }
}
