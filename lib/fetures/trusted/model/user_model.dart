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
  final int role; // Primary field for user status
  final DateTime? createdAt;
  final String addedBy;

  UserModel({
    required this.id,
    required this.aliasName,
    required this.mobileNumber,
    required this.location,
    required this.servicesProvided,
    required this.telegramAccount,
    required this.otherAccounts,
    required this.reviews,
    required this.role,
    this.createdAt,
    this.addedBy = '',
  });

  factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    // Determine role from Firestore data, with fallback logic
    int role;
    if (data?['role'] != null) {
      // If role exists in the document, use it
      role = (data!['role'] as num).toInt();
    } else if (data?['isTrusted'] != null) {
      // Fallback: if old isTrusted field exists, convert it
      bool isTrusted = data!['isTrusted'] as bool;
      role = isTrusted ? 1 : 3; // Trusted (1) or Fraud (3)
    } else {
      // Default to "Known" if no role or trust info is available
      role = 2;
    }

    return UserModel(
      id: snapshot.id,
      aliasName: data?['aliasName'] ?? '',
      mobileNumber: data?['mobileNumber'] ?? '',
      location: data?['location'] ?? '',
      servicesProvided: data?['servicesProvided'] ?? '',
      telegramAccount: data?['telegramAccount'] ?? '',
      otherAccounts: data?['otherAccounts'] ?? '',
      reviews: data?['reviews'] ?? '',
      role: role,
      createdAt: data?['createdAt'] != null
          ? (data?['createdAt'] as Timestamp).toDate()
          : null,
      addedBy: data?['addedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'aliasName': aliasName,
      'mobileNumber': mobileNumber,
      'location': location,
      'servicesProvided': servicesProvided,
      'telegramAccount': telegramAccount,
      'otherAccounts': otherAccounts,
      'reviews': reviews,
      'role': role,
      'addedBy': addedBy,
    };

    // Only add createdAt if it exists
    if (createdAt != null) {
      map['createdAt'] = Timestamp.fromDate(createdAt!);
    }

    return map;
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
        return 'غير محدد'; // Undefined/Unknown
    }
  }

  // Helper method to get style based on role
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
        return {
          'color': 'grey',
          'icon': 'help_outline',
        };
    }
  }

  // Helper method to check if user is trusted (role == 1)
  bool get isTrusted => role == 1;

  // Helper method to check if user is admin (role == 0)
  bool get isAdmin => role == 0;

  // Helper method to check if user is fraud (role == 3)
  bool get isFraud => role == 3;

  // Helper method to check if user is known (role == 2)
  bool get isKnown => role == 2;

  // CopyWith method for easy updates
  UserModel copyWith({
    String? id,
    String? aliasName,
    String? mobileNumber,
    String? location,
    String? servicesProvided,
    String? telegramAccount,
    String? otherAccounts,
    String? reviews,
    int? role,
    DateTime? createdAt,
    String? addedBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      aliasName: aliasName ?? this.aliasName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      location: location ?? this.location,
      servicesProvided: servicesProvided ?? this.servicesProvided,
      telegramAccount: telegramAccount ?? this.telegramAccount,
      otherAccounts: otherAccounts ?? this.otherAccounts,
      reviews: reviews ?? this.reviews,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      addedBy: addedBy ?? this.addedBy,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, aliasName: $aliasName, role: $role, statusText: $statusText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
