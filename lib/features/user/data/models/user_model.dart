import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/features/user/domain/entities/user.dart';

/// User model that extends the User entity and handles conversion to/from Firestore
class UserModel extends User {
  UserModel({
    required String id,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required String servicesProvided,
    required String telegramAccount,
    required String otherAccounts,
    required String reviews,
    required bool isTrusted,
  }) : super(
          id: id,
          aliasName: aliasName,
          mobileNumber: mobileNumber,
          location: location,
          servicesProvided: servicesProvided,
          telegramAccount: telegramAccount,
          otherAccounts: otherAccounts,
          reviews: reviews,
          isTrusted: isTrusted,
        );

  /// Create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    return UserModel(
      id: data?['id'] ?? snapshot.id,
      aliasName: data?['aliasName'] ?? '',
      mobileNumber: data?['mobileNumber'] ?? '',
      location: data?['location'] ?? '',
      servicesProvided: data?['servicesProvided'] ?? '',
      telegramAccount: data?['telegramAccount'] ?? '',
      otherAccounts: data?['otherAccounts'] ?? '',
      reviews: data?['reviews'] ?? '',
      isTrusted: data?['isTrusted'] ?? false,
    );
  }

  /// Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'aliasName': aliasName,
      'mobileNumber': mobileNumber,
      'location': location,
      'servicesProvided': servicesProvided,
      'telegramAccount': telegramAccount,
      'otherAccounts': otherAccounts,
      'reviews': reviews,
      'isTrusted': isTrusted,
    };
  }

  /// Create a UserModel from a User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      aliasName: user.aliasName,
      mobileNumber: user.mobileNumber,
      location: user.location,
      servicesProvided: user.servicesProvided,
      telegramAccount: user.telegramAccount,
      otherAccounts: user.otherAccounts,
      reviews: user.reviews,
      isTrusted: user.isTrusted,
    );
  }
}
