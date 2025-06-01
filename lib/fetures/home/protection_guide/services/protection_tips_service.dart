import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/protection_tip.dart';

class ProtectionTipsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'protectionTips';

  Stream<List<ProtectionTip>> getTipsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProtectionTip.fromFirestore(doc))
            .toList())
        .handleError((error) {
      throw Exception('Failed to load tips: $error');
    });
  }

  Future<String> addTip(String title, String description, IconData icon) async {
    try {
      if (title.trim().isEmpty || description.trim().isEmpty) {
        throw ArgumentError('Title and description cannot be empty');
      }

      final QuerySnapshot snapshot =
          await _firestore.collection(_collection).get();
      final int newOrder = snapshot.docs.length;

      final newTip = ProtectionTip(
        id: '',
        title: title.trim(),
        description: description.trim(),
        icon: icon,
        order: newOrder,
      );

      final docRef =
          await _firestore.collection(_collection).add(newTip.toMap());
      return docRef.id; // Return the generated ID
    } catch (e) {
      throw Exception('Failed to add tip: $e');
    }
  }

  Future<void> updateTip(String id, String title, String description,
      IconData icon, int order) async {
    try {
      final updatedTip = ProtectionTip(
        id: id,
        title: title,
        description: description,
        icon: icon,
        order: order,
      );

      await FirebaseFirestore.instance
          .collection('protectionTips')
          .doc(id)
          .update(updatedTip.toMap());
    } catch (e) {
      print('Error updating tip: $e');
    }
  }

  Future<void> deleteTip(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('protectionTips')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting tip: $e');
    }
  }
}
