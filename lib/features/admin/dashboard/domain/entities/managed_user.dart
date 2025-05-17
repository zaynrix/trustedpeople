import 'package:cloud_firestore/cloud_firestore.dart';

class ManagedUser {
  final String id;
  final String aliasName;
  final String mobileNumber;
  final String location;
  final String servicesProvided;
  final String telegramAccount;
  final String otherAccounts;
  final String reviews;
  final bool isTrusted;

  ManagedUser({
    required this.id,
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
    required this.isTrusted,
  });

  factory ManagedUser.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    return ManagedUser(
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

  ManagedUser copyWith({
    String? id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
    bool? isTrusted,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      aliasName: aliasName ?? this.aliasName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      location: location ?? this.location,
      servicesProvided: servicesProvided ?? this.servicesProvided,
      telegramAccount: telegramAccount ?? this.telegramAccount,
      otherAccounts: otherAccounts ?? this.otherAccounts,
      reviews: reviews ?? this.reviews,
      isTrusted: isTrusted ?? this.isTrusted,
    );
  }
}
