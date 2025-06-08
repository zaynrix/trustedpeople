// Trusted user model (for approved users)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_base_model.dart';
import 'package:trustedtallentsvalley/fetures/auth/shared_files/models/user_role_enum.dart';

class TrustedUser extends BaseUser {
  final String phoneNumber;
  final String? additionalPhone;
  final String serviceProvider;
  final String location;
  final String? aliasName;
  final String? telegramAccount;
  final String? description;
  final String? workingHours;
  final String? profileImageUrl;
  final Map<String, String> socialLinks;
  final bool isApproved;
  final String? applicationId;
  final double rating;
  final int totalReviews;
  final bool profileCompleted;
  final DateTime? lastActive;

  const TrustedUser({
    required super.uid,
    required super.email,
    required super.fullName,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    required this.phoneNumber,
    this.additionalPhone,
    required this.serviceProvider,
    required this.location,
    this.aliasName,
    this.telegramAccount,
    this.description,
    this.workingHours,
    this.profileImageUrl,
    this.socialLinks = const {},
    this.isApproved = true,
    this.applicationId,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.profileCompleted = false,
    this.lastActive,
  });

  factory TrustedUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrustedUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? data['aliasName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['mobileNumber'] ?? '',
      additionalPhone: data['additionalPhone'],
      serviceProvider:
          data['serviceProvider'] ?? data['servicesProvided'] ?? '',
      location: data['location'] ?? '',
      aliasName: data['aliasName'],
      telegramAccount: data['telegramAccount'],
      description: data['description'],
      workingHours: data['workingHours'],
      profileImageUrl: data['profileImageUrl'],
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
      isApproved: data['isApproved'] ?? true,
      isActive: data['isActive'] ?? true,
      applicationId: data['applicationId'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      profileCompleted: data['profileCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'aliasName': aliasName ?? fullName,
      'phoneNumber': phoneNumber,
      'mobileNumber': phoneNumber,
      'additionalPhone': additionalPhone,
      'serviceProvider': serviceProvider,
      'servicesProvided': serviceProvider,
      'location': location,
      'telegramAccount': telegramAccount,
      'description': description,
      'workingHours': workingHours,
      'profileImageUrl': profileImageUrl,
      'socialLinks': socialLinks,
      'isApproved': isApproved,
      'isActive': isActive,
      'applicationId': applicationId,
      'rating': rating,
      'totalReviews': totalReviews,
      'profileCompleted': profileCompleted,
      'role': UserRole.trusted.value,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    };
  }

  TrustedUser copyWith({
    String? fullName,
    String? phoneNumber,
    String? additionalPhone,
    String? serviceProvider,
    String? location,
    String? aliasName,
    String? telegramAccount,
    String? description,
    String? workingHours,
    String? profileImageUrl,
    Map<String, String>? socialLinks,
    bool? isApproved,
    bool? isActive,
    bool? profileCompleted,
  }) {
    return TrustedUser(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      additionalPhone: additionalPhone ?? this.additionalPhone,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      location: location ?? this.location,
      aliasName: aliasName ?? this.aliasName,
      telegramAccount: telegramAccount ?? this.telegramAccount,
      description: description ?? this.description,
      workingHours: workingHours ?? this.workingHours,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      socialLinks: socialLinks ?? this.socialLinks,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      applicationId: applicationId,
      rating: rating,
      totalReviews: totalReviews,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActive: lastActive,
    );
  }
}
