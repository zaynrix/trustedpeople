import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../models/admin_payment_place_model.dart';

abstract class AdminPaymentPlacesRemoteDataSource {
  Stream<List<AdminPaymentPlaceModel>> getPaymentPlaces();
  Future<AdminPaymentPlaceModel?> getPaymentPlaceById(String id);
  Stream<List<String>> getCategories();
  Stream<List<String>> getLocations();
  Future<String> addPaymentPlace(AdminPaymentPlaceModel place);
  Future<void> updatePaymentPlace(AdminPaymentPlaceModel place);
  Future<void> deletePaymentPlace(String id);
  Future<void> updateVerificationStatus(String id, bool isVerified);
  Future<String> exportPlacesToCSV();
  Future<String> exportPlacesToExcel();
}

class AdminPaymentPlacesRemoteDataSourceImpl
    implements AdminPaymentPlacesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final String _collection = 'paymentPlaces';

  AdminPaymentPlacesRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<AdminPaymentPlaceModel>> getPaymentPlaces() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AdminPaymentPlaceModel.fromFirestore(doc))
        .toList());
  }

  @override
  Future<AdminPaymentPlaceModel?> getPaymentPlaceById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return AdminPaymentPlaceModel.fromFirestore(doc);
  }

  @override
  Stream<List<String>> getCategories() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final categories = snapshot.docs
          .map((doc) =>
      (doc.data() as Map<String, dynamic>)['category'] as String? ?? '')
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    });
  }

  @override
  Stream<List<String>> getLocations() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      final locations = snapshot.docs
          .map((doc) =>
      (doc.data() as Map<String, dynamic>)['location'] as String? ?? '')
          .where((location) => location.isNotEmpty)
          .toSet()
          .toList();
      locations.sort();
      return locations;
    });
  }

  @override
  Future<String> addPaymentPlace(AdminPaymentPlaceModel place) async {
    final docRef = _firestore.collection(_collection).doc();
    await docRef.set({
      ...place.toMapWithCreatedAt(),
      'id': docRef.id,
    });
    return docRef.id;
  }

  @override
  Future<void> updatePaymentPlace(AdminPaymentPlaceModel place) async {
    await _firestore.collection(_collection).doc(place.id).update(place.toMap());
  }

  @override
  Future<void> deletePaymentPlace(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  @override
  Future<void> updateVerificationStatus(String id, bool isVerified) async {
    await _firestore.collection(_collection).doc(id).update({
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<String> exportPlacesToCSV() async {
    final snapshot = await _firestore.collection(_collection).get();
    final places = snapshot.docs
        .map((doc) => AdminPaymentPlaceModel.fromFirestore(doc))
        .toList();

    // Generate CSV
    String csv = 'الاسم,التصنيف,الموقع,رقم الهاتف,طرق الدفع,ساعات العمل,التقييم,عدد التقييمات,حالة التحقق\n';

    for (var place in places) {
      csv +=
      '${place.name},${place.category},${place.location},${place.phoneNumber},"${place.paymentMethods.join(', ')}",${place.workingHours},${place.rating},${place.reviewsCount},${place.isVerified ? 'متحقق' : 'قيد التحقق'}\n';
    }

    // In a real app, you would save this to a file and return the file path
    return 'data:text/csv;charset=utf-8,${Uri.encodeComponent(csv)}';
  }

  @override
  Future<String> exportPlacesToExcel() async {
    // In a real app, this would use a package like excel to create an Excel file
    // For now, we'll just return a similar format as CSV
    return exportPlacesToCSV();
  }
}