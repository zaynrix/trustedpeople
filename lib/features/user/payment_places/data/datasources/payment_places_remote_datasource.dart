// lib/features/user/payment_places/data/datasources/payment_places_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/features/user/payment_places/domain/entities/payment_place.dart';

class PaymentPlacesRemoteDatasource {
  final FirebaseFirestore _firestore;

  PaymentPlacesRemoteDatasource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Get all payment places stream
  Stream<List<PaymentPlace>> getAllPaymentPlacesStream() {
    return _firestore
        .collection(FirebaseConstants.paymentPlaces)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentPlace.fromFirestore(doc))
            .toList());
  }

  // Get unique categories for filtering
  Stream<List<String>> getUniqueCategoriesStream() {
    return _firestore
        .collection(FirebaseConstants.paymentPlaces)
        .snapshots()
        .map((snapshot) {
      final categories = snapshot.docs
          .map((doc) => doc['category'] as String? ?? '')
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    });
  }

  // Get unique locations for filtering
  Stream<List<String>> getUniqueLocationsStream() {
    return _firestore
        .collection(FirebaseConstants.paymentPlaces)
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

  // Get place by ID
  Future<PaymentPlace?> getPaymentPlaceById(String id) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.paymentPlaces)
          .doc(id)
          .get();

      if (!doc.exists) {
        return null;
      }

      return PaymentPlace.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting payment place by ID: $e');
      return null;
    }
  }

  // Add new payment place
  Future<bool> addPaymentPlace(PaymentPlace place) async {
    try {
      // Generate a new document ID if none provided
      final docRef = place.id.isEmpty
          ? _firestore.collection(FirebaseConstants.paymentPlaces).doc()
          : _firestore
              .collection(FirebaseConstants.paymentPlaces)
              .doc(place.id);

      final placeData = place.toMap();

      await docRef.set({
        ...placeData,
        'id': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error adding payment place: $e');
      return false;
    }
  }

  // Update existing payment place
  Future<bool> updatePaymentPlace(PaymentPlace place) async {
    try {
      if (place.id.isEmpty) {
        return false;
      }

      final placeData = place.toMap();
      placeData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(FirebaseConstants.paymentPlaces)
          .doc(place.id)
          .update(placeData);

      return true;
    } catch (e) {
      debugPrint('Error updating payment place: $e');
      return false;
    }
  }

  // Delete payment place
  Future<bool> deletePaymentPlace(String id) async {
    try {
      await _firestore
          .collection(FirebaseConstants.paymentPlaces)
          .doc(id)
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error deleting payment place: $e');
      return false;
    }
  }
}
