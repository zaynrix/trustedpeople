import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String aliasName;
  final String mobileNumber;
  final String location;
  final String servicesProvided;
  final String telegramAccount;
  final String otherAccounts;
  final String reviews;
  final bool isTrusted;
  final int role; // Added role field
  final DateTime? createdAt;
  final String addedBy; // Nuevo campo

  UserModel({
    required this.id,
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
    required this.isTrusted,
    required this.role, // Add to constructor
    this.createdAt,
    this.addedBy = '', // Valor por defecto
  });

  factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    // Determine role from Firestore data, with fallback logic
    int role;
    if (data?['role'] != null) {
      // If role exists in the document, use it
      role = (data!['role'] as num).toInt();
    } else {
      // If role doesn't exist, derive it from isTrusted
      bool isTrusted = data?['isTrusted'] ?? false;
      role = isTrusted ? 1 : 3; // Trusted (1) or Fraud (3)
    }

    return UserModel(
      id: snapshot.id, // Use document ID directly
      aliasName: data?['aliasName'] ?? '',
      mobileNumber: data?['mobileNumber'] ?? '',
      location: data?['location'] ?? '',
      servicesProvided: data?['servicesProvided'] ?? '',
      telegramAccount: data?['telegramAccount'] ?? '',
      otherAccounts: data?['otherAccounts'] ?? '',
      reviews: data?['reviews'] ?? '',
      isTrusted: data?['isTrusted'] ?? false,
      role: role,
      createdAt: data?['createdAt'] != null
          ? (data?['createdAt'] as Timestamp).toDate()
          : null,
      addedBy: data?['addedBy'] ?? '', // Add role to constructor
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aliasName': aliasName,
      'mobileNumber': mobileNumber,
      'location': location,
      'servicesProvided': servicesProvided,
      'telegramAccount': telegramAccount,
      'otherAccounts': otherAccounts,
      'reviews': reviews,
      'isTrusted': isTrusted,
      'role': role, // Include role in map
    };
  }

  // Helper method to get status text based on role
  String get statusText {
    switch (role) {
      case 0:
        return 'مشرف'; // Admin
      case 1:
        return 'موثوق'; // Trusted
      case 2:
        return 'معروف'; // Known person
      case 3:
        return 'نصاب'; // Fraud
      default:
        return isTrusted ? 'موثوق' : 'نصاب'; // Fallback
    }
  }

  // Helper method to get color based on role (optional)
  // You can use this in your UI if needed
  Map<String, dynamic> getStatusStyle() {
    switch (role) {
      case 0: // Admin
        return {
          'color': 'purple',
          'icon': 'admin_panel_settings',
        };
      case 1: // Trusted
        return {
          'color': 'green',
          'icon': 'verified_user',
        };
      case 2: // Known
        return {
          'color': 'blue',
          'icon': 'person',
        };
      case 3: // Fraud
        return {
          'color': 'red',
          'icon': 'warning',
        };
      default:
        return isTrusted
            ? {'color': 'green', 'icon': 'verified_user'}
            : {'color': 'red', 'icon': 'warning'};
    }
  }
}
