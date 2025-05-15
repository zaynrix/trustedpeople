import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/app/config/firebase_constant.dart';
import 'package:trustedtallentsvalley/fetures/trusted/data/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource({required this.firestore});

  Stream<List<UserModel>> getTrustedUsers() {
    return firestore
        .collection(FirebaseConstants.trustedUsers)
        .where("isTrusted", isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<List<UserModel>> getUntrustedUsers() {
    return firestore
        .collection(FirebaseConstants.trustedUsers)
        .where("isTrusted", isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<List<UserModel>> getAllUsers() {
    return firestore
        .collection(FirebaseConstants.trustedUsers)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<List<String>> getLocations() {
    return firestore
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

  Future<void> addUser(UserModel user) async {
    final docRef = firestore.collection(FirebaseConstants.trustedUsers).doc();

    await docRef.set({
      ...user.toJson(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(UserModel user) async {
    await firestore.collection(FirebaseConstants.trustedUsers).doc(user.id).update({
      ...user.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String id) async {
    await firestore.collection(FirebaseConstants.trustedUsers).doc(id).delete();
  }
}