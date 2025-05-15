import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/fetures/trusted/domain/user_entity.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String aliasName,
    required String mobileNumber,
    required String location,
    required bool isTrusted,
    String servicesProvided = '',
    String telegramAccount = '',
    String otherAccounts = '',
    String reviews = '',
  }) : super(
    id: id,
    aliasName: aliasName,
    mobileNumber: mobileNumber,
    location: location,
    isTrusted: isTrusted,
    servicesProvided: servicesProvided,
    telegramAccount: telegramAccount,
    otherAccounts: otherAccounts,
    reviews: reviews,
  );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      id: doc.id,
      aliasName: data['aliasName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      location: data['location'] ?? '',
      isTrusted: data['isTrusted'] ?? false,
      servicesProvided: data['servicesProvided'] ?? '',
      telegramAccount: data['telegramAccount'] ?? '',
      otherAccounts: data['otherAccounts'] ?? '',
      reviews: data['reviews'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aliasName': aliasName,
      'mobileNumber': mobileNumber,
      'location': location,
      'isTrusted': isTrusted,
      'servicesProvided': servicesProvided,
      'telegramAccount': telegramAccount,
      'otherAccounts': otherAccounts,
      'reviews': reviews,
    };
  }
}